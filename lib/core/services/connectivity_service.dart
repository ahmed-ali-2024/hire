import 'package:http/http.dart' as http;

abstract class ConnectivityService {
  Future<bool> get isConnected;
}

class ConnectivityServiceImpl implements ConnectivityService {
  const ConnectivityServiceImpl();

  @override
  Future<bool> get isConnected async {
    try {
      // We perform a quick HEAD request to verify real connection.
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}
