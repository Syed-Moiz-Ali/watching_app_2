import 'package:get_it/get_it.dart';
import 'logger.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<LoggingService>(() => LoggingService());
}
