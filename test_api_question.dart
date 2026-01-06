import 'dart:convert';
import 'dart:io';

/// Test Gemini API by asking a simple question
void main() async {
  print('🧪 Testing Gemini API with a real question...\n');

  const apiKey = 'AIzaSyCYDmt4DgneIficnxdP8i8PRRRgI0lRyEk';  // LATEST API KEY
  const model = 'gemini-2.0-flash-lite';
  
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey'
  );

  print('📡 Endpoint: $url\n');
  print('❓ Question: "What is 2 + 2? Give a short answer."\n');

  final requestBody = {
    'contents': [
      {
        'parts': [
          {'text': 'What is 2 + 2? Give a short answer.'}
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
      print('\n✨ The API is functioning correctly!');
    } else if (response.statusCode == 429) {
      print('⚠️  RATE LIMIT EXCEEDED (429)\n');
      print('This means the API is working, but the quota has been used up.');
      print('The free tier has limits on requests per minute.\n');
      print('Solutions:');
      print('1. Wait 1 hour for quota to reset');
      print('2. Get a fresh API key from https://aistudio.google.com/apikey');
      print('\nNote: This is EXPECTED behavior for free tier! ✅');
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
