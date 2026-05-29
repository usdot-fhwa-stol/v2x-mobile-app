import 'package:cv_mec/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs();
  SharedPreferences? _prefs;
  static const String _keyDarkTheme = "darkTheme";
  static const String _keyIconSize = "iconSize";
  static const String _keyScreenWidth = "screenWidth";
  static const String _keyScreenHeight = "screenHeight";

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

  saveScreenWidthToPrefs(int width) async {
    await initPrefs();
    _prefs?.setInt(_keyScreenWidth, width);
  }

  Future<int?> getScreenWidthFromPrefs() async {
    await initPrefs();
    return _prefs?.getInt(_keyScreenWidth);
  }

  saveScreenHeightToPrefs(int height) async {
    await initPrefs();
    _prefs?.setInt(_keyScreenHeight, height);
  }

  Future<int?> getScreenHeightFromPrefs() async {
    await initPrefs();
    return _prefs?.getInt(_keyScreenHeight);
  }
}
