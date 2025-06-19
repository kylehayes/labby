import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _gitlabUrlKey = 'gitlab_url';
  static const String _gitlabTokenKey = 'gitlab_token';
  static const String _gitlabGroupKey = 'gitlab_group';
  static const String _themeKey = 'theme_mode';

  static Future<String?> getGitLabUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_gitlabUrlKey);
  }

  static Future<void> setGitLabUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gitlabUrlKey, url);
  }

  static Future<String?> getGitLabToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_gitlabTokenKey);
  }

  static Future<void> setGitLabToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gitlabTokenKey, token);
  }

  static Future<String?> getGitLabGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_gitlabGroupKey);
  }

  static Future<void> setGitLabGroup(String? group) async {
    final prefs = await SharedPreferences.getInstance();
    if (group != null && group.isNotEmpty) {
      await prefs.setString(_gitlabGroupKey, group);
    } else {
      await prefs.remove(_gitlabGroupKey);
    }
  }

  static Future<bool> hasConfiguration() async {
    final url = await getGitLabUrl();
    final token = await getGitLabToken();
    return url != null && token != null && url.isNotEmpty && token.isNotEmpty;
  }

  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  static Future<void> setThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }

  static Future<void> clearConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gitlabUrlKey);
    await prefs.remove(_gitlabTokenKey);
    await prefs.remove(_gitlabGroupKey);
    // Note: Don't clear theme preference on logout
  }
}