import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/app/app_widget.dart';
import 'package:watching_app_2/core/global/globals.dart';
import 'package:watching_app_2/presentation/provider/manga_detail_provider.dart';
import 'package:watching_app_2/presentation/provider/navigation_provider.dart';
import 'package:watching_app_2/presentation/provider/favorites_provider.dart';
import 'package:watching_app_2/presentation/provider/search_provider.dart';
import 'package:watching_app_2/presentation/provider/source_provider.dart';
import 'package:watching_app_2/presentation/provider/theme_provider.dart';
import 'package:watching_app_2/presentation/provider/similar_content_provider.dart';
import 'package:watching_app_2/presentation/provider/webview_provider.dart';
import 'package:watching_app_2/shared/provider/local_auth_provider.dart';
import 'app/app_config_provider.dart';
import 'core/services/network_status_service.dart';
import 'core/services/service_locator.dart';
import 'shared/widgets/misc/custom_error_screen.dart';
import 'shared/widgets/misc/restart_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SMA.initializePref();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorScreen(errorDetails: details);
  };

  // Set up error reporting for uncaught exceptions
  FlutterError.onError = (details) {
    ErrorBoundary.reportError(details.exception, details.stack);
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Animate back from fullscreen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  setupLocator();
  runApp(
    RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SourceProvider()),
          ChangeNotifierProvider(
              create: (_) => ThemeProvider()..initializeTheme()),
          ChangeNotifierProvider(create: (_) => WebviewProvider()),
          ChangeNotifierProvider(
              create: (_) => NetworkServiceProvider()..initConnectivity()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => SimilarContentProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
          ChangeNotifierProvider(
              create: (_) => LocalAuthProvider()..loadPreferences()),
          ChangeNotifierProvider(create: (_) => MangaDetailProvider()),
          ChangeNotifierProvider(create: (_) => AppConfigProvider()),
        ],
        child: const SafeArea(
          child: MyApp(),
        ),
      ),
    ),
  );
}
