import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../error/exceptions.dart';
import '../../logger/app_logger.dart';

abstract class AimlService {
  Future<String> complete({
    required String apiKey,
    required String systemPrompt,
    required String userPrompt,
    String model = 'gpt-4o',
  });
}

class AimlServiceImpl implements AimlService {
  final String baseUrl;

  AimlServiceImpl({required this.baseUrl});

  @override
  Future<String> complete({
    required String apiKey,
    required String systemPrompt,
    required String userPrompt,
    String model = 'gpt-4o',
  }) async {
    final url = Uri.parse('$baseUrl/chat/completions');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'max_tokens': 2000,
      'temperature': 0.3,
    });

    int retryCount = 0;
    const maxRetries = 3;
    final delayDurations = [
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 4),
    ];

    while (true) {
      try {
        AppLogger.instance.i('AIMLAPI Request: Model $model, Retry $retryCount');
        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final content = decoded['choices'][0]['message']['content'] as String;
          return content;
        } else {
          AppLogger.instance.w(
              'AIMLAPI HTTP Error: Status ${response.statusCode}, Body: ${response.body}');
          throw ServerException(
              'AIMLAPI server returned status ${response.statusCode}',
              response.statusCode.toString());
        }
      } catch (e) {
        AppLogger.instance.e('AIMLAPI Error: $e');
        if (retryCount >= maxRetries - 1) {
          if (e is ServerException) rethrow;
          throw ServerException('Failed to connect to AIMLAPI: ${e.toString()}');
        }
        // Wait with backoff
        await Future.delayed(delayDurations[retryCount]);
        retryCount++;
      }
    }
  }
}
