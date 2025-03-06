// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:watching_app_2/provider/bottom_navigation_provider.dart';
// import 'package:watching_app_2/provider/favorites_provider.dart';
// import 'package:watching_app_2/provider/source_provider.dart';
// import 'package:sizer/sizer.dart';
// import 'package:watching_app_2/provider/theme_provider.dart';

// import 'core/constants/color_constants.dart';
// import 'core/global/app_global.dart';
// import 'provider/similar_content_provider.dart';
// import 'provider/webview_controller_provider.dart';
// import 'screens/bottom_navigation/bottom_navigation_screen.dart';
// import 'screens/share/share_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//   ]);

//   // Animate back from fullscreen
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//   runApp(MultiProvider(providers: [
//     ChangeNotifierProvider(create: (_) => SourceProvider()),
//     ChangeNotifierProvider(create: (_) => ThemeProvider()),
//     ChangeNotifierProvider(create: (_) => WebviewControllerProvider()),
//     ChangeNotifierProvider(create: (_) => FavoritesProvider()),
//     ChangeNotifierProvider(create: (_) => SimilarContentProvider()),
//     ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
//   ], child: const MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     var themeProvider = context.watch<ThemeProvider>();
//     return ResponsiveSizer(builder: (context, orientation, screenType) {
//       return MaterialApp(
//         title: 'Queen',
//         navigatorKey: SMA.navigationKey,
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.lightTheme,
//         themeMode: themeProvider.theme,
//         darkTheme: AppTheme.darkTheme,
//         home: ShareScreen(),
//       );
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/presentation/provider/navigation_provider.dart';
import 'package:watching_app_2/presentation/provider/favorites_provider.dart';
import 'package:watching_app_2/presentation/provider/source_provider.dart';
import 'package:watching_app_2/presentation/provider/theme_provider.dart';
import 'package:watching_app_2/presentation/provider/similar_content_provider.dart';
import 'package:watching_app_2/presentation/provider/webview_provider.dart';
import 'app.dart';
import 'core/services/network_status_service.dart';
import 'core/services/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Animate back from fullscreen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  setupLocator();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SourceProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()..initializeTheme()),
    ChangeNotifierProvider(create: (_) => WebviewProvider()),
    ChangeNotifierProvider(
        create: (_) => NetworkServiceProvider()..initConnectivity()),
    ChangeNotifierProvider(create: (_) => FavoritesProvider()),
    ChangeNotifierProvider(create: (_) => SimilarContentProvider()),
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
  ], child: const SafeArea(child: MyApp())));
}
