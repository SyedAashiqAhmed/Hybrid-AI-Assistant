import 'package:flutter_test/flutter_test.dart';
import 'package:hybrid_ai_assistant/services/gemini_service.dart';
import 'package:hybrid_ai_assistant/services/intent_engine.dart';
import 'package:hybrid_ai_assistant/models/intent.dart';

void main() {
  group('Intent Engine Tests', () {
    late IntentEngine intentEngine;

    setUp(() {
      intentEngine = IntentEngine();
    });

    test('Detect flashlight ON intent', () {
      final intent = intentEngine.detectIntent('turn on flashlight');
      expect(intent.type, IntentType.flashlightOn);
    });

    test('Detect flashlight OFF intent', () {
      final intent = intentEngine.detectIntent('turn off flashlight');
      expect(intent.type, IntentType.flashlightOff);
    });

    test('Detect theme change intent', () {
      final intent = intentEngine.detectIntent('change to dark mode');
      expect(intent.type, IntentType.themeChange);
      expect(intent.parameters['theme'], 'dark');
    });

    test('Detect URL opening intent', () {
      final intent = intentEngine.detectIntent('open youtube.com');
      expect(intent.type, IntentType.openUrl);
      expect(intent.parameters['url'], 'youtube.com');
      expect(intent.parameters['isWhitelisted'], true);
    });

    test('Detect AI query intent', () {
      final intent = intentEngine.detectIntent('explain binary search');
      expect(intent.type, IntentType.aiQuery);
    });

    test('Block non-whitelisted URL', () {
      final intent = intentEngine.detectIntent('open malicious-site.com');
      if (intent.type == IntentType.openUrl) {
        expect(intent.parameters['isWhitelisted'], false);
      }
    });
  });

  group('Gemini Service Tests', () {
    late GeminiService geminiService;

    setUp(() {
      geminiService = GeminiService();
    });

    test('Test API connection', () async {
      final isWorking = await geminiService.testConnection();
      print('Gemini API Status: ${isWorking ? "✅ Working" : "❌ Failed"}');
      // Note: This test requires internet connection
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('Generate simple response', () async {
      final response = await geminiService.generateResponse('Say hello');
      print('AI Response: $response');
      expect(response, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
