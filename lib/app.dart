// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// import 'core/global/globals.dart';
// import 'core/navigation/routes.dart';
// import 'presentation/provider/theme_provider.dart';
// import 'presentation/themes/app_theme.dart';
// import 'presentation/themes/dark_theme.dart';

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     // Enable wake lock when the app starts
//     WakelockPlus.enable();
//     // Add observer to monitor app lifecycle
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     // Disable wake lock when the widget is disposed
//     WakelockPlus.disable();
//     // Remove observer
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       WakelockPlus.enable(); // Re-enable when app resumes
//     } else if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached) {
//       WakelockPlus.disable(); // Disable when app is paused or detached
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var themeProvider = context.watch<ThemeProvider>();
//     return ResponsiveSizer(builder: (context, orientation, screenType) {
//       return MaterialApp(
//         title: 'BrowseX',
//         navigatorKey: SMA.navigationKey,
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.lightTheme, // Light theme
//         darkTheme: DarkTheme.darkTheme, // Dark theme
//         themeMode: themeProvider.themeMode, // Use ThemeMode from provider
//         initialRoute: AppRoutes.home,
//         onGenerateRoute: AppRoutes.generateRoute,
//       );
//     });
//   }
// }
