import 'dart:convert';
import 'dart:io';

/// Standalone Gemini API Test Script
/// Run with: dart run test_gemini_api.dart
void main() async {
  print('🧪 Testing Gemini API Connection...\n');

  const apiKey = 'YOUR_API_KEY_HERE';
  const model = 'gemini-2.0-flash-lite';  // Updated to available model
  
  // Using v1 API endpoint
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey'
  );

  print('📡 Endpoint: $url\n');

  final requestBody = {
    'contents': [
      {
        'parts': [
          {'text': 'Hello! Are you working?'}
        ]
      }
    ]
  };

  try {
    print('⏳ Sending request...\n');
    
    final client = HttpClient();
    final request = await client.postUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(requestBody));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('📊 Status Code: ${response.statusCode}\n');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
      
      print('✅ SUCCESS! Gemini API is working!\n');
      print('🤖 AI Response:');
      print('─' * 50);
      print(aiResponse);
      print('─' * 50);
    } else {
      print('❌ FAILED! Status: ${response.statusCode}\n');
      print('Response Body:');
      print(responseBody);
    }
    
    client.close();
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
