import 'dart:async';
import 'package:flutter/material.dart';
import '../models/gitlab_project.dart';
import '../models/gitlab_pipeline.dart';
import '../services/gitlab_api_service.dart';
import '../services/config_service.dart';
import 'pipeline_detail_screen.dart';
import 'starred_pipelines_screen.dart';

class PipelineListScreen extends StatefulWidget {
  final GitLabProject project;
  final GitLabApiService apiService;

  const PipelineListScreen({
    super.key,
    required this.project,
    required this.apiService,
  });

  @override
  State<PipelineListScreen> createState() => _PipelineListScreenState();
}

class _PipelineListScreenState extends State<PipelineListScreen> {
  List<GitLabPipeline> _pipelines = [];
  bool _isLoading = false;
  Timer? _refreshTimer;
  String _selectedStatus = 'running';
  Map<int, bool> _starredStatus = {};

  final List<String> _statusOptions = [
    'all',
    'running',
    'pending',
    'success',
    'failed',
    'canceled',
  ];

  @override
  void initState() {
    super.initState();
    _loadPipelines();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadPipelines(showLoading: false),
    );
  }

  Future<void> _loadPipelines({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final pipelines = await widget.apiService.getPipelines(
        widget.project.id,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );

      await _loadStarredStatus(pipelines);

      if (mounted) {
        setState(() {
          _pipelines = pipelines;
          if (showLoading) _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading pipelines: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadStarredStatus(List<GitLabPipeline> pipelines) async {
    final Map<int, bool> starredStatus = {};
    for (final pipeline in pipelines) {
      starredStatus[pipeline.id] = await ConfigService.isPipelineStarred(
        widget.project.id,
        pipeline.id,
      );
    }
    _starredStatus = starredStatus;
  }

  Future<void> _toggleStar(GitLabPipeline pipeline) async {
    final isCurrentlyStarred = _starredStatus[pipeline.id] ?? false;

    try {
      if (isCurrentlyStarred) {
        await ConfigService.removeStarredPipeline(
            widget.project.id, pipeline.id);
      } else {
        await ConfigService.addStarredPipeline(widget.project.id, pipeline.id);
      }

      if (mounted) {
        setState(() {
          _starredStatus[pipeline.id] = !isCurrentlyStarred;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyStarred
                ? 'Pipeline removed from favorites'
                : 'Pipeline added to favorites'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorite: $e'),
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
        title: Text(widget.project.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const StarredPipelinesScreen()),
              );
            },
            tooltip: 'Starred Pipelines',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPipelines(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Status: '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                        _loadPipelines();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && _pipelines.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _pipelines.isEmpty
                    ? const Center(
                        child: Text(
                          'No pipelines found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadPipelines(showLoading: false),
                        child: ListView.builder(
                          itemCount: _pipelines.length,
                          itemBuilder: (context, index) {
                            final pipeline = _pipelines[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: _getStatusIcon(pipeline.status),
                                title: Text(
                                  'Pipeline #${pipeline.id}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Branch: ${pipeline.ref}'),
                                    Text(
                                        'Status: ${pipeline.status.toUpperCase()}'),
                                    Text(
                                        'Updated: ${_formatDateTime(pipeline.updatedAt)}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _starredStatus[pipeline.id] == true
                                            ? Icons.star
                                            : Icons.star_border,
                                        color:
                                            _starredStatus[pipeline.id] == true
                                                ? Colors.amber
                                                : Colors.grey,
                                      ),
                                      onPressed: () => _toggleStar(pipeline),
                                      tooltip:
                                          _starredStatus[pipeline.id] == true
                                              ? 'Remove from favorites'
                                              : 'Add to favorites',
                                    ),
                                    pipeline.isRunning
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(Icons.arrow_forward_ios),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PipelineDetailScreen(
                                        project: widget.project,
                                        pipeline: pipeline,
                                        apiService: widget.apiService,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
