import 'package:flutter_test/flutter_test.dart';
import 'package:labby/models/gitlab_pipeline.dart';

void main() {
  group('GitLabPipeline', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 123,
        'sha': 'abc123def456',
        'ref': 'main',
        'status': 'success',
        'created_at': '2023-10-01T10:00:00Z',
        'updated_at': '2023-10-01T10:30:00Z',
        'web_url': 'https://gitlab.com/group/project/-/pipelines/123',
      };

      final pipeline = GitLabPipeline.fromJson(json);

      expect(pipeline.id, 123);
      expect(pipeline.sha, 'abc123def456');
      expect(pipeline.ref, 'main');
      expect(pipeline.status, 'success');
      expect(pipeline.createdAt, '2023-10-01T10:00:00Z');
      expect(pipeline.updatedAt, '2023-10-01T10:30:00Z');
      expect(
          pipeline.webUrl, 'https://gitlab.com/group/project/-/pipelines/123');
    });

    test('should convert to JSON correctly', () {
      const pipeline = GitLabPipeline(
        id: 456,
        sha: 'def456ghi789',
        ref: 'develop',
        status: 'failed',
        createdAt: '2023-10-02T14:00:00Z',
        updatedAt: '2023-10-02T14:15:00Z',
        webUrl: 'https://gitlab.com/org/repo/-/pipelines/456',
      );

      final json = pipeline.toJson();

      expect(json['id'], 456);
      expect(json['sha'], 'def456ghi789');
      expect(json['ref'], 'develop');
      expect(json['status'], 'failed');
      expect(json['created_at'], '2023-10-02T14:00:00Z');
      expect(json['updated_at'], '2023-10-02T14:15:00Z');
      expect(json['web_url'], 'https://gitlab.com/org/repo/-/pipelines/456');
    });

    test('isRunning should return true for running status', () {
      const pipeline = GitLabPipeline(
        id: 789,
        sha: 'ghi789jkl012',
        ref: 'feature/test',
        status: 'running',
        createdAt: '2023-10-03T09:00:00Z',
        updatedAt: '2023-10-03T09:05:00Z',
        webUrl: 'https://gitlab.com/user/project/-/pipelines/789',
      );

      expect(pipeline.isRunning, isTrue);
    });

    test('isRunning should return true for pending status', () {
      const pipeline = GitLabPipeline(
        id: 101,
        sha: 'jkl012mno345',
        ref: 'hotfix/urgent',
        status: 'pending',
        createdAt: '2023-10-04T12:00:00Z',
        updatedAt: '2023-10-04T12:00:00Z',
        webUrl: 'https://gitlab.com/team/app/-/pipelines/101',
      );

      expect(pipeline.isRunning, isTrue);
    });

    test('isRunning should return false for success status', () {
      const pipeline = GitLabPipeline(
        id: 202,
        sha: 'mno345pqr678',
        ref: 'main',
        status: 'success',
        createdAt: '2023-10-05T16:00:00Z',
        updatedAt: '2023-10-05T16:30:00Z',
        webUrl: 'https://gitlab.com/company/service/-/pipelines/202',
      );

      expect(pipeline.isRunning, isFalse);
    });

    test('isRunning should return false for failed status', () {
      const pipeline = GitLabPipeline(
        id: 303,
        sha: 'pqr678stu901',
        ref: 'develop',
        status: 'failed',
        createdAt: '2023-10-06T08:00:00Z',
        updatedAt: '2023-10-06T08:20:00Z',
        webUrl: 'https://gitlab.com/org/library/-/pipelines/303',
      );

      expect(pipeline.isRunning, isFalse);
    });

    test('isRunning should return false for canceled status', () {
      const pipeline = GitLabPipeline(
        id: 404,
        sha: 'stu901vwx234',
        ref: 'feature/cancelled',
        status: 'canceled',
        createdAt: '2023-10-07T11:00:00Z',
        updatedAt: '2023-10-07T11:05:00Z',
        webUrl: 'https://gitlab.com/dev/test/-/pipelines/404',
      );

      expect(pipeline.isRunning, isFalse);
    });
  });
}
