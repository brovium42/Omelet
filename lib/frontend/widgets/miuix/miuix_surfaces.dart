import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/config/app_miuix.dart';
import '../liquid_glass.dart';

class MiuixShape {
  static const double cardRadius = 16;
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(cardRadius),
  );

  static bool get smooth => AppMiuix.smoothCorners.current.value;

  static OutlinedBorder border(
    BorderRadius radius, {
    BorderSide side = BorderSide.none,
  }) => smooth
      ? RoundedSuperellipseBorder(borderRadius: radius, side: side)
      : RoundedRectangleBorder(borderRadius: radius, side: side);

  static Widget clip({required BorderRadius radius, required Widget child}) =>
      smooth
      ? ClipRSuperellipse(borderRadius: radius, child: child)
      : ClipRRect(borderRadius: radius, child: child);
}

class MiuixNoise {
  static const int _size = 128;
  static final ValueNotifier<ui.Image?> image = ValueNotifier(null);
  static bool _requested = false;

  static void ensure() {
    if (_requested) return;
    _requested = true;
    final random = math.Random(42);
    final pixels = Uint8List(_size * _size * 4);
    for (var i = 0; i < pixels.length; i += 4) {
      final value = random.nextInt(256);
      pixels[i] = value;
      pixels[i + 1] = value;
      pixels[i + 2] = value;
      pixels[i + 3] = 255;
    }
    ui.decodeImageFromPixels(
      pixels,
      _size,
      _size,
      ui.PixelFormat.rgba8888,
      (decoded) => image.value = decoded,
    );
  }

  static double opacityFor(double coefficient) =>
      (coefficient / AppMiuix.maxNoise).clamp(0.0, 1.0) * 0.45;
}

class MiuixNoiseLayer extends StatelessWidget {
  final double coefficient;

  const MiuixNoiseLayer({super.key, required this.coefficient});

  @override
  Widget build(BuildContext context) {
    if (coefficient <= 0) return const SizedBox.expand();
    MiuixNoise.ensure();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return IgnorePointer(
      child: ValueListenableBuilder<ui.Image?>(
        valueListenable: MiuixNoise.image,
        builder: (context, noise, _) {
          if (noise == null) return const SizedBox.expand();
          return CustomPaint(
            size: Size.infinite,
            painter: _NoisePainter(
              image: noise,
              opacity: MiuixNoise.opacityFor(coefficient),
              devicePixelRatio: dpr,
            ),
          );
        },
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final ui.Image image;
  final double opacity;
  final double devicePixelRatio;

  const _NoisePainter({
    required this.image,
    required this.opacity,
    required this.devicePixelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = 1 / devicePixelRatio;
    final matrix = Float64List(16)
      ..[0] = scale
      ..[5] = scale
      ..[10] = 1
      ..[15] = 1;
    final paint = Paint()
      ..shader = ImageShader(
        image,
        TileMode.repeated,
        TileMode.repeated,
        matrix,
      )
      ..color = Colors.black.withValues(alpha: opacity)
      ..blendMode = BlendMode.overlay;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_NoisePainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.opacity != opacity ||
      oldDelegate.devicePixelRatio != devicePixelRatio;
}

class MiuixBlurSurface extends StatelessWidget {
  final BorderRadius borderRadius;
  final Color tint;
  final BackdropKey? backdropKey;
  final Widget child;

  const MiuixBlurSurface({
    super.key,
    this.borderRadius = BorderRadius.zero,
    required this.tint,
    this.backdropKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppMiuix.listenable,
      builder: (context, _) {
        final sigma = AppMiuix.blurSigma;
        final noise = AppMiuix.blurNoise.current.value;
        final body = Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: tint)),
            ),
            if (sigma > 0 && noise > 0)
              Positioned.fill(child: MiuixNoiseLayer(coefficient: noise)),
            child,
          ],
        );
        return MiuixShape.clip(
          radius: borderRadius,
          child: sigma > 0
              ? BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: sigma,
                    sigmaY: sigma,
                    tileMode: TileMode.mirror,
                  ),
                  backdropGroupKey: backdropKey,
                  child: body,
                )
              : body,
        );
      },
    );
  }
}

class MiuixGlassSurface extends StatelessWidget {
  final BorderRadius borderRadius;
  final Color tint;
  final bool shadow;
  final Widget child;

  const MiuixGlassSurface({
    super.key,
    required this.borderRadius,
    this.tint = Colors.transparent,
    this.shadow = true,
    required this.child,
  });

  static Color materialTint(Brightness brightness) =>
      brightness == Brightness.dark
      ? const Color(0x59262626)
      : const Color(0x4DFFFFFF);

  static List<BoxShadow> shadows(Brightness brightness) => [
    BoxShadow(
      color: Colors.black.withValues(
        alpha: brightness == Brightness.dark ? 0.32 : 0.1,
      ),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppMiuix.listenable,
      builder: (context, _) {
        final brightness = Theme.of(context).brightness;
        final layer = tint.a > 0.01 ? tint : materialTint(brightness);
        final highlight = AppMiuix.glassHighlight.current.value;
        final sigma = AppMiuix.glassSigma;
        final refraction = AppMiuix.refractionStrength;
        final noise = AppMiuix.blurNoise.current.value;
        final smooth = MiuixShape.smooth;

        final content = Stack(
          fit: StackFit.passthrough,
          children: [
            if (noise > 0)
              Positioned.fill(child: MiuixNoiseLayer(coefficient: noise)),
            child,
            if (highlight > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GlassHighlightPainter(
                      borderRadius: borderRadius,
                      intensity: highlight,
                      dark: brightness == Brightness.dark,
                      smooth: smooth,
                    ),
                  ),
                ),
              ),
          ],
        );

        final Widget glass;
        if (refraction > 0 && LiquidGlass.hasShader) {
          glass = LiquidGlassRefraction(
            borderRadius: borderRadius,
            tint: layer,
            blurSigma: sigma,
            refraction: refraction,
            specular: highlight * 0.35,
            child: content,
          );
        } else {
          final tinted = DecoratedBox(
            decoration: BoxDecoration(color: layer),
            child: content,
          );
          glass = MiuixShape.clip(
            radius: borderRadius,
            child: sigma > 0
                ? BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: sigma,
                      sigmaY: sigma,
                      tileMode: TileMode.mirror,
                    ),
                    child: tinted,
                  )
                : tinted,
          );
        }

        if (!shadow) return glass;
        return DecoratedBox(
          decoration: ShapeDecoration(
            shape: MiuixShape.border(borderRadius),
            shadows: shadows(brightness),
          ),
          child: glass,
        );
      },
    );
  }
}

class _GlassHighlightPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final double intensity;
  final bool dark;
  final bool smooth;

  const _GlassHighlightPainter({
    required this.borderRadius,
    required this.intensity,
    required this.dark,
    required this.smooth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || intensity <= 0) return;
    final rect = Offset.zero & size;
    final shape = smooth
        ? RoundedSuperellipseBorder(borderRadius: borderRadius)
        : RoundedRectangleBorder(borderRadius: borderRadius);
    final path = shape.getOuterPath(rect);
    final peak = (dark ? 0.34 : 0.8) * intensity;
    final shader = LinearGradient(
      begin: const Alignment(-0.6, -1),
      end: const Alignment(0.6, 1),
      colors: [
        Colors.white.withValues(alpha: peak),
        Colors.white.withValues(alpha: peak * 0.16),
        Colors.white.withValues(alpha: peak * 0.06),
        Colors.white.withValues(alpha: peak * 0.5),
      ],
      stops: const [0, 0.38, 0.62, 1],
    ).createShader(rect);

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..shader = shader
        ..color = Colors.white.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, dark ? 1.7 : 2.8)
        ..blendMode = BlendMode.plus,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = shader,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassHighlightPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.intensity != intensity ||
      oldDelegate.dark != dark ||
      oldDelegate.smooth != smooth;
}
