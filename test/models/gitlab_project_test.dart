import 'package:flutter_test/flutter_test.dart';
import 'package:labby/models/gitlab_project.dart';

void main() {
  group('GitLabProject', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'test-project',
        'name_with_namespace': 'group/test-project',
        'web_url': 'https://gitlab.com/group/test-project',
        'description': 'Test project description',
        'default_branch': 'main',
      };

      final project = GitLabProject.fromJson(json);

      expect(project.id, 1);
      expect(project.name, 'test-project');
      expect(project.nameWithNamespace, 'group/test-project');
      expect(project.webUrl, 'https://gitlab.com/group/test-project');
      expect(project.description, 'Test project description');
      expect(project.defaultBranch, 'main');
    });

    test('should create from JSON with null optional fields', () {
      final json = {
        'id': 2,
        'name': 'minimal-project',
        'name_with_namespace': 'user/minimal-project',
        'web_url': 'https://gitlab.com/user/minimal-project',
      };

      final project = GitLabProject.fromJson(json);

      expect(project.id, 2);
      expect(project.name, 'minimal-project');
      expect(project.nameWithNamespace, 'user/minimal-project');
      expect(project.webUrl, 'https://gitlab.com/user/minimal-project');
      expect(project.description, isNull);
      expect(project.defaultBranch, isNull);
    });

    test('should convert to JSON correctly', () {
      const project = GitLabProject(
        id: 3,
        name: 'json-test',
        nameWithNamespace: 'org/json-test',
        webUrl: 'https://gitlab.com/org/json-test',
        description: 'JSON test description',
        defaultBranch: 'develop',
      );

      final json = project.toJson();

      expect(json['id'], 3);
      expect(json['name'], 'json-test');
      expect(json['name_with_namespace'], 'org/json-test');
      expect(json['web_url'], 'https://gitlab.com/org/json-test');
      expect(json['description'], 'JSON test description');
      expect(json['default_branch'], 'develop');
    });

    test('should use nameWithNamespace for toString', () {
      const project = GitLabProject(
        id: 4,
        name: 'string-test',
        nameWithNamespace: 'company/string-test',
        webUrl: 'https://gitlab.com/company/string-test',
      );

      expect(project.toString(), 'company/string-test');
    });

    test('should handle equality correctly', () {
      const project1 = GitLabProject(
        id: 5,
        name: 'equality-test',
        nameWithNamespace: 'team/equality-test',
        webUrl: 'https://gitlab.com/team/equality-test',
      );

      const project2 = GitLabProject(
        id: 5,
        name: 'equality-test',
        nameWithNamespace: 'team/equality-test',
        webUrl: 'https://gitlab.com/team/equality-test',
      );

      const project3 = GitLabProject(
        id: 6,
        name: 'different-test',
        nameWithNamespace: 'team/different-test',
        webUrl: 'https://gitlab.com/team/different-test',
      );

      expect(project1 == project2, isTrue);
      expect(project1 == project3, isFalse);
    });
  });
}
