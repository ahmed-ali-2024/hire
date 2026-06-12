import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../error/exceptions.dart';
import '../../logger/app_logger.dart';

abstract class BandService {
  Future<String> createRoom({
    required String apiKey,
    required String sessionId,
    required String candidateId,
  });

  Future<void> sendMessage({
    required String apiKey,
    required String roomId,
    required String sessionId,
    required String candidateId,
    required String type,
    required String senderAgent,
    required String receiverAgent,
    required Map<String, dynamic> payload,
  });

  Future<List<Map<String, dynamic>>> getMessages({
    required String apiKey,
    required String roomId,
  });
}

class BandServiceImpl implements BandService {
  final String baseUrl;
  final SupabaseClient _supabaseClient;

  BandServiceImpl({
    required this.baseUrl,
    SupabaseClient? supabaseClient,
  }) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<String> createRoom({
    required String apiKey,
    required String sessionId,
    required String candidateId,
  }) async {
    final url = Uri.parse('$baseUrl/rooms');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'name': 'session_${sessionId}_candidate_$candidateId',
    });

    try {
      AppLogger.instance.i('BandAPI: Creating room for candidate $candidateId');
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return decoded['room_id'] as String;
      } else {
        AppLogger.instance.w(
            'BandAPI createRoom HTTP Error: Status ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            'Failed to create Band room: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.instance.e('BandAPI createRoom Error: $e');
      throw ServerException('Failed to connect to Band API: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMessage({
    required String apiKey,
    required String roomId,
    required String sessionId,
    required String candidateId,
    required String type,
    required String senderAgent,
    required String receiverAgent,
    required Map<String, dynamic> payload,
  }) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId/messages');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'type': type,
      'sender': senderAgent,
      'receiver': receiverAgent,
      'payload': payload,
    });

    try {
      AppLogger.instance.i('BandAPI: Sending message to room $roomId');
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Logging message to Supabase log table for real-time panel support
        await _supabaseClient.from('band_messages_log').insert({
          'room_id': roomId,
          'session_id': sessionId,
          'candidate_id': candidateId,
          'message_type': type,
          'sender_agent': senderAgent,
          'receiver_agent': receiverAgent,
          'payload': payload,
        });
        AppLogger.instance.i('BandAPI: Message logged successfully to Supabase');
      } else {
        AppLogger.instance.w(
            'BandAPI sendMessage HTTP Error: Status ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            'Failed to send message via Band API: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.instance.e('BandAPI sendMessage Error: $e');
      throw ServerException(
          'Failed to send message or log in Supabase: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages({
    required String apiKey,
    required String roomId,
  }) async {
    final url = Uri.parse('$baseUrl/rooms/$roomId/messages');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    try {
      AppLogger.instance.i('BandAPI: Getting messages for room $roomId');
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
        return [];
      } else {
        AppLogger.instance.w(
            'BandAPI getMessages HTTP Error: Status ${response.statusCode}, Body: ${response.body}');
        throw ServerException(
            'Failed to get messages from Band API: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.instance.e('BandAPI getMessages Error: $e');
      throw ServerException(
          'Failed to get messages from Band API: ${e.toString()}');
    }
  }
}
