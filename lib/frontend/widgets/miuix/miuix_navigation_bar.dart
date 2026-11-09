import 'package:flutter/material.dart';

import '../../../core/config/app_miuix.dart';
import '../../../core/config/app_miuix_colors.dart';
import '../sliding_pill_nav.dart';
import 'miuix_surfaces.dart';

class MiuixNavigationBar extends StatelessWidget {
  static const double itemHeight = 64;
  static const double iconSize = 26;
  static const double labelSize = 12;
  static const double unselectedAlpha = 0.4;

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

  static double heightOf(BuildContext context) =>
      itemHeight + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppMiuix.listenable,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        final palette = MiuixPalette.ofContext(context);
        final bottom = MediaQuery.viewPaddingOf(context).bottom;
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 0.5, color: palette.dividerLine),
            SizedBox(
              height: itemHeight,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _MiuixNavItem(
                        item: items[i],
                        selected: i == selectedIndex,
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
            ),
            SizedBox(height: bottom),
          ],
        );
        if (AppMiuix.glassEnabled.current.value) {
          return MiuixGlassSurface(
            borderRadius: BorderRadius.zero,
            tint: cs.surface.withValues(alpha: 0.55),
            shadow: false,
            edgeHighlight: false,
            child: content,
          );
        }
        if (AppMiuix.blurEnabled.current.value) {
          return MiuixBlurSurface(
            tint: cs.surface.withValues(alpha: 0.78),
            backdropKey: backdropKey,
            child: content,
          );
        }
        return ColoredBox(color: cs.surface, child: content);
      },
    );
  }
}

class _MiuixNavItem extends StatelessWidget {
  final PillNavItem item;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final void Function(Offset globalPosition)? onLongPress;

  const _MiuixNavItem({
    required this.item,
    required this.selected,
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: onLongPress == null
          ? null
          : (details) => onLongPress!(details.globalPosition),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1.0 : MiuixNavigationBar.unselectedAlpha),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (context, alpha, _) {
          final tint = color.withValues(alpha: alpha);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: MiuixNavigationBar.iconSize,
                color: tint,
                weight: 300,
                fill: 0,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tint,
                  fontSize: MiuixNavigationBar.labelSize,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
