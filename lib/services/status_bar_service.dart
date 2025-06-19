import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/gitlab_pipeline.dart';
import '../models/gitlab_job.dart';

enum PipelineStatus {
  unknown,
  success,
  running,
  failed,
  warning, // has manual jobs available
}

class StatusBarService {
  static const MethodChannel _channel = MethodChannel('gitlab_pipeline_monitor/status_bar');
  
  static Timer? _updateTimer;
  static PipelineStatus _currentStatus = PipelineStatus.unknown;
  static String _currentProject = '';
  static int _currentPipelineId = 0;

  static Future<void> initialize() async {
    if (!Platform.isMacOS) return;
    
    try {
      await _channel.invokeMethod('initialize');
    } catch (e) {
      print('Failed to initialize status bar: $e');
    }
  }

  static Future<void> updateStatus({
    required String projectName,
    required GitLabPipeline pipeline,
    required List<GitLabJob> jobs,
  }) async {
    if (!Platform.isMacOS) return;

    _currentProject = projectName;
    _currentPipelineId = pipeline.id;
    
    // Calculate rollup status
    final newStatus = _calculateRollupStatus(pipeline, jobs);
    
    print('StatusBar: Updating status for $projectName #${pipeline.id} - Status: $newStatus (was: $_currentStatus)');
    
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      await _updateStatusBarIcon(newStatus, projectName, pipeline.id);
    }
  }

  static PipelineStatus _calculateRollupStatus(GitLabPipeline pipeline, List<GitLabJob> jobs) {
    // Check if any jobs are running
    if (jobs.any((job) => job.isRunning) || pipeline.isRunning) {
      return PipelineStatus.running;
    }
    
    // Check if any jobs failed
    if (jobs.any((job) => job.isFailed)) {
      return PipelineStatus.failed;
    }
    
    // Check if there are manual jobs available
    if (jobs.any((job) => job.canBeStarted)) {
      return PipelineStatus.warning;
    }
    
    // Check if pipeline is successful
    if (pipeline.status == 'success' && jobs.every((job) => job.isSuccess || job.isCanceled)) {
      return PipelineStatus.success;
    }
    
    return PipelineStatus.unknown;
  }

  static Future<void> _updateStatusBarIcon(PipelineStatus status, String projectName, int pipelineId) async {
    try {
      final iconName = _getIconForStatus(status);
      final tooltip = _getTooltipForStatus(status, projectName, pipelineId);
      
      print('StatusBar: Setting icon=$iconName, tooltip=$tooltip');
      
      await _channel.invokeMethod('updateIcon', {
        'icon': iconName,
        'tooltip': tooltip,
      });
    } catch (e) {
      print('Failed to update status bar icon: $e');
    }
  }

  static String _getIconForStatus(PipelineStatus status) {
    switch (status) {
      case PipelineStatus.success:
        return 'checkmark.circle.fill';
      case PipelineStatus.running:
        return 'arrow.clockwise.circle.fill';
      case PipelineStatus.failed:
        return 'xmark.circle.fill';
      case PipelineStatus.warning:
        return 'exclamationmark.triangle.fill';
      case PipelineStatus.unknown:
        return 'questionmark.circle.fill';
    }
  }

  static String _getTooltipForStatus(PipelineStatus status, String projectName, int pipelineId) {
    final statusText = switch (status) {
      PipelineStatus.success => 'Success',
      PipelineStatus.running => 'Running',
      PipelineStatus.failed => 'Failed',
      PipelineStatus.warning => 'Manual jobs available',
      PipelineStatus.unknown => 'Unknown',
    };
    
    return 'GitLab: $projectName #$pipelineId - $statusText';
  }

  static Future<void> clearStatus() async {
    if (!Platform.isMacOS) return;
    
    try {
      await _channel.invokeMethod('clear');
      _currentStatus = PipelineStatus.unknown;
    } catch (e) {
      print('Failed to clear status bar: $e');
    }
  }

  static Future<void> showDefaultStatus() async {
    if (!Platform.isMacOS) return;
    
    try {
      final iconName = _getIconForStatus(PipelineStatus.unknown);
      await _channel.invokeMethod('updateIcon', {
        'icon': iconName,
        'tooltip': 'Labby - No active monitoring',
      });
    } catch (e) {
      print('Failed to show default status: $e');
    }
  }

  static Future<void> dispose() async {
    _updateTimer?.cancel();
    await clearStatus();
  }
}