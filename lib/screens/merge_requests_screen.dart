import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gitlab_merge_request.dart';
import '../services/gitlab_api_service.dart';
import '../services/config_service.dart';
import '../main.dart';
import 'watched_projects_screen.dart';

class MergeRequestsScreen extends StatefulWidget {
  const MergeRequestsScreen({super.key});

  @override
  State<MergeRequestsScreen> createState() => _MergeRequestsScreenState();
}

class _MergeRequestsScreenState extends State<MergeRequestsScreen> {
  List<GitLabMergeRequest> _mergeRequests = [];
  bool _isLoading = false;
  bool _isBackgroundRefreshing = false;
  String _selectedScope = 'assigned_to_me';
  String _selectedState = 'opened';
  GitLabApiService? _apiService;
  Timer? _pollTimer;

  final Map<String, String> _scopeOptions = {
    'assigned_to_me': 'Assigned to Me',
    'created_by_me': 'Created by Me',
    'watched_projects': 'Watched Projects',
    'all': 'All',
  };

  final Map<String, String> _stateOptions = {
    'opened': 'Open',
    'merged': 'Merged',
    'closed': 'Closed',
    'all': 'All',
  };

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
      _loadMergeRequests();
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadMergeRequests(isBackgroundRefresh: true);
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _loadMergeRequests({bool isBackgroundRefresh = false}) async {
    if (_apiService == null) return;

    setState(() {
      if (isBackgroundRefresh) {
        _isBackgroundRefreshing = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      List<GitLabMergeRequest> mergeRequests;
      
      if (_selectedScope == 'watched_projects') {
        // Load merge requests from watched projects
        final watchedProjectIds = await ConfigService.getWatchedProjects();
        mergeRequests = await _apiService!.getMergeRequestsFromWatchedProjects(
          state: _selectedState,
          projectIds: watchedProjectIds,
        );
      } else {
        // Load user's personal merge requests
        mergeRequests = await _apiService!.getMergeRequests(
          scope: _selectedScope == 'watched_projects' ? null : _selectedScope,
          state: _selectedState,
        );
      }
      
      setState(() {
        _mergeRequests = mergeRequests;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading merge requests: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isBackgroundRefreshing = false;
      });
    }
  }

  Future<void> _openInBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open URL')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening URL: $e')),
        );
      }
    }
  }

  void _navigateToWatchedProjects() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WatchedProjectsScreen()),
    );
    // Refresh merge requests when returning from watched projects config
    if (result != null || _selectedScope == 'watched_projects') {
      _loadMergeRequests();
    }
  }

  Widget _buildMergeRequestCard(GitLabMergeRequest mr) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _openInBrowser(mr.webUrl),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStateChip(mr),
                  const SizedBox(width: 8),
                  if (mr.isDraft) _buildDraftChip(),
                  if (mr.hasConflicts) _buildConflictChip(),
                  const Spacer(),
                  Text(
                    '!${mr.iid}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                mr.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mr.author.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(mr.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${mr.sourceBranch} → ${mr.targetBranch}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (mr.hasActivity) ...[
                    if (mr.userNotesCount > 0) ...[
                      Icon(
                        Icons.comment,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${mr.userNotesCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (mr.upvotes > 0) ...[
                      Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${mr.upvotes}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateChip(GitLabMergeRequest mr) {
    Color chipColor;
    IconData icon;
    
    if (mr.isMerged) {
      chipColor = Colors.purple;
      icon = Icons.merge_type;
    } else if (mr.isClosed) {
      chipColor = Colors.red;
      icon = Icons.close;
    } else {
      chipColor = Colors.green;
      icon = Icons.merge_type;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        mr.state.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDraftChip() {
    return const Chip(
      label: Text(
        'DRAFT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.orange,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildConflictChip() {
    return const Chip(
      avatar: Icon(Icons.warning, size: 16, color: Colors.white),
      label: Text(
        'CONFLICTS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.red,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _stopPolling();
    _apiService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Merge Requests'),
            if (_isBackgroundRefreshing) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToWatchedProjects,
            tooltip: 'Configure Watched Projects',
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return PopupMenuButton<ThemeMode>(
                icon: const Icon(Icons.brightness_6),
                tooltip: 'Theme',
                onSelected: (ThemeMode mode) {
                  themeProvider.setThemeMode(mode);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ThemeMode.system,
                    child: Row(
                      children: [
                        Icon(
                          Icons.brightness_auto,
                          color: themeProvider.themeMode == ThemeMode.system 
                              ? Theme.of(context).colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('System'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.light,
                    child: Row(
                      children: [
                        Icon(
                          Icons.light_mode,
                          color: themeProvider.themeMode == ThemeMode.light 
                              ? Theme.of(context).colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('Light'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemeMode.dark,
                    child: Row(
                      children: [
                        Icon(
                          Icons.dark_mode,
                          color: themeProvider.themeMode == ThemeMode.dark 
                              ? Theme.of(context).colorScheme.primary 
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('Dark'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedScope,
                    decoration: const InputDecoration(
                      labelText: 'Scope',
                      border: OutlineInputBorder(),
                    ),
                    items: _scopeOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedScope = value);
                        _loadMergeRequests();
                        _startPolling(); // Restart polling with new filters
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                    items: _stateOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedState = value);
                        _loadMergeRequests();
                        _startPolling(); // Restart polling with new filters
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && !_isBackgroundRefreshing
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMergeRequests,
                    child: _mergeRequests.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'No merge requests found',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _mergeRequests.length,
                            itemBuilder: (context, index) {
                              return _buildMergeRequestCard(_mergeRequests[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}