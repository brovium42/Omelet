import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SIZE = 1024
SS = 4
CANVAS = SIZE * SS

CENTER = (512, 740)
RADIUS_X = 330
RADIUS_Y = 250
BASE_BULGE = 18
TILT = -10

BODY_TOP = (255, 226, 122)
BODY_BOTTOM = (246, 169, 43)
RIM = (226, 132, 30)
FOLD = (255, 243, 176)
SPOT = (236, 152, 46)
HERBS = [(76, 175, 80), (46, 125, 50), (102, 187, 106)]
STEAM_NEAR = (232, 232, 232)
STEAM_FAR = (150, 150, 150)


def s(value):
    return value * SS


def rotate(point, angle=TILT, origin=CENTER):
    rad = math.radians(angle)
    x, y = point[0] - origin[0], point[1] - origin[1]
    return (
        origin[0] + x * math.cos(rad) - y * math.sin(rad),
        origin[1] + x * math.sin(rad) + y * math.cos(rad),
    )


def scaled(points):
    return [(s(x), s(y)) for x, y in points]


def body_outline(inset=0.0):
    cx, cy = CENTER
    rx, ry = RADIUS_X - inset, RADIUS_Y - inset
    points = []
    for i in range(180, 361):
        a = math.radians(i)
        points.append((cx + rx * math.cos(a), cy + ry * math.sin(a)))
    bulge = BASE_BULGE - inset * 0.3
    for i in range(1, 180):
        t = i / 180
        x = cx + rx - 2 * rx * t
        y = cy - inset * 0.5 + bulge * math.sin(math.pi * t)
        points.append((x, y))
    return [rotate(p) for p in points]


def seam(offset):
    cx, cy = CENTER
    rx = RADIUS_X - 34
    points = []
    for i in range(0, 101):
        t = i / 100
        x = cx - rx + 2 * rx * t
        lift = offset + 10 * (1 - math.sin(math.pi * t))
        y = cy + (BASE_BULGE - 4) * math.sin(math.pi * t) - lift
        points.append(rotate((x, y)))
    return points

def mask_of(points):
    mask = Image.new("L", (CANVAS, CANVAS), 0)
    ImageDraw.Draw(mask).polygon(scaled(points), fill=255)
    return mask


def gradient_layer():
    ys, xs = np.mgrid[0:CANVAS, 0:CANVAS].astype(np.float32) / SS
    rad = math.radians(TILT)
    dx, dy = -math.sin(rad), math.cos(rad)
    t = ((xs - CENTER[0]) * dx + (ys - CENTER[1]) * dy + RADIUS_Y) / (
        RADIUS_Y + BASE_BULGE
    )
    t = np.clip(t, 0, 1)[..., None]
    top = np.array(BODY_TOP, np.float32)
    bottom = np.array(BODY_BOTTOM, np.float32)
    rgb = top + (bottom - top) * t
    alpha = np.full((CANVAS, CANVAS, 1), 255, np.float32)
    return Image.fromarray(np.concatenate([rgb, alpha], -1).astype(np.uint8))


def stroke(draw, points, width, color):
    pts = scaled(points)
    draw.line(pts, fill=color, width=int(s(width)), joint="curve")
    r = s(width) / 2
    for x, y in (pts[0], pts[-1]):
        draw.ellipse((x - r, y - r, x + r, y + r), fill=color)


def tapered(draw, points, start_width, end_width, start_color, end_color):
    count = len(points)
    for i, (x, y) in enumerate(points):
        t = i / (count - 1)
        w = s(start_width + (end_width - start_width) * t) / 2
        color = tuple(
            int(a + (b - a) * t) for a, b in zip(start_color, end_color)
        ) + (255,)
        draw.ellipse((s(x) - w, s(y) - w, s(x) + w, s(y) + w), fill=color)


def steam_path(x0, y0, height, amplitude, phase):
    points = []
    steps = 160
    for i in range(steps + 1):
        t = i / steps
        y = y0 - height * t
        x = x0 + amplitude * math.sin(phase + t * math.pi * 1.6) * (0.4 + 0.6 * t)
        points.append((x, y))
    return points


def draw_steam(layer, mono):
    draw = ImageDraw.Draw(layer)
    near = (255, 255, 255) if mono else STEAM_NEAR
    far = (255, 255, 255) if mono else STEAM_FAR
    specs = [
        (404, 450, 170, 22, 0.0, 30, 12),
        (512, 420, 200, 26, 1.4, 34, 12),
        (620, 420, 170, 22, 2.6, 30, 12),
    ]
    for x0, y0, height, amp, phase, w0, w1 in specs:
        tapered(draw, steam_path(x0, y0, height, amp, phase), w0, w1, near, far)


def draw_omelet(layer, mono):
    outline = body_outline()
    body_mask = mask_of(outline)
    if mono:
        fill = Image.new("RGBA", (CANVAS, CANVAS), (255, 255, 255, 255))
    else:
        fill = gradient_layer()
    layer.paste(fill, (0, 0), body_mask)

    draw = ImageDraw.Draw(layer)
    if mono:
        stroke(draw, seam(44), 18, (0, 0, 0, 0))
        return

    inner = mask_of(body_outline(inset=22))
    rim = Image.new("L", (CANVAS, CANVAS), 0)
    rim.paste(body_mask, (0, 0))
    rim.paste(0, (0, 0), inner)
    rim = rim.filter(ImageFilter.GaussianBlur(s(3)))
    rim_layer = Image.new("RGBA", (CANVAS, CANVAS), RIM + (255,))
    layer.paste(rim_layer, (0, 0), Image.fromarray(
        np.minimum(np.array(rim), np.array(body_mask))
    ))

    spots = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    sd = ImageDraw.Draw(spots)
    for dx, dy, rx, ry in [
        (-150, -90, 34, 22), (-40, -170, 26, 18), (90, -120, 40, 24),
        (190, -60, 22, 16), (-220, -40, 20, 14), (20, -70, 18, 12),
    ]:
        x, y = rotate((CENTER[0] + dx, CENTER[1] + dy))
        sd.ellipse(
            (s(x - rx), s(y - ry), s(x + rx), s(y + ry)),
            fill=SPOT + (120,),
        )
    spots = spots.filter(ImageFilter.GaussianBlur(s(4)))
    clipped = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    clipped.paste(spots, (0, 0), inner)
    layer.alpha_composite(clipped)

    stroke(draw, seam(40), 14, FOLD + (255,))

    for (dx, dy, angle, color) in [
        (-110, -120, 30, HERBS[0]), (-20, -195, -20, HERBS[1]),
        (70, -160, 55, HERBS[2]), (160, -110, 10, HERBS[0]),
        (-200, -80, -45, HERBS[2]), (40, -100, 80, HERBS[1]),
    ]:
        x, y = rotate((CENTER[0] + dx, CENTER[1] + dy))
        a = math.radians(angle + TILT)
        half = 16
        p1 = (x - half * math.cos(a), y - half * math.sin(a))
        p2 = (x + half * math.cos(a), y + half * math.sin(a))
        stroke(draw, [p1, p2], 9, color + (255,))


def render(background, mono):
    layer = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw_steam(layer, mono)
    draw_omelet(layer, mono)
    if background is not None:
        base = Image.new("RGBA", (CANVAS, CANVAS), background + (255,))
        base.alpha_composite(layer)
        layer = base
    return layer.resize((SIZE, SIZE), Image.LANCZOS)


def save(image, relative, size=None):
    path = os.path.join(ROOT, relative)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out = image if size is None else image.resize((size, size), Image.LANCZOS)
    out.save(path, optimize=True)
    print(relative, out.size[0])


def main():
    icon = render((0, 0, 0), mono=False)
    fore = render(None, mono=False)
    minimal_icon = render((0, 0, 0), mono=True)
    minimal_fore = render(None, mono=True)

    save(icon, "assets/omelet_icon.png")
    save(fore, "assets/omelet.png")
    save(minimal_icon, "assets/omelet_minimal_icon.png", 512)
    save(minimal_fore, "assets/omelet_mono.png", 512)

    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for name, factor in densities.items():
        save(
            minimal_icon,
            f"android/app/src/main/res/mipmap-{name}/ic_launcher_minimal.png",
            int(48 * factor),
        )
        save(
            minimal_fore,
            f"android/app/src/main/res/drawable-{name}/ic_launcher_minimal_foreground.png",
            int(108 * factor),
        )
    save(minimal_icon, "ios/Runner/MinimalIcon@2x.png", 120)
    save(minimal_icon, "ios/Runner/MinimalIcon@3x.png", 180)


if __name__ == "__main__":
    sys.exit(main())
