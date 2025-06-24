import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _gitlabUrlKey = 'gitlab_url';
  static const String _gitlabTokenKey = 'gitlab_token';
  static const String _gitlabGroupKey = 'gitlab_group';
  static const String _themeKey = 'theme_mode';
  static const String _watchedProjectsKey = 'watched_projects';

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

  static Future<List<int>> getWatchedProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_watchedProjectsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<int>();
    }
    return [];
  }

  static Future<void> setWatchedProjects(List<int> projectIds) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(projectIds);
    await prefs.setString(_watchedProjectsKey, jsonString);
  }

  static Future<void> addWatchedProject(int projectId) async {
    final watchedProjects = await getWatchedProjects();
    if (!watchedProjects.contains(projectId)) {
      watchedProjects.add(projectId);
      await setWatchedProjects(watchedProjects);
    }
  }

  static Future<void> removeWatchedProject(int projectId) async {
    final watchedProjects = await getWatchedProjects();
    watchedProjects.remove(projectId);
    await setWatchedProjects(watchedProjects);
  }

  static Future<void> clearConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gitlabUrlKey);
    await prefs.remove(_gitlabTokenKey);
    await prefs.remove(_gitlabGroupKey);
    await prefs.remove(_watchedProjectsKey);
    // Note: Don't clear theme preference on logout
  }
}