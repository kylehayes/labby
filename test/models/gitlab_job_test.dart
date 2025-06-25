import 'package:flutter_test/flutter_test.dart';
import 'package:labby/models/gitlab_job.dart';

void main() {
  group('GitLabJob', () {
    test('should create from JSON correctly with all fields', () {
      final json = {
        'id': 123,
        'name': 'test-job',
        'stage': 'test',
        'status': 'success',
        'created_at': '2023-10-01T10:00:00Z',
        'started_at': '2023-10-01T10:01:00Z',
        'finished_at': '2023-10-01T10:05:00Z',
        'duration': 240.5,
        'web_url': 'https://gitlab.com/group/project/-/jobs/123',
        'when': 'on_success',
      };

      final job = GitLabJob.fromJson(json);

      expect(job.id, 123);
      expect(job.name, 'test-job');
      expect(job.stage, 'test');
      expect(job.status, 'success');
      expect(job.createdAt, '2023-10-01T10:00:00Z');
      expect(job.startedAt, '2023-10-01T10:01:00Z');
      expect(job.finishedAt, '2023-10-01T10:05:00Z');
      expect(job.duration, 240.5);
      expect(job.webUrl, 'https://gitlab.com/group/project/-/jobs/123');
      expect(job.when, 'on_success');
    });

    test('should create from JSON with null optional fields', () {
      final json = {
        'id': 456,
        'name': 'build-job',
        'stage': 'build',
        'status': 'pending',
        'created_at': '2023-10-02T14:00:00Z',
        'web_url': 'https://gitlab.com/org/repo/-/jobs/456',
      };

      final job = GitLabJob.fromJson(json);

      expect(job.id, 456);
      expect(job.name, 'build-job');
      expect(job.stage, 'build');
      expect(job.status, 'pending');
      expect(job.createdAt, '2023-10-02T14:00:00Z');
      expect(job.startedAt, isNull);
      expect(job.finishedAt, isNull);
      expect(job.duration, isNull);
      expect(job.webUrl, 'https://gitlab.com/org/repo/-/jobs/456');
      expect(job.when, isNull);
    });

    test('should convert to JSON correctly', () {
      const job = GitLabJob(
        id: 789,
        name: 'deploy-job',
        stage: 'deploy',
        status: 'running',
        createdAt: '2023-10-03T09:00:00Z',
        startedAt: '2023-10-03T09:02:00Z',
        webUrl: 'https://gitlab.com/team/app/-/jobs/789',
        when: 'manual',
      );

      final json = job.toJson();

      expect(json['id'], 789);
      expect(json['name'], 'deploy-job');
      expect(json['stage'], 'deploy');
      expect(json['status'], 'running');
      expect(json['created_at'], '2023-10-03T09:00:00Z');
      expect(json['started_at'], '2023-10-03T09:02:00Z');
      expect(json['finished_at'], isNull);
      expect(json['duration'], isNull);
      expect(json['web_url'], 'https://gitlab.com/team/app/-/jobs/789');
      expect(json['when'], 'manual');
    });

    group('status getters', () {
      test('isRunning should return true for running status', () {
        const job = GitLabJob(
          id: 1,
          name: 'test',
          stage: 'test',
          status: 'running',
          createdAt: '2023-10-01T10:00:00Z',
          webUrl: 'https://gitlab.com/test',
        );

        expect(job.isRunning, isTrue);
        expect(job.isPending, isFalse);
        expect(job.isSuccess, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.isCanceled, isFalse);
        expect(job.isManual, isFalse);
        expect(job.canBeStarted, isFalse);
      });

      test('isPending should return true for pending status', () {
        const job = GitLabJob(
          id: 2,
          name: 'test',
          stage: 'test',
          status: 'pending',
          createdAt: '2023-10-01T10:00:00Z',
          webUrl: 'https://gitlab.com/test',
        );

        expect(job.isRunning, isFalse);
        expect(job.isPending, isTrue);
        expect(job.isSuccess, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.isCanceled, isFalse);
        expect(job.isManual, isFalse);
        expect(job.canBeStarted, isFalse);
      });

      test('isPending should return true for created status', () {
        const job = GitLabJob(
          id: 3,
          name: 'test',
          stage: 'test',
          status: 'created',
          createdAt: '2023-10-01T10:00:00Z',
          webUrl: 'https://gitlab.com/test',
        );

        expect(job.isRunning, isFalse);
        expect(job.isPending, isTrue);
        expect(job.isSuccess, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.isCanceled, isFalse);
        expect(job.isManual, isFalse);
        expect(job.canBeStarted, isFalse);
      });

      test('isSuccess should return true for success status', () {
        const job = GitLabJob(
          id: 4,
          name: 'test',
          stage: 'test',
          status: 'success',
          createdAt: '2023-10-01T10:00:00Z',
          webUrl: 'https://gitlab.com/test',
        );

        expect(job.isRunning, isFalse);
        expect(job.isPending, isFalse);
        expect(job.isSuccess, isTrue);
        expect(job.isFailed, isFalse);
        expect(job.isCanceled, isFalse);
        expect(job.isManual, isFalse);
        expect(job.canBeStarted, isFalse);
      });

      test('isFailed should return true for failed status', () {
        const job = GitLabJob(
          id: 5,
          name: 'test',
          stage: 'test',
          status: 'failed',
          createdAt: '2023-10-01T10:00:00Z',
          webUrl: 'https://gitlab.com/test',
        );

        expect(job.isRunning, isFalse);
        expect(job.isPending, isFalse);
        expect(job.isSuccess, isFalse);
        expect(job.isFailed, isTrue);
        expect(job.isCanceled, isFalse);
        expect(job.isManual, isFalse);
        expect(job.canBeStarted, isFalse);
      });

      test('isCanceled should return true for canceled status', () {
        const job = GitLabJob(
          id: 6,
          name: 'test',
          stage: 'test',
          status: 'canceled',
          createdAt: '2023-10-01T10:00:00Z',
          webUrl: 'https://gitlab.com/test',
        );

        expect(job.isRunning, isFalse);
        expect(job.isPending, isFalse);
        expect(job.isSuccess, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.isCanceled, isTrue);
        expect(job.isManual, isFalse);
        expect(job.canBeStarted, isFalse);
      });

      test('isManual and canBeStarted should return true for manual status',
          () {
        const job = GitLabJob(
          id: 7,
          name: 'test',
          stage: 'test',
          status: 'manual',
          createdAt: '2023-10-01T10:00:00Z',
          webUrl: 'https://gitlab.com/test',
        );

        expect(job.isRunning, isFalse);
        expect(job.isPending, isFalse);
        expect(job.isSuccess, isFalse);
        expect(job.isFailed, isFalse);
        expect(job.isCanceled, isFalse);
        expect(job.isManual, isTrue);
        expect(job.canBeStarted, isTrue);
      });
    });
  });
}
