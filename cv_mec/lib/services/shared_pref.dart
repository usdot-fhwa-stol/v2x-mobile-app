import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs();
  SharedPreferences? _prefs;
  static const String _keyDarkTheme = "darkTheme";
  static const String _keyIconSize = "iconSize";

  initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  saveDarkModeToPrefs(bool darkMode) async {
    await initPrefs();
    _prefs?.setBool(_keyDarkTheme, darkMode);
  }

  getDarkModeFromPrefs() async {
    await initPrefs();
    return _prefs?.getBool(_keyDarkTheme);
  }

  saveIconSizeToPrefs(IconSize iconSize) async {
    await initPrefs();
    _prefs?.setString(_keyIconSize, iconSize.name);
  }

  Future<IconSize?> getIconSizeFromPrefs() async {
    await initPrefs();
    String? iconSizeName = _prefs?.getString(_keyIconSize);
    return iconSizeName != null ? IconSize.values.firstWhere((e) => e.name == iconSizeName) : null;
  }
}
