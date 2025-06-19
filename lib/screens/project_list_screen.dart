import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gitlab_project.dart';
import '../services/gitlab_api_service.dart';
import '../services/config_service.dart';
import '../main.dart';
import 'pipeline_list_screen.dart';
import 'config_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<GitLabProject> _projects = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  GitLabApiService? _apiService;

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
      _loadProjects();
    }
  }

  Future<void> _loadProjects() async {
    if (_apiService == null) return;

    setState(() => _isLoading = true);

    try {
      final groupId = await ConfigService.getGitLabGroup();
      final projects = await _apiService!.getProjects(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        groupId: groupId,
      );
      
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    if (query.isEmpty || query.length >= 3) {
      _loadProjects();
    }
  }

  Future<void> _navigateToConfig() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ConfigScreen()),
    );
    
    if (result == true) {
      _initializeApiService();
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? This will clear all your saved settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ConfigService.clearConfiguration();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ConfigScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitLab Projects'),
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToConfig,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search projects',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _projects.isEmpty
                    ? const Center(
                        child: Text(
                          'No projects found',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _projects.length,
                        itemBuilder: (context, index) {
                          final project = _projects[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(
                                project.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(project.nameWithNamespace),
                                  if (project.description != null && project.description!.isNotEmpty)
                                    Text(
                                      project.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  project.name.isNotEmpty 
                                      ? project.name[0].toUpperCase() 
                                      : '?',
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PipelineListScreen(
                                      project: project,
                                      apiService: _apiService!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiService?.dispose();
    super.dispose();
  }
}