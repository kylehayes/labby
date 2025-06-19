import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/config_service.dart';
import 'services/status_bar_service.dart';
import 'screens/project_list_screen.dart';
import 'screens/config_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const LabbyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemeMode() async {
    final savedTheme = await ConfigService.getThemeMode();
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await ConfigService.setThemeMode(mode.name);
    notifyListeners();
  }
}

class LabbyApp extends StatelessWidget {
  const LabbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Labby',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00BCD4), // Cyan/Teal
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF00BCD4), // Cyan
              secondary: const Color(0xFFE91E63), // Magenta/Pink
              tertiary: const Color(0xFF9C27B0), // Purple
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00E5FF), // Bright Cyan
              brightness: Brightness.dark,
            ).copyWith(
              primary: const Color(0xFF00E5FF), // Bright Cyan
              secondary: const Color(0xFFFF4081), // Hot Pink
              tertiary: const Color(0xFFE040FB), // Bright Purple
              surface: const Color(0xFF0A0A0A), // Deep black
              background: const Color(0xFF0A0A0A), // Deep black
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  Future<void> _checkConfiguration() async {
    // Initialize status bar service
    await StatusBarService.initialize();
    
    // Load theme preference first
    if (mounted) {
      await Provider.of<ThemeProvider>(context, listen: false).loadThemeMode();
    }
    
    await Future.delayed(const Duration(seconds: 1));
    
    final hasConfig = await ConfigService.hasConfiguration();
    
    if (mounted) {
      if (hasConfig) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProjectListScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ConfigScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Labby',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
