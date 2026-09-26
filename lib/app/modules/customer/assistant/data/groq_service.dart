import 'dart:convert';
import 'package:http/http.dart' as http;

// Service to communicate with Groq AI API as intelligent fallback
class GroqService {
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _apiKey = String.fromEnvironment('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');
  static const String _model = 'llama-3.1-8b-instant';
  static const String _fallbackMessage =
      "Sorry, I couldn't find an answer right now. Please try rephrasing or check your connection.";

  // Sends question to Groq API and returns brief answer or fallback
  static Future<String> askGroq(String userQuestion) async {
    if (_apiKey.isEmpty) {
      return _fallbackMessage;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a helpful farm products assistant for a local farm marketplace app. Answer briefly (2-3 sentences) about fruits, vegetables, nutrition, storage, and farming. If asked about anything unrelated to farming or the app, politely redirect.',
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

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices']?[0]?['message']?['content']?.toString().trim();
        if (content != null && content.isNotEmpty) {
          return content;
        }
      }
      return _fallbackMessage;
    } catch (_) {
      return _fallbackMessage;
    }
  }
}
