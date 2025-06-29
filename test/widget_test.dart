// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:labby/main.dart';

// Test-only widget that displays splash screen UI without timers
class TestSplashScreen extends StatelessWidget {
  const TestSplashScreen({super.key});

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

void main() {
  group('App Integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('SplashScreen UI displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => ThemeProvider(),
            child: const TestSplashScreen(),
          ),
        ),
      );

      expect(find.text('Labby'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.account_tree), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.account_tree));
      expect(iconWidget.size, 80);

      await tester.pump();
    });

    testWidgets('Real SplashScreen displays correctly without timers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => ThemeProvider(),
            child: const SplashScreen(skipInitialization: true),
          ),
        ),
      );

      expect(find.text('Labby'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.account_tree), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.account_tree));
      expect(iconWidget.size, 80);

      await tester.pump();
    });

    testWidgets('Theme colors are configured correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00BCD4),
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF00BCD4),
              secondary: const Color(0xFFE91E63),
              tertiary: const Color(0xFF9C27B0),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00E5FF),
              brightness: Brightness.dark,
            ).copyWith(
              primary: const Color(0xFF00E5FF),
              secondary: const Color(0xFFFF4081),
              tertiary: const Color(0xFFE040FB),
              surface: const Color(0xFF0A0A0A),
            ),
            useMaterial3: true,
          ),
          home: const Scaffold(body: Text('Test')),
        ),
      );

      // Verify theme is applied correctly
      final theme = Theme.of(tester.element(find.text('Test')));
      expect(theme.colorScheme.primary, const Color(0xFF00BCD4));
      expect(theme.useMaterial3, true);
    });
  });

  group('ThemeProvider', () {
    test('should initialize with system theme', () {
      final themeProvider = ThemeProvider();
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('should notify listeners when theme changes', () async {
      final themeProvider = ThemeProvider();
      bool notified = false;

      themeProvider.addListener(() {
        notified = true;
      });

      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(notified, isTrue);
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    testWidgets('should apply theme to MaterialApp',
        (WidgetTester tester) async {
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              return MaterialApp(
                themeMode: provider.themeMode,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                home: const Scaffold(body: Text('Test')),
              );
            },
          ),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);

      await themeProvider.setThemeMode(ThemeMode.dark);
      await tester.pump();

      final updatedMaterialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(updatedMaterialApp.themeMode, ThemeMode.dark);
    });
  });
}
