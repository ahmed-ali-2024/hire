import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class ConnectivityService {
  Future<bool> get isConnected;
}

class ConnectivityServiceImpl implements ConnectivityService {
  const ConnectivityServiceImpl();

  @override
  Future<bool> get isConnected async {
    if (kIsWeb) {
      // On web, external HEAD requests fail due to CORS.
      // Since the web app itself is loaded and running in the browser, 
      // we can safely assume connection is available.
      return true;
    }
    try {
      // Mobile/Desktop fallback using a quick HEAD ping
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}
