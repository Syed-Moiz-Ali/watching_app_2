import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'core/constants/color_constants.dart';
import 'core/global/app_global.dart';
import 'core/navigation/routes.dart';
import 'presentation/provider/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeProvider = context.watch<ThemeProvider>();
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'Queen',
        navigatorKey: SMA.navigationKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: themeProvider.theme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      );
    });
  }
}
