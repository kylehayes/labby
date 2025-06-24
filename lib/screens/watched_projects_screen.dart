import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gitlab_project.dart';
import '../services/gitlab_api_service.dart';
import '../services/config_service.dart';
import '../main.dart';

class WatchedProjectsScreen extends StatefulWidget {
  const WatchedProjectsScreen({super.key});

  @override
  State<WatchedProjectsScreen> createState() => _WatchedProjectsScreenState();
}

class _WatchedProjectsScreenState extends State<WatchedProjectsScreen> {
  List<GitLabProject> _allProjects = [];
  List<int> _watchedProjectIds = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  GitLabApiService? _apiService;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final url = await ConfigService.getGitLabUrl();
    final token = await ConfigService.getGitLabToken();
    
    if (url != null && token != null) {
      _apiService = GitLabApiService(baseUrl: url, token: token);
      await _loadWatchedProjects();
      _loadProjects();
    }
  }

  Future<void> _loadWatchedProjects() async {
    final watchedIds = await ConfigService.getWatchedProjects();
    setState(() {
      _watchedProjectIds = watchedIds;
    });
  }

  Future<void> _loadProjects() async {
    if (_apiService == null) return;

    setState(() => _isLoading = true);

    try {
      final groupId = await ConfigService.getGitLabGroup();
      final projects = await _apiService!.getProjects(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        groupId: groupId,
        perPage: 100, // Load more projects for selection
      );
      setState(() {
        _allProjects = projects;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading projects: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleProjectWatch(GitLabProject project) async {
    final isWatched = _watchedProjectIds.contains(project.id);
    
    if (isWatched) {
      await ConfigService.removeWatchedProject(project.id);
    } else {
      await ConfigService.addWatchedProject(project.id);
    }
    
    await _loadWatchedProjects();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadProjects();
  }

  Widget _buildProjectTile(GitLabProject project) {
    final isWatched = _watchedProjectIds.contains(project.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isWatched 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            isWatched ? Icons.visibility : Icons.visibility_off,
            color: isWatched 
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          project.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isWatched ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: project.description?.isNotEmpty == true
            ? Text(
                project.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : Text(
                project.nameWithNamespace,
                style: Theme.of(context).textTheme.bodySmall,
              ),
        trailing: Switch(
          value: isWatched,
          onChanged: (_) => _toggleProjectWatch(project),
        ),
        onTap: () => _toggleProjectWatch(project),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Projects'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select projects to watch for merge requests. You\'ll see merge requests from these projects in addition to your personal assigned/created MRs.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search projects',
                    hintText: 'Enter project name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 8),
                if (_watchedProjectIds.isNotEmpty)
                  Text(
                    'Watching ${_watchedProjectIds.length} project${_watchedProjectIds.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadProjects,
                    child: _allProjects.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'No projects found',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _allProjects.length,
                            itemBuilder: (context, index) {
                              return _buildProjectTile(_allProjects[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}