import 'package:flutter/material.dart';

class MiuixPalette {
  final Color primary;
  final Color onPrimary;
  final Color primaryVariant;
  final Color disabledPrimary;
  final Color disabledOnPrimary;
  final Color secondary;
  final Color disabledSecondary;
  final Color disabledOnSecondary;
  final Color secondaryContainer;
  final Color onSecondaryVariant;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color summary;
  final Color actions;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerMid;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color dividerLine;
  final Color sliderTrack;
  final Color windowDimming;
  final Color pressedOverlay;
  final Color sectionTitle;

  const MiuixPalette._({
    required this.primary,
    required this.onPrimary,
    required this.primaryVariant,
    required this.disabledPrimary,
    required this.disabledOnPrimary,
    required this.secondary,
    required this.disabledSecondary,
    required this.disabledOnSecondary,
    required this.secondaryContainer,
    required this.onSecondaryVariant,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.summary,
    required this.actions,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerMid,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.dividerLine,
    required this.sliderTrack,
    required this.windowDimming,
    required this.pressedOverlay,
    required this.sectionTitle,
  });

  static const light = MiuixPalette._(
    primary: Color(0xFF3482FF),
    onPrimary: Color(0xFFFFFFFF),
    primaryVariant: Color(0xFF3482FF),
    disabledPrimary: Color(0xFFC2D9FF),
    disabledOnPrimary: Color(0xFFF3F8FF),
    secondary: Color(0xFFE6E6E6),
    disabledSecondary: Color(0xFFF0F0F0),
    disabledOnSecondary: Color(0xFFFCFCFC),
    secondaryContainer: Color(0xFFF0F0F0),
    onSecondaryVariant: Color(0xFF303030),
    tertiaryContainer: Color(0xFFEAF2FF),
    onTertiaryContainer: Color(0xFF3482FF),
    error: Color(0xFFE94634),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDF6F4),
    onErrorContainer: Color(0xFF410002),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F7F7),
    onSurface: Color(0xFF000000),
    summary: Color(0xFF666666),
    actions: Color(0xFF999999),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFBFBFB),
    surfaceContainerMid: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFFE8E8E8),
    outline: Color(0xFFD9D9D9),
    dividerLine: Color(0xFFE0E0E0),
    sliderTrack: Color(0x0F000000),
    windowDimming: Color(0x4D000000),
    pressedOverlay: Color(0x0F000000),
    sectionTitle: Color(0xFF8C93B0),
  );

  static const dark = MiuixPalette._(
    primary: Color(0xFF277AF7),
    onPrimary: Color(0xFFFFFFFF),
    primaryVariant: Color(0xFF0073DD),
    disabledPrimary: Color(0xFF253E64),
    disabledOnPrimary: Color(0xFF677993),
    secondary: Color(0xFF505050),
    disabledSecondary: Color(0xFF3F3F3F),
    disabledOnSecondary: Color(0xFF797979),
    secondaryContainer: Color(0xFF434343),
    onSecondaryVariant: Color(0xFFD9D9D9),
    tertiaryContainer: Color(0xFF2B3B54),
    onTertiaryContainer: Color(0xFF4788FF),
    error: Color(0xFFF12522),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFF2E0603),
    onErrorContainer: Color(0xFFFFDAD6),
    background: Color(0xFF242424),
    surface: Color(0xFF000000),
    onSurface: Color(0xFFF2F2F2),
    summary: Color(0xFF929292),
    actions: Color(0xFF7C7C7C),
    surfaceContainer: Color(0xFF242424),
    surfaceContainerLow: Color(0xFF121212),
    surfaceContainerMid: Color(0xFF1A1A1A),
    surfaceContainerHighest: Color(0xFF2D2D2D),
    outline: Color(0xFF404040),
    dividerLine: Color(0xFF393939),
    sliderTrack: Color(0x26FFFFFF),
    windowDimming: Color(0x99000000),
    pressedOverlay: Color(0x14FFFFFF),
    sectionTitle: Color(0xFF787E96),
  );

  static MiuixPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static MiuixPalette ofContext(BuildContext context) =>
      of(Theme.of(context).brightness);

  static Brightness _invert(Brightness brightness) =>
      brightness == Brightness.dark ? Brightness.light : Brightness.dark;

  ColorScheme toColorScheme(Brightness brightness, {ColorScheme? monet}) {
    final accent = monet?.primary ?? primary;
    final onAccent = monet?.onPrimary ?? onPrimary;
    final dark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );
    final bubble = dark
        ? (monet?.primaryContainer ?? tertiaryContainer)
        : Color.alphaBlend(accent.withValues(alpha: 0.2), background);
    return base.copyWith(
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: bubble,
      onPrimaryContainer: monet?.onPrimaryContainer ?? onTertiaryContainer,
      secondary: monet?.secondary ?? primaryVariant,
      onSecondary: monet?.onSecondary ?? onPrimary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryVariant,
      tertiary: monet?.tertiary ?? primaryVariant,
      onTertiary: monet?.onTertiary ?? onPrimary,
      tertiaryContainer: monet?.tertiaryContainer ?? tertiaryContainer,
      onTertiaryContainer: monet?.onTertiaryContainer ?? onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: summary,
      surfaceDim: surface,
      surfaceBright: surfaceContainerHighest,
      surfaceContainerLowest: dark ? surface : background,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainerMid,
      surfaceContainerHigh: surfaceContainer,
      surfaceContainerHighest: surfaceContainerHighest,
      outline: actions,
      outlineVariant: dividerLine,
      surfaceTint: Colors.transparent,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: MiuixPalette.of(_invert(brightness)).surfaceContainer,
      onInverseSurface: MiuixPalette.of(_invert(brightness)).onSurface,
    );
  }
}
