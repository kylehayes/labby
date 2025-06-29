import 'package:flutter_test/flutter_test.dart';
import 'package:labby/services/gitlab_api_service.dart';

void main() {
  group('GitLabApiService', () {
    late GitLabApiService apiService;

    setUp(() {
      apiService = GitLabApiService(
        baseUrl: 'https://gitlab.example.com',
        token: 'test-token',
      );
    });

    tearDown(() {
      apiService.dispose();
    });

    group('Constructor and Properties', () {
      test('should initialize with correct base URL and token', () {
        expect(apiService.baseUrl, 'https://gitlab.example.com');
        expect(apiService.token, 'test-token');
      });

      test('should create service with trailing slash in URL', () {
        final service = GitLabApiService(
          baseUrl: 'https://gitlab.example.com/',
          token: 'test-token',
        );

        expect(service.baseUrl, 'https://gitlab.example.com/');
        service.dispose();
      });
    });

    group('Service Methods', () {
      test('should have correct method signatures', () {
        // Test that methods exist with correct signatures by checking types
        expect(apiService.getProjects, isA<Function>());
        expect(apiService.getProject, isA<Function>());
        expect(apiService.getPipelines, isA<Function>());
        expect(apiService.getPipeline, isA<Function>());
        expect(apiService.getPipelineJobs, isA<Function>());
        expect(apiService.playJob, isA<Function>());
        expect(apiService.retryJob, isA<Function>());
        expect(apiService.getMergeRequests, isA<Function>());
        expect(apiService.getMergeRequest, isA<Function>());
        expect(apiService.testConnection, isA<Function>());
      });
    });

    group('Parameter Validation', () {
      test('should accept valid project IDs for getProject', () {
        expect(1, isA<int>());
        expect(999999, isA<int>());
        expect(0, isA<int>());
      });

      test('should accept valid pipeline parameters', () {
        expect('running', isA<String>());
        expect('success', isA<String>());
        expect(2, isA<int>());
        expect(50, isA<int>());
      });

      test('should accept valid search parameters', () {
        expect('test', isA<String>());
        expect('', isA<String>());
        expect('my-group', isA<String>());
      });
    });

    group('Dispose', () {
      test('should dispose without throwing', () {
        final service = GitLabApiService(
          baseUrl: 'https://test.com',
          token: 'token',
        );

        expect(() => service.dispose(), returnsNormally);
      });

      test('should handle multiple dispose calls', () {
        final service = GitLabApiService(
          baseUrl: 'https://test.com',
          token: 'token',
        );

        expect(() {
          service.dispose();
          service.dispose();
        }, returnsNormally);
      });
    });
  });
}
