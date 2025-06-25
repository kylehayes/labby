import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gitlab_project.dart';
import '../models/gitlab_pipeline.dart';
import '../models/gitlab_job.dart';
import '../models/gitlab_merge_request.dart';
import '../models/starred_pipeline.dart';

class GitLabApiService {
  final String baseUrl;
  final String token;

  late final http.Client _client;

  GitLabApiService({
    required this.baseUrl,
    required this.token,
  }) {
    _client = http.Client();
  }

  Map<String, String> get _headers => {
        'PRIVATE-TOKEN': token,
        'Content-Type': 'application/json',
      };

  String _buildUrl(String endpoint) {
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$cleanBaseUrl/api/v4$endpoint';
  }

  Future<List<GitLabProject>> getProjects({
    String? search,
    String? groupId,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'order_by': 'last_activity_at',
      'sort': 'desc',
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    // Build endpoint based on whether we're filtering by group
    String endpoint;
    if (groupId != null && groupId.isNotEmpty) {
      // Use groups endpoint to get projects from a specific group
      endpoint = '/groups/${Uri.encodeComponent(groupId)}/projects';
    } else {
      // Use general projects endpoint
      endpoint = '/projects';
    }

    final uri = Uri.parse(_buildUrl(endpoint)).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => GitLabProject.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch projects: ${response.statusCode} ${response.body}');
    }
  }

  Future<GitLabProject> getProject(int projectId) async {
    final uri = Uri.parse(_buildUrl('/projects/$projectId'));

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return GitLabProject.fromJson(json);
    } else {
      throw Exception(
          'Failed to fetch project: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<GitLabPipeline>> getPipelines(
    int projectId, {
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'order_by': 'updated_at',
      'sort': 'desc',
    };

    if (status != null) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse(_buildUrl('/projects/$projectId/pipelines')).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => GitLabPipeline.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch pipelines: ${response.statusCode} ${response.body}');
    }
  }

  Future<GitLabPipeline> getPipeline(int projectId, int pipelineId) async {
    final uri =
        Uri.parse(_buildUrl('/projects/$projectId/pipelines/$pipelineId'));

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return GitLabPipeline.fromJson(json);
    } else {
      throw Exception(
          'Failed to fetch pipeline: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<GitLabJob>> getPipelineJobs(int projectId, int pipelineId) async {
    final uri =
        Uri.parse(_buildUrl('/projects/$projectId/pipelines/$pipelineId/jobs'));

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => GitLabJob.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch pipeline jobs: ${response.statusCode} ${response.body}');
    }
  }

  Future<GitLabJob> playJob(int projectId, int jobId) async {
    final uri = Uri.parse(_buildUrl('/projects/$projectId/jobs/$jobId/play'));

    final response = await _client.post(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return GitLabJob.fromJson(json);
    } else {
      throw Exception(
          'Failed to start job: ${response.statusCode} ${response.body}');
    }
  }

  Future<GitLabJob> retryJob(int projectId, int jobId) async {
    final uri = Uri.parse(_buildUrl('/projects/$projectId/jobs/$jobId/retry'));

    final response = await _client.post(uri, headers: _headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return GitLabJob.fromJson(json);
    } else {
      throw Exception(
          'Failed to retry job: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<GitLabMergeRequest>> getMergeRequests({
    String? scope,
    String? state,
    int? projectId,
    List<int>? projectIds,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'order_by': 'updated_at',
      'sort': 'desc',
    };

    if (scope != null) {
      queryParams['scope'] = scope; // 'created_by_me', 'assigned_to_me', 'all'
    }

    if (state != null) {
      queryParams['state'] = state; // 'opened', 'closed', 'merged', 'all'
    }

    String endpoint;
    if (projectId != null) {
      endpoint = '/projects/$projectId/merge_requests';
    } else {
      endpoint = '/merge_requests';
    }

    final uri = Uri.parse(_buildUrl(endpoint)).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => GitLabMergeRequest.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch merge requests: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<GitLabMergeRequest>> getMergeRequestsFromWatchedProjects({
    String? state,
    List<int> projectIds = const [],
    int perPage = 20,
  }) async {
    if (projectIds.isEmpty) return [];

    final allMergeRequests = <GitLabMergeRequest>[];

    // Fetch merge requests from each watched project
    for (final projectId in projectIds) {
      try {
        final projectMRs = await getMergeRequests(
          projectId: projectId,
          state: state,
          perPage: perPage,
        );
        allMergeRequests.addAll(projectMRs);
      } catch (e) {
        // Continue with other projects if one fails
        continue;
      }
    }

    // Sort by updated_at descending
    allMergeRequests.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return allMergeRequests;
  }

  Future<GitLabMergeRequest> getMergeRequest(
      int projectId, int mergeRequestIid) async {
    final uri = Uri.parse(
        _buildUrl('/projects/$projectId/merge_requests/$mergeRequestIid'));

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return GitLabMergeRequest.fromJson(json);
    } else {
      throw Exception(
          'Failed to fetch merge request: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<StarredPipeline>> getStarredPipelines(
      List<String> starredPipelineKeys) async {
    if (starredPipelineKeys.isEmpty) return [];

    final allStarredPipelines = <StarredPipeline>[];

    for (final pipelineKey in starredPipelineKeys) {
      try {
        final parts = pipelineKey.split('_');
        if (parts.length != 2) continue;

        final projectId = int.parse(parts[0]);
        final pipelineId = int.parse(parts[1]);

        final pipeline = await getPipeline(projectId, pipelineId);
        final project = await getProject(projectId);

        allStarredPipelines.add(StarredPipeline(
          pipeline: pipeline,
          project: project,
        ));
      } catch (e) {
        continue;
      }
    }

    allStarredPipelines
        .sort((a, b) => b.pipeline.updatedAt.compareTo(a.pipeline.updatedAt));

    return allStarredPipelines;
  }

  Future<Map<String, dynamic>> testConnection() async {
    try {
      final uri = Uri.parse(_buildUrl('/user'));

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        return {
          'success': true,
          'message':
              'Connected as ${user['name'] ?? user['username'] ?? 'Unknown'}'
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message':
              'Authentication failed. Please check your personal access token.'
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message':
              'Access forbidden. Your token may not have sufficient permissions.'
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  void dispose() {
    _client.close();
  }
}
