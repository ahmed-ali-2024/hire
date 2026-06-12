import 'package:flutter/services.dart';
import '../logger/app_logger.dart';

class EnvironmentConfig {
  static final EnvironmentConfig instance = EnvironmentConfig._();
  EnvironmentConfig._();

  final Map<String, String> _config = {};

  Future<void> init() async {
    try {
      final content = await rootBundle.loadString('.env');
      final lines = content.split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          _config[key] = value;
        }
      }
      AppLogger.instance.i('EnvironmentConfig: Loaded ${_config.length} variables.');
    } catch (e) {
      AppLogger.instance.w('EnvironmentConfig: Could not load .env file from assets: $e. Utilizing fallbacks.');
    }
  }

  String get(String key, [String fallback = '']) {
    return _config[key] ?? String.fromEnvironment(key, defaultValue: fallback);
  }

  String get env => get('ENVIRONMENT', 'development');
  String get supabaseUrl => get('SUPABASE_URL', 'https://fedbxlfyrtwctmyolioq.supabase.co');
  String get supabaseAnonKey => get('SUPABASE_ANON_KEY');
  String get aimlBaseUrl => get('AIMLAPI_BASE_URL', 'https://api.aimlapi.com/v1');
  String get featherlessBaseUrl => get('FEATHERLESS_BASE_URL', 'https://api.featherless.ai/v1');
  String get bandApiUrl => get('BAND_API_URL', 'https://api.band.ai/v1');
}
