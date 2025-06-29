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

void main() {
  group('App Integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App starts with splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: const LabbyApp(),
        ),
      );

      // Verify initial splash screen elements are immediately visible
      expect(find.text('Labby'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.account_tree), findsOneWidget);

      // Just pump once to complete the initial frame render
      await tester.pump();
    });

    testWidgets('SplashScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => ThemeProvider(),
            child: const SplashScreen(),
          ),
        ),
      );

      expect(find.text('Labby'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.account_tree), findsOneWidget);

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.account_tree));
      expect(iconWidget.size, 80);

      // Just pump once to complete the initial frame render
      await tester.pump();
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
