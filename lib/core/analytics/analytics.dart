// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:watching_app_2/core/global/globals.dart';

// class AnalyticsService {
//   final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

//   // Initialize analytics and set up default configurations
//   Future<void> init() async {
//     await _analytics.setAnalyticsCollectionEnabled(true);
//     SMA.logger.logInfo('Analytics initialized');
//   }

//   // Log a custom event
//   Future<void> logEvent({
//     required String name,
//     Map<String, Object>? parameters,
//   }) async {
//     try {
//       await _analytics.logEvent(
//         name: name,
//         parameters: parameters,
//       );
//       SMA.logger.logInfo('Logged event: $name with params: $parameters');
//     } catch (e) {
//       SMA.logger.logError('Failed to log event: $name, error: $e');
//     }
//   }

//   // Log screen view
//   Future<void> logScreenView({
//     required String screenName,
//     String? screenClass,
//   }) async {
//     try {
//       await _analytics.logScreenView(
//         screenName: screenName,
//         screenClass: screenClass,
//       );
//       SMA.logger.logInfo('Logged screen view: $screenName');
//     } catch (e) {
//       SMA.logger.logError('Failed to log screen view: $screenName, error: $e');
//     }
//   }

//   // Log user properties (e.g., user preferences or settings)
//   Future<void> setUserProperty({
//     required String name,
//     required String value,
//   }) async {
//     try {
//       await _analytics.setUserProperty(name: name, value: value);
//       SMA.logger.logInfo('Set user property: $name = $value');
//     } catch (e) {
//       SMA.logger.logError('Failed to set user property: $name, error: $e');
//     }
//   }
// }