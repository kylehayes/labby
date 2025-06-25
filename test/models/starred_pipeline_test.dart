import 'package:flutter_test/flutter_test.dart';
import 'package:labby/models/starred_pipeline.dart';
import 'package:labby/models/gitlab_pipeline.dart';
import 'package:labby/models/gitlab_project.dart';

void main() {
  group('StarredPipeline', () {
    test('should create with pipeline and project', () {
      const project = GitLabProject(
        id: 123,
        name: 'test-project',
        nameWithNamespace: 'group/test-project',
        webUrl: 'https://gitlab.com/group/test-project',
        description: 'Test project',
        defaultBranch: 'main',
      );

      const pipeline = GitLabPipeline(
        id: 456,
        sha: 'abc123def456',
        ref: 'main',
        status: 'success',
        createdAt: '2023-10-01T10:00:00Z',
        updatedAt: '2023-10-01T10:30:00Z',
        webUrl: 'https://gitlab.com/group/test-project/-/pipelines/456',
      );

      const starredPipeline = StarredPipeline(
        pipeline: pipeline,
        project: project,
      );

      expect(starredPipeline.pipeline, equals(pipeline));
      expect(starredPipeline.project, equals(project));
      expect(starredPipeline.pipeline.id, 456);
      expect(starredPipeline.project.id, 123);
      expect(starredPipeline.pipeline.status, 'success');
      expect(starredPipeline.project.name, 'test-project');
    });

    test('should allow access to nested properties', () {
      const project = GitLabProject(
        id: 789,
        name: 'another-project',
        nameWithNamespace: 'org/another-project',
        webUrl: 'https://gitlab.com/org/another-project',
      );

      const pipeline = GitLabPipeline(
        id: 101,
        sha: 'def456ghi789',
        ref: 'develop',
        status: 'running',
        createdAt: '2023-10-02T14:00:00Z',
        updatedAt: '2023-10-02T14:15:00Z',
        webUrl: 'https://gitlab.com/org/another-project/-/pipelines/101',
      );

      const starredPipeline = StarredPipeline(
        pipeline: pipeline,
        project: project,
      );

      expect(starredPipeline.pipeline.isRunning, isTrue);
      expect(starredPipeline.project.toString(), 'org/another-project');
      expect(starredPipeline.pipeline.ref, 'develop');
      expect(starredPipeline.project.nameWithNamespace, 'org/another-project');
    });

    test('should handle equality correctly', () {
      const project1 = GitLabProject(
        id: 1,
        name: 'project1',
        nameWithNamespace: 'group/project1',
        webUrl: 'https://gitlab.com/group/project1',
      );

      const pipeline1 = GitLabPipeline(
        id: 1,
        sha: 'sha1',
        ref: 'main',
        status: 'success',
        createdAt: '2023-10-01T10:00:00Z',
        updatedAt: '2023-10-01T10:30:00Z',
        webUrl: 'https://gitlab.com/group/project1/-/pipelines/1',
      );

      const project2 = GitLabProject(
        id: 1,
        name: 'project1',
        nameWithNamespace: 'group/project1',
        webUrl: 'https://gitlab.com/group/project1',
      );

      const pipeline2 = GitLabPipeline(
        id: 1,
        sha: 'sha1',
        ref: 'main',
        status: 'success',
        createdAt: '2023-10-01T10:00:00Z',
        updatedAt: '2023-10-01T10:30:00Z',
        webUrl: 'https://gitlab.com/group/project1/-/pipelines/1',
      );

      const starredPipeline1 = StarredPipeline(
        pipeline: pipeline1,
        project: project1,
      );

      const starredPipeline2 = StarredPipeline(
        pipeline: pipeline2,
        project: project2,
      );

      expect(starredPipeline1.pipeline == starredPipeline2.pipeline, isTrue);
      expect(starredPipeline1.project == starredPipeline2.project, isTrue);
    });
  });
}
