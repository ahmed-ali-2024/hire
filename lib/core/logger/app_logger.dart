import 'dart:developer' as dev;

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  void i(String message) => _log('INFO', message);
  void d(String message) => _log('DEBUG', message);
  void w(String message) => _log('WARN', message);
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _log('ERROR', message, error, stackTrace);

  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    dev.log('[$level] $timestamp: $message', error: error, stackTrace: stackTrace);
  }
}
