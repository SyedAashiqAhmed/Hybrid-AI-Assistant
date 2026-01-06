import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Gemini AI Service
/// Handles all communication with Google's Gemini FREE API
/// 
/// IMPORTANT: This service is ONLY used when Intent Engine determines
/// the query requires AI (not a system command)
class GeminiService {
  final String _apiKey = AppConfig.geminiApiKey;
  final String _model = AppConfig.geminiModel;

  /// Conversation history for context
  final List<Map<String, dynamic>> _conversationHistory = [];

  /// Generate AI response from user query
  Future<String> generateResponse(String userQuery) async {
    
    try {
      // Add user message to history
      _conversationHistory.add({
        'role': 'user',
        'parts': [{'text': userQuery}],
      });

      // Prepare request - Using v1 API endpoint
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/$_model:generateContent?key=$_apiKey'
      );
      
      final requestBody = {
        'contents': _conversationHistory,
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
        ],
      };

      // Make API call
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract AI response
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          final content = candidate['content'];
          final parts = content['parts'];
          
          if (parts != null && parts.isNotEmpty) {
            final aiResponse = parts[0]['text'] ?? 'No response generated.';
            
            // Add AI response to history
            _conversationHistory.add({
              'role': 'model',
              'parts': [{'text': aiResponse}],
            });

            // Limit history size to prevent token overflow
            if (_conversationHistory.length > 20) {
              _conversationHistory.removeRange(0, _conversationHistory.length - 20);
            }

            return aiResponse;
          }
        }

        return 'Sorry, I couldn\'t generate a response. Please try again.';
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        return 'API Error: ${error['error']['message'] ?? 'Bad request'}';
      } else if (response.statusCode == 403) {
        return 'API Key Error: Please check your Gemini API key in app_config.dart';
      } else if (response.statusCode == 429) {
        return 'Rate limit exceeded. Please wait a moment and try again.';
      } else {
        return 'Server error (${response.statusCode}). Please try again later.';
      }
    } catch (e) {
      // Handle different types of errors
      if (e.toString().contains('SocketException') || 
          e.toString().contains('NetworkException')) {
        return '❌ No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('timeout')) {
        return '⏱️ Request timed out. Please try again.';
      } else {
        return '❌ Error: ${e.toString()}';
      }
    }
  }

  /// Generate response with system context
  Future<String> generateResponseWithContext(String userQuery, String systemContext) async {
    final contextualQuery = '$systemContext\n\nUser query: $userQuery';
    return generateResponse(contextualQuery);
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// Get conversation history length
  int get historyLength => _conversationHistory.length;

  /// Check if API is working (for testing)
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/$_model:generateContent?key=$_apiKey'
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Hello'}
              ]
            }
          ],
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get API status message
  Future<String> getApiStatus() async {
    final isWorking = await testConnection();
    if (isWorking) {
      return '✅ Gemini API is working correctly!';
    } else {
      return '❌ Gemini API connection failed. Please check:\n'
             '1. Your API key\n'
             '2. Internet connection\n'
             '3. API quota limits';
    }
  }
}
