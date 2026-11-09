import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/config/app_frost.dart';
import '../../../core/config/app_miuix.dart';
import '../../../core/config/app_visual_style.dart';
import '../../../core/config/persisted_setting.dart';
import '../../../core/config/visual_style_controller.dart';
import '../../../core/utils/haptics.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/connection_status.dart';
import '../../widgets/liquid_glass.dart';
import '../../widgets/miuix/miuix_components.dart';
import '../../widgets/miuix/miuix_surfaces.dart';

class MiuixSettingsScreen extends StatefulWidget {
  const MiuixSettingsScreen({super.key});

  @override
  State<MiuixSettingsScreen> createState() => _MiuixSettingsScreenState();
}

class _MiuixSettingsScreenState extends State<MiuixSettingsScreen> {
  void _setTheme(bool enabled) {
    VisualStyleController.apply(
      enabled ? VisualStyle.miuix : VisualStyle.materialYou,
    );
  }

  Future<void> _setMaterialFlag(PersistedSetting<bool> flag, bool value) async {
    await flag.save(value);
    await AppMiuix.syncMaterials();
  }

  void _preview(PersistedSetting<double> setting, double value) {
    setting.current.value = value;
  }

  void _commit(PersistedSetting<double> setting, double value) {
    setting.save(value);
  }

  void _commitRefraction(double value) {
    AppMiuix.glassRefraction.save(value);
    if (value <= 0) return;
    LiquidGlass.ensureShader().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _reset() async {
    Haptics.tap();
    await Future.wait<void>([
      AppMiuix.monet.save(false),
      AppMiuix.smoothCorners.save(true),
      AppMiuix.blurEnabled.save(true),
      AppMiuix.blurRadius.save(AppMiuix.defaultBlurRadius),
      AppMiuix.blurNoise.save(AppMiuix.defaultNoise),
      AppMiuix.glassEnabled.save(false),
      AppMiuix.glassBlurRadius.save(AppMiuix.defaultGlassBlurRadius),
      AppMiuix.glassHighlight.save(AppMiuix.defaultGlassHighlight),
      AppMiuix.glassRefraction.save(0),
    ]);
    await AppMiuix.syncMaterials();
  }

  String _percent(double value, double max) =>
      '${(value / max * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: ConnectionTitleBar(
        titleText: l10n.miuixSettingsTitle,
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: AppMiuix.listenable,
          builder: (context, _) => ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 120),
            children: [
              ..._themeSection(l10n),
              MiuixSmallTitle(l10n.miuixPreviewTitle),
              const MiuixCard(
                padding: EdgeInsets.all(12),
                children: [_MiuixPreview()],
              ),
              ..._appearanceSection(l10n),
              ..._blurSection(l10n),
              ..._glassSection(l10n),
              const SizedBox(height: 16),
              MiuixCard(
                children: [
                  MiuixBasicTile(
                    title: l10n.miuixReset,
                    titleColor: cs.error,
                    onTap: _reset,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _themeSection(AppLocalizations l10n) {
    final active = AppMiuix.active;
    return [
      const SizedBox(height: 8),
      MiuixCard(
        children: [
          MiuixSwitchTile(
            title: l10n.miuixEnableTitle,
            summary: active ? l10n.miuixEnableSubtitle : l10n.miuixInactiveHint,
            value: active,
            onChanged: _setTheme,
          ),
        ],
      ),
    ];
  }

  List<Widget> _appearanceSection(AppLocalizations l10n) => [
    MiuixSmallTitle(l10n.miuixSectionAppearance),
    MiuixCard(
      children: [
        MiuixSwitchTile(
          title: l10n.miuixMonetTitle,
          summary: l10n.miuixMonetSubtitle,
          value: AppMiuix.monet.current.value,
          onChanged: AppMiuix.monet.save,
        ),
        MiuixSwitchTile(
          title: l10n.miuixSmoothCornersTitle,
          summary: l10n.miuixSmoothCornersSubtitle,
          value: AppMiuix.smoothCorners.current.value,
          onChanged: AppMiuix.smoothCorners.save,
        ),
      ],
    ),
  ];

  List<Widget> _blurSection(AppLocalizations l10n) {
    final enabled = AppMiuix.blurEnabled.current.value;
    final radius = AppMiuix.blurRadius.current.value;
    final noise = AppMiuix.blurNoise.current.value;
    return [
      MiuixSmallTitle(l10n.miuixSectionBlur),
      MiuixCard(
        children: [
          MiuixSwitchTile(
            title: l10n.miuixBlurTitle,
            summary: l10n.miuixBlurSubtitle,
            value: enabled,
            onChanged: (v) => _setMaterialFlag(AppMiuix.blurEnabled, v),
          ),
          MiuixSliderTile(
            title: l10n.miuixBlurRadius,
            valueLabel: '${radius.round()} dp',
            value: radius,
            max: AppMiuix.maxBlurRadius,
            enabled: enabled,
            onChanged: (v) => _preview(AppMiuix.blurRadius, v),
            onChangeEnd: (v) => _commit(AppMiuix.blurRadius, v),
          ),
          MiuixSliderTile(
            title: l10n.miuixBlurNoise,
            valueLabel: _percent(noise, AppMiuix.maxNoise),
            value: noise,
            max: AppMiuix.maxNoise,
            enabled: enabled,
            onChanged: (v) => _preview(AppMiuix.blurNoise, v),
            onChangeEnd: (v) => _commit(AppMiuix.blurNoise, v),
          ),
        ],
      ),
    ];
  }

  List<Widget> _glassSection(AppLocalizations l10n) {
    final enabled = AppMiuix.glassEnabled.current.value;
    final radius = AppMiuix.glassBlurRadius.current.value;
    final highlight = AppMiuix.glassHighlight.current.value;
    final refraction = AppMiuix.glassRefraction.current.value;
    final refractionSupported = LiquidGlass.shaderFiltersSupported;
    return [
      MiuixSmallTitle(l10n.miuixSectionGlass),
      MiuixCard(
        children: [
          MiuixSwitchTile(
            title: l10n.miuixGlassTitle,
            summary: l10n.miuixGlassSubtitle,
            value: enabled,
            onChanged: (v) => _setMaterialFlag(AppMiuix.glassEnabled, v),
          ),
          MiuixSliderTile(
            title: l10n.miuixGlassBlur,
            valueLabel: '${radius.round()} dp',
            value: radius,
            max: AppMiuix.maxBlurRadius,
            enabled: enabled,
            onChanged: (v) => _preview(AppMiuix.glassBlurRadius, v),
            onChangeEnd: (v) => _commit(AppMiuix.glassBlurRadius, v),
          ),
          MiuixSliderTile(
            title: l10n.miuixGlassHighlight,
            valueLabel: _percent(highlight, 1),
            value: highlight,
            max: 1,
            enabled: enabled,
            onChanged: (v) => _preview(AppMiuix.glassHighlight, v),
            onChangeEnd: (v) => _commit(AppMiuix.glassHighlight, v),
          ),
          if (refractionSupported)
            MiuixSliderTile(
              title: l10n.miuixGlassRefraction,
              valueLabel: _percent(refraction, 1),
              value: refraction,
              max: 1,
              enabled: enabled,
              onChanged: (v) => _preview(AppMiuix.glassRefraction, v),
              onChangeEnd: _commitRefraction,
            )
          else
            MiuixBasicTile(
              title: l10n.miuixGlassRefraction,
              summary: l10n.miuixGlassRefractionUnavailable,
              enabled: false,
            ),
        ],
      ),
    ];
  }
}

class _MiuixPreview extends StatelessWidget {
  const _MiuixPreview();

  static const double _height = 200;
  static const BorderRadius _pillRadius = BorderRadius.all(Radius.circular(26));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final glass = AppMiuix.glassEnabled.current.value;
    return SizedBox(
      height: _height,
      child: MiuixShape.clip(
        radius: const BorderRadius.all(Radius.circular(12)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _PreviewBackdrop(),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 56,
              child: MiuixBlurSurface(
                tint: AppFrost.miuixTint(cs),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Symbols.arrow_back, color: cs.onSurface, size: 22),
                      const SizedBox(width: 16),
                      Text(
                        'Omelet',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: 14,
              height: 52,
              child: glass
                  ? MiuixGlassSurface(
                      borderRadius: _pillRadius,
                      child: const _PreviewNavIcons(),
                    )
                  : MiuixBlurSurface(
                      borderRadius: _pillRadius,
                      tint: AppFrost.miuixTint(cs),
                      child: const _PreviewNavIcons(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewNavIcons extends StatelessWidget {
  const _PreviewNavIcons();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Symbols.chat, color: cs.primary, size: 24, fill: 1),
        Icon(Symbols.call, color: cs.onSurface, size: 24),
        Icon(Symbols.person, color: cs.onSurface, size: 24),
      ],
    );
  }
}

class _PreviewBackdrop extends StatelessWidget {
  const _PreviewBackdrop();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: cs.surface),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            top: 10,
            child: _blob(140, const Color(0xFF3482FF)),
          ),
          Positioned(
            right: -20,
            top: 30,
            child: _blob(120, const Color(0xFFFF8A3D)),
          ),
          Positioned(
            left: 90,
            bottom: -40,
            child: _blob(150, const Color(0xFF2EC27E)),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 28, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _bubble(
                    cs.surfaceContainerHighest,
                    150,
                    Alignment.centerLeft,
                  ),
                  const SizedBox(height: 8),
                  _bubble(cs.primaryContainer, 120, Alignment.centerRight),
                  const SizedBox(height: 8),
                  _bubble(
                    cs.surfaceContainerHighest,
                    190,
                    Alignment.centerLeft,
                  ),
                  const SizedBox(height: 8),
                  _bubble(cs.primaryContainer, 90, Alignment.centerRight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.85),
    ),
  );

  Widget _bubble(Color color, double width, Alignment alignment) => Align(
    alignment: alignment,
    child: Container(
      width: width,
      height: 30,
      decoration: ShapeDecoration(
        color: color,
        shape: MiuixShape.border(const BorderRadius.all(Radius.circular(15))),
      ),
    ),
  );
}
