import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Enum to categorise every possible failure coming from the Groq API
enum GroqErrorType {
  none, // No error — successful response
  network, // Timeout or socket/connection exception
  rateLimit, // HTTP 401 (bad key) or 429 (quota exceeded)
  unknown, // Any other non-200 status or empty/garbage response
}

// Service to communicate with Groq AI API as intelligent fallback
class GroqService {
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _model = 'openai/gpt-oss-120b';

  // Sends question to Groq and returns a record of (answer, errorType)
  static Future<({String answer, GroqErrorType errorType})> askGroq(
      String userQuestion) async {
    debugPrint('[GROQ DEBUG] askGroq called for question: "$userQuestion"');

    // Missing key treated as unknown so controller shows appropriate fallback
    if (_apiKey.isEmpty) {
      debugPrint('[GROQ DEBUG] GROQ_API_KEY is missing from .env');
      return (answer: '', errorType: GroqErrorType.unknown);
    }

    final stopwatch = Stopwatch()..start();
    try {
      debugPrint(
          '[GROQ DEBUG] Sending POST request to $_endpoint with model $_model...');

      // Makes the HTTP POST request with a 12-second timeout
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${_apiKey.trim()}',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are Harvey, a helpful farm products assistant for a local farm marketplace app. Answer briefly (2-3 sentences) about fruits, vegetables, nutrition, storage, and farming. If asked about anything unrelated to farming or the app, politely redirect.',
                },
                {
                  'role': 'user',
                  'content': userQuestion,
                },
              ],
              'temperature': 0.7,
              'max_tokens': 200,
            }),
          )
          .timeout(const Duration(seconds: 12));

      stopwatch.stop();
      debugPrint(
          '[GROQ DEBUG] Response time: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('[GROQ DEBUG] Response Status Code: ${response.statusCode}');
      debugPrint('[GROQ DEBUG] Response Body: ${response.body}');

      // Successful 200 response — extract content string
      if (response.statusCode == 200) {
        debugPrint('[GROQ DEBUG] ✅ 200 OK: Successful response received.');
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            data['choices']?[0]?['message']?['content']?.toString().trim();
        if (content != null && content.isNotEmpty) {
          return (answer: content, errorType: GroqErrorType.none);
        }
        // 200 but empty/garbage body — treat as unknown
        debugPrint('[GROQ DEBUG] ⚠️ 200 OK but content was null or empty.');
        return (answer: '', errorType: GroqErrorType.unknown);
      }

      // 401 or 429 — key problem or quota hit
      if (response.statusCode == 401 || response.statusCode == 429) {
        debugPrint(
            '[GROQ DEBUG] ❌ ${response.statusCode}: Auth/rate-limit error.');
        return (answer: '', errorType: GroqErrorType.rateLimit);
      }

      // Any other non-200 status
      debugPrint(
          '[GROQ DEBUG] ❌ ERROR: Received status code ${response.statusCode}');
      return (answer: '', errorType: GroqErrorType.unknown);
    } on TimeoutException catch (e) {
      // Request timed out after 12 seconds
      stopwatch.stop();
      debugPrint(
          '[GROQ DEBUG] ❌ TimeoutException after ${stopwatch.elapsedMilliseconds}ms: $e');
      return (answer: '', errorType: GroqErrorType.network);
    } catch (e) {
      // Socket errors, no-internet, DNS failures etc.
      stopwatch.stop();
      debugPrint(
          '[GROQ DEBUG] ❌ Exception after ${stopwatch.elapsedMilliseconds}ms: $e');
      return (answer: '', errorType: GroqErrorType.network);
    }
  }
}
