import 'dart:async';
import 'package:flutter/material.dart';
import '../models/starred_pipeline.dart';
import '../services/gitlab_api_service.dart';
import '../services/config_service.dart';
import 'pipeline_detail_screen.dart';

class StarredPipelinesScreen extends StatefulWidget {
  const StarredPipelinesScreen({super.key});

  @override
  State<StarredPipelinesScreen> createState() => _StarredPipelinesScreenState();
}

class _StarredPipelinesScreenState extends State<StarredPipelinesScreen> {
  List<StarredPipeline> _starredPipelines = [];
  bool _isLoading = false;
  bool _isBackgroundRefreshing = false;
  GitLabApiService? _apiService;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final url = await ConfigService.getGitLabUrl();
    final token = await ConfigService.getGitLabToken();
    
    if (url != null && token != null) {
      _apiService = GitLabApiService(baseUrl: url, token: token);
      await _loadStarredPipelines();
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadStarredPipelines(isBackgroundRefresh: true),
    );
  }

  Future<void> _loadStarredPipelines({bool isBackgroundRefresh = false}) async {
    if (_apiService == null) return;

    if (isBackgroundRefresh) {
      setState(() => _isBackgroundRefreshing = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final starredKeys = await ConfigService.getStarredPipelines();
      final starredPipelines = await _apiService!.getStarredPipelines(starredKeys);

      if (mounted) {
        setState(() {
          _starredPipelines = starredPipelines;
          _isLoading = false;
          _isBackgroundRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isBackgroundRefreshing = false;
        });
        
        if (!isBackgroundRefresh) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading starred pipelines: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeStar(StarredPipeline starredPipeline) async {
    try {
      await ConfigService.removeStarredPipeline(
        starredPipeline.project.id,
        starredPipeline.pipeline.id,
      );
      
      if (mounted) {
        setState(() {
          _starredPipelines.removeWhere((sp) => 
            sp.project.id == starredPipeline.project.id && 
            sp.pipeline.id == starredPipeline.pipeline.id
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pipeline removed from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'failed':
        return const Icon(Icons.error, color: Colors.red);
      case 'running':
        return const Icon(Icons.play_circle, color: Colors.blue);
      case 'pending':
        return const Icon(Icons.schedule, color: Colors.orange);
      case 'canceled':
        return const Icon(Icons.cancel, color: Colors.grey);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starred Pipelines'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isBackgroundRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadStarredPipelines(),
          ),
        ],
      ),
      body: _isLoading && _starredPipelines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _starredPipelines.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No starred pipelines',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Star pipelines from project views to see them here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadStarredPipelines(),
                  child: ListView.builder(
                    itemCount: _starredPipelines.length,
                    itemBuilder: (context, index) {
                      final starredPipeline = _starredPipelines[index];
                      final pipeline = starredPipeline.pipeline;
                      final project = starredPipeline.project;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: _getStatusIcon(pipeline.status),
                          title: Text(
                            'Pipeline #${pipeline.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text('Branch: ${pipeline.ref}'),
                              Text('Status: ${pipeline.status.toUpperCase()}'),
                              Text('Updated: ${_formatDateTime(pipeline.updatedAt)}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onPressed: () => _removeStar(starredPipeline),
                                tooltip: 'Remove from favorites',
                              ),
                              pipeline.isRunning
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                          onTap: () {
                            if (_apiService != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PipelineDetailScreen(
                                    project: project,
                                    pipeline: pipeline,
                                    apiService: _apiService!,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _apiService?.dispose();
    super.dispose();
  }
}