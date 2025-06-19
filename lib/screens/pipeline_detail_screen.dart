import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gitlab_project.dart';
import '../models/gitlab_pipeline.dart';
import '../models/gitlab_job.dart';
import '../services/gitlab_api_service.dart';
import '../services/status_bar_service.dart';

class PipelineDetailScreen extends StatefulWidget {
  final GitLabProject project;
  final GitLabPipeline pipeline;
  final GitLabApiService apiService;

  const PipelineDetailScreen({
    super.key,
    required this.project,
    required this.pipeline,
    required this.apiService,
  });

  @override
  State<PipelineDetailScreen> createState() => _PipelineDetailScreenState();
}

class _PipelineDetailScreenState extends State<PipelineDetailScreen> {
  List<GitLabJob> _jobs = [];
  bool _isLoading = false;
  Timer? _refreshTimer;
  Map<String, List<GitLabJob>> _jobsByStage = {};
  late GitLabPipeline _currentPipeline;
  List<String> _stageOrder = [];

  @override
  void initState() {
    super.initState();
    _currentPipeline = widget.pipeline;
    _loadPipelineAndJobs();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadPipelineAndJobs(showLoading: false),
    );
  }

  Future<void> _loadPipelineAndJobs({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      // Load both pipeline status and jobs concurrently
      final futures = await Future.wait([
        widget.apiService.getPipeline(widget.project.id, widget.pipeline.id),
        widget.apiService.getPipelineJobs(widget.project.id, widget.pipeline.id),
      ]);

      final pipeline = futures[0] as GitLabPipeline;
      final jobs = futures[1] as List<GitLabJob>;

      if (mounted) {
        setState(() {
          _currentPipeline = pipeline;
          _jobs = jobs;
          _jobsByStage = _groupJobsByStage(jobs);
          if (showLoading) _isLoading = false;
        });

        // Update status bar with current pipeline status
        await StatusBarService.updateStatus(
          projectName: widget.project.name,
          pipeline: pipeline,
          jobs: jobs,
        );

        // Stop auto-refresh only if pipeline is complete AND no jobs are running or manual
        final hasActiveJobs = jobs.any((job) => job.isRunning || job.canBeStarted);
        if (!pipeline.isRunning && !hasActiveJobs && _refreshTimer != null) {
          _refreshTimer!.cancel();
          _refreshTimer = null;
        }
        
        // Start auto-refresh if we have active jobs but no timer
        if ((pipeline.isRunning || hasActiveJobs) && _refreshTimer == null) {
          _startAutoRefresh();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading pipeline data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openInBrowser() async {
    try {
      final url = Uri.parse(_currentPipeline.webUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open pipeline in browser'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening browser: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startManualJob(GitLabJob job) async {
    try {
      await widget.apiService.playJob(widget.project.id, job.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Started job: ${job.name}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh to show the updated job status
        _loadPipelineAndJobs(showLoading: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, List<GitLabJob>> _groupJobsByStage(List<GitLabJob> jobs) {
    final Map<String, List<GitLabJob>> grouped = {};
    final List<String> stageOrder = []; // Track the order stages first appear
    
    for (final job in jobs) {
      if (!grouped.containsKey(job.stage)) {
        grouped[job.stage] = [];
        stageOrder.add(job.stage); // Record first appearance order
      }
      grouped[job.stage]!.add(job);
    }
    
    // Store the stage order for later use
    _stageOrder = stageOrder;
    return grouped;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'running':
        return Colors.blue;
      case 'pending':
      case 'created':
        return Colors.orange;
      case 'canceled':
        return Colors.grey;
      case 'skipped':
        return Colors.grey[400]!;
      default:
        return Colors.grey;
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
      case 'created':
        return const Icon(Icons.schedule, color: Colors.orange);
      case 'canceled':
        return const Icon(Icons.cancel, color: Colors.grey);
      case 'skipped':
        return Icon(Icons.skip_next, color: Colors.grey[400]);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  String _formatDuration(double? duration) {
    if (duration == null) return '';
    final minutes = (duration / 60).floor();
    final seconds = (duration % 60).floor();
    return '${minutes}m ${seconds}s';
  }

  Widget _buildStageColumn(String stage, List<GitLabJob> jobs) {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                stage.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            ...jobs.map((job) => _buildJobCard(job)),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(GitLabJob job) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getStatusIcon(job.status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                job.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(job.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              if (job.duration != null) ...[
                const SizedBox(height: 2),
                Text(
                  _formatDuration(job.duration),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
              if (job.isRunning) ...[
                const SizedBox(height: 4),
                const SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(),
                ),
              ],
              if (job.canBeStarted) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startManualJob(job),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text(
                      'Start',
                      style: TextStyle(fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size.fromHeight(28),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getOrderedStageNames() {
    // Use the order that stages first appeared in the jobs API response
    // Reverse to show pipeline flow left-to-right (first stages on left)
    return _stageOrder.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final stageNames = _getOrderedStageNames();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pipeline #${widget.pipeline.id}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
            tooltip: 'Open in browser',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPipelineAndJobs(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getStatusIcon(_currentPipeline.status),
                    const SizedBox(width: 8),
                    Text(
                      _currentPipeline.status.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(_currentPipeline.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Branch: ${_currentPipeline.ref}'),
                Text('SHA: ${_currentPipeline.sha.substring(0, 8)}'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && _jobs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _jobs.isEmpty
                    ? const Center(
                        child: Text(
                          'No jobs found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: stageNames
                                  .map((stage) => _buildStageColumn(
                                        stage,
                                        _jobsByStage[stage]!,
                                      ))
                                  .toList(),
                            ),
                          ),
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
    // Show default status when leaving pipeline detail screen
    StatusBarService.showDefaultStatus();
    super.dispose();
  }
}