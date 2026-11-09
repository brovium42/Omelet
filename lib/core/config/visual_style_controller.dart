import 'app_chat_chrome.dart';
import 'app_composer_background.dart';
import 'app_miuix.dart';
import 'app_nav_pill_style.dart';
import 'app_visual_style.dart';

class VisualStyleController {
  static Future<void> apply(VisualStyle style) async {
    await AppVisualStyle.save(style);
    switch (style) {
      case VisualStyle.miuix:
        await AppMiuix.syncMaterials();
      case VisualStyle.liquidGlass:
        if (AppNavPillStyle.current.value != NavPillStyle.auto) {
          await AppNavPillStyle.save(NavPillStyle.liquidGlass);
        }
        await AppComposerBackground.save(ComposerBackground.liquidGlass);
        await AppChatChrome.save(ChatChromeStyle.liquidGlass);
      case VisualStyle.materialYou:
      case VisualStyle.glossy:
        await _dropLiquidMaterials();
    }
  }

  static Future<void> _dropLiquidMaterials() async {
    if (AppNavPillStyle.current.value == NavPillStyle.liquidGlass) {
      await AppNavPillStyle.save(NavPillStyle.frostBlur);
    }
    if (AppComposerBackground.current.value == ComposerBackground.liquidGlass) {
      await AppComposerBackground.save(ComposerBackground.frostBlur);
    }
    if (AppChatChrome.current.value == ChatChromeStyle.liquidGlass) {
      await AppChatChrome.save(ChatChromeStyle.transparent);
    }
  }
}
