import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/config/app_miuix.dart';
import '../../core/config/app_shape.dart';
import 'glossy_pill.dart';
import 'miuix/miuix_surfaces.dart';

BorderRadius get _cardRadius =>
    AppMiuix.active ? MiuixShape.cardBorderRadius : AppShape.cardRadius;

double get _tileTitleSize => AppMiuix.active ? 17 : 16;

FontWeight get _tileTitleWeight => FontWeight.w500;

double get _tileIconSize => AppMiuix.active ? 24 : 22;

double get _tileIconFill => AppMiuix.active ? 1 : 0;

double get _tileSummarySize => AppMiuix.active ? 14 : 13;

Color _tileIconColor(ColorScheme cs) =>
    AppMiuix.active ? cs.onSurface : cs.onSurfaceVariant;

double get _tileInset => AppMiuix.active ? 16 : 20;

class SettingsPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const SettingsPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 20),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlossyPill(
      color: color ?? cs.surfaceContainerHigh,
      borderRadius: _cardRadius,
      padding: padding,
      depth: 6,
      child: child,
    );
  }
}

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlossyPill(
      color: cs.surfaceContainerHigh,
      borderRadius: _cardRadius,
      depth: 6,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1 && !AppMiuix.active)
              Padding(
                padding: const EdgeInsets.only(left: 58),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const SettingsToggleTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _tileInset,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: _tileIconColor(cs),
                    size: _tileIconSize,
                    weight: 400,
                    fill: _tileIconFill,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: _tileTitleSize,
                            fontWeight: _tileTitleWeight,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: _tileSummarySize,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(value: value, onChanged: onChanged),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsNavTile extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String label;
  final Color? tintColor;
  final VoidCallback? onTap;
  final bool isLast;

  const SettingsNavTile({
    super.key,
    this.icon,
    this.leading,
    required this.label,
    this.tintColor,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: isLast
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppShape.card),
              )
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _tileInset, vertical: 17),
          child: Row(
            children: [
              leading ??
                  Icon(
                    icon,
                    color: tintColor ?? _tileIconColor(cs),
                    size: _tileIconSize,
                    weight: 400,
                    fill: _tileIconFill,
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: tintColor ?? cs.onSurface,
                    fontSize: _tileTitleSize,
                    fontWeight: _tileTitleWeight,
                  ),
                ),
              ),
              Icon(
                Symbols.chevron_right,
                color: cs.outline,
                size: AppMiuix.active ? 24 : 20,
                weight: AppMiuix.active ? 500 : 400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
