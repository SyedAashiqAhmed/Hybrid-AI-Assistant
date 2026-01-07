import 'dart:convert';
import 'dart:io';

/// Final test - Ask a real question to verify AI is working
void main() async {
  print('🎉 FINAL API TEST\n');

  const apiKey = 'YOUR_API_KEY_HERE';
  const model = 'gemini-2.5-flash';
  
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey'
  );

  print('❓ Question: "Explain binary search in one sentence."\n');

  final requestBody = {
    'contents': [
      {
        'parts': [
          {'text': 'Explain binary search algorithm in one sentence.'}
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
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
      
      print('✅ SUCCESS! Your Gemini AI is FULLY WORKING!\n');
      print('🤖 AI Response:');
      print('─' * 60);
      print(aiResponse);
      print('─' * 60);
      print('\n🎉 CONGRATULATIONS!');
      print('Your Hybrid AI Assistant is ready!');
      print('\n📱 Run your app now:');
      print('   flutter run');
      print('\n💡 Try these in the app:');
      print('   • "Turn on flashlight"');
      print('   • "Change to dark mode"');
      print('   • "Explain recursion"');
      print('   • "Help me with C++ pointers"');
    } else {
      print('Status: ${response.statusCode}');
      print(responseBody);
    }
    
    client.close();
  } catch (e) {
    print('Error: $e');
  }
}
