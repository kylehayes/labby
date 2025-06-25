import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:labby/services/config_service.dart';

void main() {
  group('ConfigService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('GitLab URL', () {
      test('should get and set GitLab URL', () async {
        const testUrl = 'https://gitlab.example.com';

        await ConfigService.setGitLabUrl(testUrl);
        final url = await ConfigService.getGitLabUrl();

        expect(url, testUrl);
      });

      test('should return null when no URL is set', () async {
        final url = await ConfigService.getGitLabUrl();
        expect(url, isNull);
      });
    });

    group('GitLab Token', () {
      test('should get and set GitLab token', () async {
        const testToken = 'glpat-xxxxxxxxxxxxxxxxxxxx';

        await ConfigService.setGitLabToken(testToken);
        final token = await ConfigService.getGitLabToken();

        expect(token, testToken);
      });

      test('should return null when no token is set', () async {
        final token = await ConfigService.getGitLabToken();
        expect(token, isNull);
      });
    });

    group('GitLab Group', () {
      test('should get and set GitLab group', () async {
        const testGroup = 'my-group';

        await ConfigService.setGitLabGroup(testGroup);
        final group = await ConfigService.getGitLabGroup();

        expect(group, testGroup);
      });

      test('should return null when no group is set', () async {
        final group = await ConfigService.getGitLabGroup();
        expect(group, isNull);
      });

      test('should remove group when setting null', () async {
        await ConfigService.setGitLabGroup('test-group');
        await ConfigService.setGitLabGroup(null);
        final group = await ConfigService.getGitLabGroup();

        expect(group, isNull);
      });

      test('should remove group when setting empty string', () async {
        await ConfigService.setGitLabGroup('test-group');
        await ConfigService.setGitLabGroup('');
        final group = await ConfigService.getGitLabGroup();

        expect(group, isNull);
      });
    });

    group('Configuration Status', () {
      test('should return true when both URL and token are set', () async {
        await ConfigService.setGitLabUrl('https://gitlab.com');
        await ConfigService.setGitLabToken('glpat-test');

        final hasConfig = await ConfigService.hasConfiguration();
        expect(hasConfig, isTrue);
      });

      test('should return false when URL is missing', () async {
        await ConfigService.setGitLabToken('glpat-test');

        final hasConfig = await ConfigService.hasConfiguration();
        expect(hasConfig, isFalse);
      });

      test('should return false when token is missing', () async {
        await ConfigService.setGitLabUrl('https://gitlab.com');

        final hasConfig = await ConfigService.hasConfiguration();
        expect(hasConfig, isFalse);
      });

      test('should return false when both are missing', () async {
        final hasConfig = await ConfigService.hasConfiguration();
        expect(hasConfig, isFalse);
      });

      test('should return false when URL is empty', () async {
        await ConfigService.setGitLabUrl('');
        await ConfigService.setGitLabToken('glpat-test');

        final hasConfig = await ConfigService.hasConfiguration();
        expect(hasConfig, isFalse);
      });

      test('should return false when token is empty', () async {
        await ConfigService.setGitLabUrl('https://gitlab.com');
        await ConfigService.setGitLabToken('');

        final hasConfig = await ConfigService.hasConfiguration();
        expect(hasConfig, isFalse);
      });
    });

    group('Theme Mode', () {
      test('should get and set theme mode', () async {
        const testTheme = 'dark';

        await ConfigService.setThemeMode(testTheme);
        final theme = await ConfigService.getThemeMode();

        expect(theme, testTheme);
      });

      test('should return null when no theme is set', () async {
        final theme = await ConfigService.getThemeMode();
        expect(theme, isNull);
      });
    });

    group('Watched Projects', () {
      test('should get and set watched projects', () async {
        final testProjects = [1, 2, 3, 4, 5];

        await ConfigService.setWatchedProjects(testProjects);
        final projects = await ConfigService.getWatchedProjects();

        expect(projects, testProjects);
      });

      test('should return empty list when no projects are watched', () async {
        final projects = await ConfigService.getWatchedProjects();
        expect(projects, isEmpty);
      });

      test('should add watched project', () async {
        await ConfigService.setWatchedProjects([1, 2]);
        await ConfigService.addWatchedProject(3);

        final projects = await ConfigService.getWatchedProjects();
        expect(projects, [1, 2, 3]);
      });

      test('should not add duplicate watched project', () async {
        await ConfigService.setWatchedProjects([1, 2]);
        await ConfigService.addWatchedProject(2);

        final projects = await ConfigService.getWatchedProjects();
        expect(projects, [1, 2]);
      });

      test('should remove watched project', () async {
        await ConfigService.setWatchedProjects([1, 2, 3]);
        await ConfigService.removeWatchedProject(2);

        final projects = await ConfigService.getWatchedProjects();
        expect(projects, [1, 3]);
      });

      test('should handle removing non-existent project', () async {
        await ConfigService.setWatchedProjects([1, 2]);
        await ConfigService.removeWatchedProject(99);

        final projects = await ConfigService.getWatchedProjects();
        expect(projects, [1, 2]);
      });
    });

    group('Starred Pipelines', () {
      test('should get and set starred pipelines', () async {
        final testPipelines = ['1_100', '2_200', '3_300'];

        await ConfigService.setStarredPipelines(testPipelines);
        final pipelines = await ConfigService.getStarredPipelines();

        expect(pipelines, testPipelines);
      });

      test('should return empty list when no pipelines are starred', () async {
        final pipelines = await ConfigService.getStarredPipelines();
        expect(pipelines, isEmpty);
      });

      test('should add starred pipeline', () async {
        await ConfigService.setStarredPipelines(['1_100', '2_200']);
        await ConfigService.addStarredPipeline(3, 300);

        final pipelines = await ConfigService.getStarredPipelines();
        expect(pipelines, ['1_100', '2_200', '3_300']);
      });

      test('should not add duplicate starred pipeline', () async {
        await ConfigService.setStarredPipelines(['1_100', '2_200']);
        await ConfigService.addStarredPipeline(2, 200);

        final pipelines = await ConfigService.getStarredPipelines();
        expect(pipelines, ['1_100', '2_200']);
      });

      test('should remove starred pipeline', () async {
        await ConfigService.setStarredPipelines(['1_100', '2_200', '3_300']);
        await ConfigService.removeStarredPipeline(2, 200);

        final pipelines = await ConfigService.getStarredPipelines();
        expect(pipelines, ['1_100', '3_300']);
      });

      test('should handle removing non-existent pipeline', () async {
        await ConfigService.setStarredPipelines(['1_100', '2_200']);
        await ConfigService.removeStarredPipeline(99, 999);

        final pipelines = await ConfigService.getStarredPipelines();
        expect(pipelines, ['1_100', '2_200']);
      });

      test('should check if pipeline is starred', () async {
        await ConfigService.setStarredPipelines(['1_100', '2_200']);

        final isStarred1 = await ConfigService.isPipelineStarred(1, 100);
        final isStarred2 = await ConfigService.isPipelineStarred(2, 200);
        final isNotStarred = await ConfigService.isPipelineStarred(3, 300);

        expect(isStarred1, isTrue);
        expect(isStarred2, isTrue);
        expect(isNotStarred, isFalse);
      });
    });

    group('Clear Configuration', () {
      test('should clear all configuration except theme', () async {
        await ConfigService.setGitLabUrl('https://gitlab.com');
        await ConfigService.setGitLabToken('glpat-test');
        await ConfigService.setGitLabGroup('test-group');
        await ConfigService.setThemeMode('dark');
        await ConfigService.setWatchedProjects([1, 2, 3]);
        await ConfigService.setStarredPipelines(['1_100', '2_200']);

        await ConfigService.clearConfiguration();

        expect(await ConfigService.getGitLabUrl(), isNull);
        expect(await ConfigService.getGitLabToken(), isNull);
        expect(await ConfigService.getGitLabGroup(), isNull);
        expect(await ConfigService.getWatchedProjects(), isEmpty);
        expect(await ConfigService.getStarredPipelines(), isEmpty);

        expect(await ConfigService.getThemeMode(), 'dark');
      });
    });
  });
}
