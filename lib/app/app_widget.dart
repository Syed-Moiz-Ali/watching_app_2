import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/constants/colors.dart';
import '../core/global/globals.dart';
import '../core/navigation/routes.dart';
import '../presentation/provider/theme_provider.dart';
import '../presentation/themes/app_theme.dart';
import '../presentation/themes/dark_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Future<void> _appInitialization;

  @override
  void initState() {
    super.initState();
    _appInitialization = AppInitializer.initializeApp();
    WidgetsBinding.instance.addObserver(this);
    _enableWakelock();
  }

  @override
  void dispose() {
    _disableWakelock();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enableWakelock();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _disableWakelock();
    }
  }

  Future<void> _enableWakelock() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await WakelockPlus.enable();
      }
    } catch (e) {
      debugPrint('Error enabling wakelock: $e');
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('Error disabling wakelock: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppColors.primaryColor;
    return FutureBuilder(
      future: _appInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return ResponsiveSizer(builder: (context, orientation, screenType) {
          return MaterialApp(
            title: 'BrowseX',
            navigatorKey: SMA.navigationKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: DarkTheme.darkTheme,
            themeMode: context.watch<ThemeProvider>().themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            builder: (context, child) {
              return SafeArea(
                  child: ErrorBoundary(child: child ?? const SizedBox()));
            },
            navigatorObservers: [AnalyticsNavigatorObserver()],
          );
        });
      },
    );
  }
}

class AppInitializer {
  static Future<void> initializeApp() async {
    // Add initialization logic (e.g., SharedPreferences, Firebase)
    await Future.delayed(const Duration(seconds: 0));
  }
}

class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }

  static void reportError(Object error, StackTrace? stackTrace) {
    debugPrint('Error: $error\nStackTrace: $stackTrace');
  }
}

class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint('Pushed route: ${route.settings.name}');
  }
}
