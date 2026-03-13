import 'package:logger/logger.dart' as log_pkg; // Alias to avoid conflict
import 'package:flutter/foundation.dart';

class Logger {
  // Create a single internal instance from the package
  static final _internalLogger = log_pkg.Logger(
    printer: log_pkg.PrettyPrinter(
      methodCount: 0, // Set to 2 if you want to see the file/line number
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
    // This ensures logs only show up while you are debugging
    filter: log_pkg.DevelopmentFilter(),
  );

  // Map your existing methods to the new package levels
  static void info(String tag, String message) {
    _internalLogger.i('[$tag] $message');
  }

  static void warn(String tag, String message) {
    _internalLogger.w('[$tag] $message');
  }

  static void error(String tag, String message) {
    _internalLogger.e('[$tag] $message');
  }
}
