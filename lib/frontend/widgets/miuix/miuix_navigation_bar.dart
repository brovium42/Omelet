import 'package:flutter/material.dart';

import '../../../core/config/app_miuix.dart';
import '../sliding_pill_nav.dart';
import 'miuix_surfaces.dart';

class MiuixNavigationBar extends StatelessWidget {
  static const double barHeight = 64;
  static const double barPadding = 4;
  static const double indicatorHeight = barHeight - barPadding * 2;
  static const double sideMargin = 28;
  static const double floatingMargin = 28;
  static const double insetGap = 8;
  static const double iconSize = 24;
  static const double labelSize = 11;
  static const BorderRadius _capsule = BorderRadius.all(
    Radius.circular(barHeight / 2),
  );

  final List<PillNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final void Function(int index, Offset globalPosition)? onItemLongPress;
  final BackdropKey? backdropKey;

  const MiuixNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.onItemLongPress,
    this.backdropKey,
  });

  static double bottomMargin(double systemInset) =>
      systemInset > 0 ? insetGap + systemInset : floatingMargin;

  static double occupiedHeight(double systemInset) =>
      barHeight + bottomMargin(systemInset);

  @override
  Widget build(BuildContext context) {
    final bottom = bottomMargin(MediaQuery.viewPaddingOf(context).bottom);
    return Padding(
      padding: EdgeInsets.fromLTRB(sideMargin, 0, sideMargin, bottom),
      child: ListenableBuilder(
        listenable: AppMiuix.listenable,
        builder: (context, _) => _buildBar(context),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    final glass = AppMiuix.glassEnabled.current.value;
    final blur = AppMiuix.blurEnabled.current.value;
    final translucent = glass || blur;
    final container = translucent
        ? cs.surfaceContainerHigh.withValues(alpha: 0.4)
        : cs.surfaceContainerHigh;
    final indicator = translucent
        ? (dark ? Colors.white : Colors.black).withValues(alpha: 0.1)
        : cs.primary.withValues(alpha: 0.15);

    final content = SizedBox(
      height: barHeight,
      child: Padding(
        padding: const EdgeInsets.all(barPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  left: itemWidth * selectedIndex,
                  top: 0,
                  width: itemWidth,
                  height: indicatorHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: indicator,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(indicatorHeight / 2),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      SizedBox(
                        width: itemWidth,
                        child: _MiuixNavItem(
                          item: items[i],
                          selected: i == selectedIndex,
                          selectedColor: cs.primary,
                          color: cs.onSurface,
                          onTap: () => onTap(i),
                          onLongPress:
                              onItemLongPress == null || !items[i].longPressable
                              ? null
                              : (position) => onItemLongPress!(i, position),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

    final Widget surface;
    if (glass) {
      surface = MiuixGlassSurface(
        borderRadius: _capsule,
        tint: container,
        shadow: false,
        child: content,
      );
    } else if (blur) {
      surface = MiuixBlurSurface(
        borderRadius: _capsule,
        tint: container,
        backdropKey: backdropKey,
        child: content,
      );
    } else {
      surface = Material(
        color: container,
        shape: MiuixShape.border(_capsule),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: MiuixShape.border(_capsule),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.2 : 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: surface,
    );
  }
}

class _MiuixNavItem extends StatefulWidget {
  final PillNavItem item;
  final bool selected;
  final Color selectedColor;
  final Color color;
  final VoidCallback onTap;
  final void Function(Offset globalPosition)? onLongPress;

  const _MiuixNavItem({
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_MiuixNavItem> createState() => _MiuixNavItemState();
}

class _MiuixNavItemState extends State<_MiuixNavItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onLongPressStart: widget.onLongPress == null
          ? null
          : (details) => widget.onLongPress!(details.globalPosition),
      child: AnimatedScale(
        scale: _pressed ? 1.12 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(
            end: widget.selected ? widget.selectedColor : widget.color,
          ),
          duration: const Duration(milliseconds: 200),
          builder: (context, tint, _) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.item.icon,
                size: MiuixNavigationBar.iconSize,
                color: tint,
                fill: 1,
              ),
              const SizedBox(height: 1),
              Text(
                widget.item.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: tint,
                  fontSize: MiuixNavigationBar.labelSize,
                  height: 14 / 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
