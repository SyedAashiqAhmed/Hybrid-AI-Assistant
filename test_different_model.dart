import 'dart:convert';
import 'dart:io';

/// Test with gemini-2.5-flash model (might have different quota)
void main() async {
  print('🧪 Testing Gemini API with different model...\n');

  const apiKey = 'AIzaSyCYDmt4DgneIficnxdP8i8PRRRgI0lRyEk';
  const model = 'gemini-2.5-flash';  // Trying different model
  
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey'
  );

  print('📡 Model: $model\n');
  print('❓ Question: "Hello, are you working?"\n');

  final requestBody = {
    'contents': [
      {
        'parts': [
          {'text': 'Hello, are you working? Reply with just "Yes" or "No".'}
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
      
      print('✅ SUCCESS! Gemini API is WORKING!\n');
      print('🤖 AI Response:');
      print('─' * 50);
      print(aiResponse);
      print('─' * 50);
      print('\n🎉 Your API is fully functional!');
      print('\nNow you can run: flutter run');
    } else if (response.statusCode == 429) {
      print('⚠️  RATE LIMIT (429) - Still quota exceeded\n');
      print('This API key also has quota limits.');
      print('\n📋 RECOMMENDATION:');
      print('Demo your project with SYSTEM COMMANDS (they work perfectly!)');
      print('Check DEMO_WITHOUT_AI.md for the demo script.');
    } else {
      print('Status: ${response.statusCode}\n');
      print('Response:');
      print(responseBody);
    }
    
    client.close();
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
