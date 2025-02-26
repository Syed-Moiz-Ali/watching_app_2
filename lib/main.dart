import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/provider/bottom_navigation_provider.dart';
import 'package:watching_app_2/provider/source_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/provider/theme_provider.dart';

import 'core/constants/color_constants.dart';
import 'core/global/app_global.dart';
import 'provider/similar_content_provider.dart';
import 'provider/webview_controller_provider.dart';
import 'screens/bottom_navigation/bottom_navigation_screen.dart';
import 'screens/source_list/source_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Animate back from fullscreen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SourceProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => WebviewControllerProvider()),
    ChangeNotifierProvider(create: (_) => SimilarContentProvider()),
    ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    final MaterialColor blackSwatch = MaterialColor(
      AppColors.primaryColor.value,
      const <int, Color>{
        50: AppColors.primaryColor,
        100: AppColors.primaryColor,
        200: AppColors.primaryColor,
        300: AppColors.primaryColor,
        400: AppColors.primaryColor,
        500: AppColors.primaryColor,
        600: AppColors.primaryColor,
        700: AppColors.primaryColor,
        800: AppColors.primaryColor,
        900: AppColors.primaryColor,
      },
    );
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'PornQueen',
        navigatorKey: SMA.navigationKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: themeProvider.theme,
        darkTheme: AppTheme.darkTheme,
        home: const NavigationScreen(),
      );
    });
  }
}
