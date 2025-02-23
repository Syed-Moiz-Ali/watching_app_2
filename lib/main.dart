import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/provider/source_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/provider/theme_provider.dart';

import 'core/constants/color_constants.dart';
import 'core/global/app_global.dart';
import 'provider/webview_controller_provider.dart';
import 'screens/source_list/source_list_screen.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SourceProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => WebviewControllerProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'PornQueen',
        navigatorKey: SMA.navigationKey,
        debugShowCheckedModeBanner: false,
        home: const SourceListScreen(),
      );
    });
  }
}
