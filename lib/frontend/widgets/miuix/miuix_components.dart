import 'package:flutter/material.dart';

import '../../../core/config/app_miuix_colors.dart';
import '../../../core/utils/haptics.dart';
import 'miuix_surfaces.dart';

class MiuixSmallTitle extends StatelessWidget {
  final String text;

  const MiuixSmallTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Text(
        text,
        style: TextStyle(
          color: MiuixPalette.ofContext(context).sectionTitle,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MiuixCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const MiuixCard({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: MiuixShape.border(MiuixShape.cardBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class MiuixBasicTile extends StatelessWidget {
  final String title;
  final String? summary;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? titleColor;

  const MiuixBasicTile({
    super.key,
    required this.title,
    this.summary,
    this.trailing,
    this.bottom,
    this.onTap,
    this.enabled = true,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final palette = MiuixPalette.ofContext(context);
    Widget content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor ?? cs.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (summary != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          summary!,
                          style: TextStyle(
                            color: palette.summary,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
            if (bottom != null) ...[const SizedBox(height: 12), bottom!],
          ],
        ),
      ),
    );
    if (onTap != null) {
      content = InkWell(onTap: enabled ? onTap : null, child: content);
    }
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.4,
      child: IgnorePointer(ignoring: !enabled, child: content),
    );
  }
}

class MiuixSwitchTile extends StatelessWidget {
  final String title;
  final String? summary;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const MiuixSwitchTile({
    super.key,
    required this.title,
    this.summary,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  void _toggle(bool next) {
    Haptics.selection();
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return MiuixBasicTile(
      title: title,
      summary: summary,
      enabled: enabled,
      onTap: () => _toggle(!value),
      trailing: Switch(value: value, onChanged: _toggle),
    );
  }
}

class MiuixSliderTile extends StatelessWidget {
  final String title;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;
  final bool enabled;

  const MiuixSliderTile({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.value,
    this.min = 0,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return MiuixBasicTile(
      title: title,
      enabled: enabled,
      trailing: Text(
        valueLabel,
        style: TextStyle(
          color: MiuixPalette.ofContext(context).summary,
          fontSize: 14,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      bottom: MiuixSlider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}

class MiuixSlider extends StatefulWidget {
  static const double height = 28;

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const MiuixSlider({
    super.key,
    required this.value,
    this.min = 0,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<MiuixSlider> createState() => _MiuixSliderState();
}

class _MiuixSliderState extends State<MiuixSlider> {
  double _lastEmitted = 0;
  bool _atEdge = false;

  double get _range => widget.max - widget.min;

  double get _fraction =>
      _range <= 0 ? 0 : ((widget.value - widget.min) / _range).clamp(0.0, 1.0);

  void _update(Offset local, double width) {
    if (width <= 0) return;
    final fraction = (local.dx / width).clamp(0.0, 1.0);
    final edge = fraction == 0 || fraction == 1;
    if (edge && !_atEdge) Haptics.selection();
    _atEdge = edge;
    _lastEmitted = widget.min + fraction * _range;
    widget.onChanged(_lastEmitted);
  }

  void _finish() {
    widget.onChangeEnd?.call(_lastEmitted);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final palette = MiuixPalette.ofContext(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _update(d.localPosition, width),
          onTapUp: (_) => _finish(),
          onHorizontalDragStart: (d) => _update(d.localPosition, width),
          onHorizontalDragUpdate: (d) => _update(d.localPosition, width),
          onHorizontalDragEnd: (_) => _finish(),
          child: SizedBox(
            width: width,
            height: MiuixSlider.height,
            child: CustomPaint(
              painter: _SliderPainter(
                fraction: _fraction,
                track: palette.sliderTrack,
                fill: cs.primary,
                smooth: MiuixShape.smooth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double fraction;
  final Color track;
  final Color fill;
  final bool smooth;

  const _SliderPainter({
    required this.fraction,
    required this.track,
    required this.fill,
    required this.smooth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = BorderRadius.circular(size.height / 2);
    final rect = Offset.zero & size;
    final shape = smooth
        ? RoundedSuperellipseBorder(borderRadius: radius)
        : RoundedRectangleBorder(borderRadius: radius);
    final trackPath = shape.getOuterPath(rect);
    canvas.save();
    canvas.clipPath(trackPath);
    canvas.drawPath(trackPath, Paint()..color = track);
    final fillWidth = size.width * fraction;
    if (fillWidth > 0) {
      final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
      canvas.drawPath(shape.getOuterPath(fillRect), Paint()..color = fill);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill ||
      oldDelegate.smooth != smooth;
}
