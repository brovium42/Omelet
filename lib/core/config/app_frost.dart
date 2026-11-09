import 'package:flutter/material.dart';

import 'app_miuix.dart';

class AppFrost {
  static const double baseSigma = 34;
  static const double basePanelSigma = 24;
  static const double overlaySigma = 18;
  static const double mediaBackdropSigma = 30;
  static const double glassAlpha = 0.28;
  static const double blurPanelAlpha = 0.55;
  static const double scrimAlpha = 0.4;
  static const double miuixBlurAlpha = 0.62;

  static double get sigma => AppMiuix.active ? AppMiuix.blurSigma : baseSigma;

  static double get panelSigma =>
      AppMiuix.active ? AppMiuix.blurSigma : basePanelSigma;

  static Color glassTint(ColorScheme cs, [double alpha = glassAlpha]) {
    if (AppMiuix.active) return miuixTint(cs);
    return cs.surfaceContainerHigh.withValues(alpha: alpha);
  }

  static Color miuixTint(ColorScheme cs) => cs.surfaceContainerHigh.withValues(
    alpha: AppMiuix.blurEnabled.current.value ? miuixBlurAlpha : 1,
  );

  static Color blurPanelTint(ColorScheme cs) => glassTint(cs, blurPanelAlpha);

  static Color scrim([double alpha = scrimAlpha]) =>
      Colors.black.withValues(alpha: alpha);

  static BorderSide hairline(ColorScheme cs) =>
      BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4), width: 0.5);
}
