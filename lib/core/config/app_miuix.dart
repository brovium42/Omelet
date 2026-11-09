import 'package:flutter/foundation.dart';

import 'app_chat_chrome.dart';
import 'app_composer_background.dart';
import 'app_nav_pill_style.dart';
import 'app_visual_style.dart';
import 'persisted_setting.dart';

class AppMiuix {
  static const double maxBlurRadius = 150;
  static const double defaultBlurRadius = 20;
  static const double maxNoise = 0.03;
  static const double defaultNoise = 0.0045;
  static const double defaultGlassBlurRadius = 20;
  static const double defaultGlassHighlight = 1;
  static const double maxRefraction = 40;

  static final monet = _flag('miuix_monet', false);
  static final smoothCorners = _flag('miuix_smooth_corners', true);
  static final blurEnabled = _flag('miuix_blur_enabled', true);
  static final blurRadius = _amount(
    'miuix_blur_radius',
    defaultBlurRadius,
    maxBlurRadius,
  );
  static final blurNoise = _amount('miuix_blur_noise', defaultNoise, maxNoise);
  static final glassEnabled = _flag('miuix_glass_enabled', false);
  static final glassBlurRadius = _amount(
    'miuix_glass_blur_radius',
    defaultGlassBlurRadius,
    maxBlurRadius,
  );
  static final glassHighlight = _amount(
    'miuix_glass_highlight',
    defaultGlassHighlight,
    1,
  );
  static final glassRefraction = _amount('miuix_glass_refraction', 0, 1);

  static final Listenable listenable = Listenable.merge([
    AppVisualStyle.current,
    monet.current,
    smoothCorners.current,
    blurEnabled.current,
    blurRadius.current,
    blurNoise.current,
    glassEnabled.current,
    glassBlurRadius.current,
    glassHighlight.current,
    glassRefraction.current,
  ]);

  static final ValueListenable<VisualStyle> visualStyle =
      _VisualStyleWithMiuix();

  static bool get active => AppVisualStyle.current.value == VisualStyle.miuix;

  static bool get glassActive => active && glassEnabled.current.value;

  static bool get blurActive => active && blurEnabled.current.value;

  static double sigmaForRadius(double radius) =>
      radius <= 0 ? 0 : radius * 0.57735 + 0.5;

  static double get blurSigma =>
      blurEnabled.current.value ? sigmaForRadius(blurRadius.current.value) : 0;

  static double get glassSigma => sigmaForRadius(glassBlurRadius.current.value);

  static double get refractionStrength =>
      glassRefraction.current.value * maxRefraction;

  static Future<void> load() => Future.wait<Object>([
    monet.load(),
    smoothCorners.load(),
    blurEnabled.load(),
    blurRadius.load(),
    blurNoise.load(),
    glassEnabled.load(),
    glassBlurRadius.load(),
    glassHighlight.load(),
    glassRefraction.load(),
  ]);

  static Future<void> syncMaterials() async {
    if (!active) return;
    final glass = glassEnabled.current.value;
    final blur = blurEnabled.current.value;
    await AppComposerBackground.save(
      glass
          ? ComposerBackground.liquidGlass
          : blur
          ? ComposerBackground.frostBlur
          : ComposerBackground.standard,
    );
    await AppChatChrome.save(
      glass
          ? ChatChromeStyle.liquidGlass
          : blur
          ? ChatChromeStyle.blur
          : ChatChromeStyle.color,
    );
    if (AppNavPillStyle.current.value != NavPillStyle.auto) {
      await AppNavPillStyle.save(NavPillStyle.auto);
    }
  }

  static PersistedSetting<bool> _flag(String key, bool fallback) =>
      PersistedSetting<bool>(
        prefKey: key,
        defaultValue: fallback,
        read: (prefs, k) => prefs.getBool(k),
        write: (prefs, k, value) => prefs.setBool(k, value),
      );

  static PersistedSetting<double> _amount(
    String key,
    double fallback,
    double max,
  ) => PersistedSetting<double>(
    prefKey: key,
    defaultValue: fallback,
    read: (prefs, k) => prefs.getDouble(k),
    write: (prefs, k, value) => prefs.setDouble(k, value),
    sanitize: (value) => value.isFinite ? value.clamp(0.0, max) : fallback,
  );
}

class _VisualStyleWithMiuix implements ValueListenable<VisualStyle> {
  @override
  VisualStyle get value => AppVisualStyle.current.value;

  @override
  void addListener(VoidCallback listener) =>
      AppMiuix.listenable.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      AppMiuix.listenable.removeListener(listener);
}
