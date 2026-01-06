import 'dart:convert';
import 'dart:io';

/// List available Gemini models
void main() async {
  print('🔍 Checking available Gemini models...\n');

  const apiKey = 'AIzaSyBRNFZ8jXFRoZSo8D1mnX0V--ZLmd93tiY';
  
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1/models?key=$apiKey'
  );

  try {
    final client = HttpClient();
    final request = await client.getUrl(url);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Status: ${response.statusCode}\n');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('✅ Available Models:\n');
      
      for (var model in data['models']) {
        final name = model['name'];
        final supportedMethods = model['supportedGenerationMethods'];
        print('📦 $name');
        print('   Methods: $supportedMethods\n');
      }
    } else {
      print('Response: $responseBody');
    }
    
    client.close();
  } catch (e) {
    print('Error: $e');
  }
}
