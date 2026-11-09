import 'package:flutter/material.dart';

import '../../../core/config/app_miuix_colors.dart';
import 'miuix_surfaces.dart';

class MiuixThemeData {
  static const double dialogRadius = 32;
  static const double buttonRadius = 16;
  static const double buttonMinHeight = 50;

  static ThemeData apply(ThemeData theme) {
    final cs = theme.colorScheme;
    final palette = MiuixPalette.of(cs.brightness);
    return theme.copyWith(
      scaffoldBackgroundColor: cs.surface,
      canvasColor: cs.surface,
      splashFactory: NoSplash.splashFactory,
      highlightColor: palette.pressedOverlay,
      hoverColor: palette.pressedOverlay,
      dividerColor: palette.dividerLine,
      dividerTheme: theme.dividerTheme.copyWith(
        color: palette.dividerLine,
        thickness: 0.5,
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: theme.cardTheme.copyWith(
        color: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: MiuixShape.border(MiuixShape.cardBorderRadius),
      ),
      dialogTheme: theme.dialogTheme.copyWith(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        barrierColor: palette.windowDimming,
        shape: MiuixShape.border(
          const BorderRadius.all(Radius.circular(dialogRadius)),
        ),
      ),
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: palette.windowDimming,
        shape: MiuixShape.border(
          const BorderRadius.vertical(top: Radius.circular(dialogRadius)),
        ),
      ),
      popupMenuTheme: theme.popupMenuTheme.copyWith(
        color: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: MiuixShape.border(MiuixShape.cardBorderRadius),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, buttonMinHeight),
          elevation: 0,
          shape: MiuixShape.border(
            const BorderRadius.all(Radius.circular(buttonRadius)),
          ),
        ),
      ),
      checkboxTheme: theme.checkboxTheme.copyWith(
        shape: const CircleBorder(),
        side: BorderSide.none,
        checkColor: const WidgetStatePropertyAll(Colors.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          if (states.contains(WidgetState.disabled)) {
            return selected
                ? palette.disabledPrimary
                : palette.disabledSecondary;
          }
          return selected ? cs.primary : palette.secondary;
        }),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      segmentedButtonTheme: theme.segmentedButtonTheme.copyWith(
        style: _segmentStyle(cs, palette),
      ),
      switchTheme: theme.switchTheme.copyWith(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (!states.contains(WidgetState.disabled)) return Colors.white;
          return states.contains(WidgetState.selected)
              ? palette.disabledOnPrimary
              : palette.disabledOnSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          if (states.contains(WidgetState.disabled)) {
            return selected
                ? palette.disabledPrimary
                : palette.disabledSecondary;
          }
          return selected ? cs.primary : palette.secondary;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackOutlineWidth: const WidgetStatePropertyAll(0),
        thumbIcon: const WidgetStatePropertyAll(Icon(null)),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  static ButtonStyle _segmentStyle(ColorScheme cs, MiuixPalette palette) {
    final dark = cs.brightness == Brightness.dark;
    final track = dark ? cs.surfaceContainer : palette.secondaryContainer;
    final selected = dark
        ? cs.surfaceContainerHighest
        : cs.surfaceContainerHigh;
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? selected : track,
      ),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return palette.onSurface.withValues(alpha: 0.3);
        }
        return states.contains(WidgetState.selected)
            ? palette.onSurface
            : palette.summary;
      }),
      textStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 15,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w500
              : FontWeight.w400,
        ),
      ),
      side: const WidgetStatePropertyAll(BorderSide.none),
      overlayColor: WidgetStatePropertyAll(palette.pressedOverlay),
      minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
      shape: WidgetStatePropertyAll(
        MiuixShape.border(const BorderRadius.all(Radius.circular(12))),
      ),
    );
  }
}
