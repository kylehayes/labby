import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gitlab_project.dart';
import '../models/gitlab_pipeline.dart';
import '../models/gitlab_job.dart';

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
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
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
      throw Exception('Failed to fetch projects: ${response.statusCode} ${response.body}');
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
      throw Exception('Failed to fetch pipelines: ${response.statusCode} ${response.body}');
    }
  }

  Future<GitLabPipeline> getPipeline(int projectId, int pipelineId) async {
    final uri = Uri.parse(_buildUrl('/projects/$projectId/pipelines/$pipelineId'));

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return GitLabPipeline.fromJson(json);
    } else {
      throw Exception('Failed to fetch pipeline: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<GitLabJob>> getPipelineJobs(int projectId, int pipelineId) async {
    final uri = Uri.parse(_buildUrl('/projects/$projectId/pipelines/$pipelineId/jobs'));

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => GitLabJob.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch pipeline jobs: ${response.statusCode} ${response.body}');
    }
  }

  Future<GitLabJob> playJob(int projectId, int jobId) async {
    final uri = Uri.parse(_buildUrl('/projects/$projectId/jobs/$jobId/play'));

    final response = await _client.post(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return GitLabJob.fromJson(json);
    } else {
      throw Exception('Failed to start job: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> testConnection() async {
    try {
      final uri = Uri.parse(_buildUrl('/user'));
      print('Testing connection to: $uri');
      print('Headers: ${_headers.keys.join(', ')}');
      
      final response = await _client.get(uri, headers: _headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        return {
          'success': true, 
          'message': 'Connected as ${user['name'] ?? user['username'] ?? 'Unknown'}'
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false, 
          'message': 'Authentication failed. Please check your personal access token.'
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false, 
          'message': 'Access forbidden. Your token may not have sufficient permissions.'
        };
      } else {
        return {
          'success': false, 
          'message': 'HTTP ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e) {
      print('Connection exception: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}'
      };
    }
  }

  void dispose() {
    _client.close();
  }
}