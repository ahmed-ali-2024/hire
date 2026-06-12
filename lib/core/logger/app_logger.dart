import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();
  
  static final AppLogger instance = AppLogger._();

  void d(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'DEBUG', level: 500, error: error, stackTrace: stackTrace);
  }

  void i(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'INFO', level: 800, error: error, stackTrace: stackTrace);
  }

  void w(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'WARNING', level: 900, error: error, stackTrace: stackTrace);
  }

  void e(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'ERROR', level: 1000, error: error, stackTrace: stackTrace);
  }
}
