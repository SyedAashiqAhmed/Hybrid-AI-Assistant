/// App Configuration File
/// Contains all constants, API keys, and configuration settings
class AppConfig {
  // Gemini API Configuration
  // Get your API key from: https://aistudio.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_API_KEY_HERE';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String geminiModel = 'gemini-2.5-flash';  // ✅ TESTED AND WORKING!
  
  // App Settings
  static const String appName = 'Astralite';
  static const String appVersion = '1.0.0';
  
  // System Command Keywords (for rule-based detection)
  static const List<String> flashlightOnKeywords = [
    'flashlight on',
    'torch on',
    'turn on flashlight',
    'turn on torch',
    'light on',
    'enable flashlight',
  ];
  
  static const List<String> flashlightOffKeywords = [
    'flashlight off',
    'torch off',
    'turn off flashlight',
    'turn off torch',
    'light off',
    'disable flashlight',
  ];
  
  static const List<String> themeChangeKeywords = [
    'change theme',
    'dark mode',
    'light mode',
    'switch theme',
    'toggle theme',
    'dark theme',
    'light theme',
  ];
  
  static const List<String> urlOpenKeywords = [
    'open',
    'browse',
    'go to',
    'visit',
    'navigate to',
    
  ];
  
  // Timer and Alarm Keywords
  static const List<String> setTimerKeywords = [
    'set timer',
    'start timer',
    'timer for',
    'countdown',
    'remind me in',
  ];
  
  static const List<String> cancelTimerKeywords = [
    'cancel timer',
    'stop timer',
    'delete timer',
    'remove timer',
  ];
  
  static const List<String> setAlarmKeywords = [
    'set alarm',
    'wake me up',
    'alarm for',
    'set wake up',
  ];
  
  static const List<String> showAlarmsKeywords = [
    'show alarms',
    'list alarms',
    'my alarms',
    'check alarms',
  ];
  
  static const List<String> setReminderKeywords = [
    'remind me',
    'reminder',
    'set reminder',
    'create reminder',
  ];
  
  static const List<String> showRemindersKeywords = [
    'show reminders',
    'list reminders',
    'my reminders',
    'check reminders',
  ];
  
  
  // Phone Call Keywords
  static const List<String> makeCallKeywords = [
    'call',
    'dial',
    'phone',
    'make a call',
    'call now',
    'dial now',
  ];
  
  static const List<String> scheduleCallKeywords = [
    'schedule call',
    'call in',
    'phone call in',
    'dial in',
    'make a call in',
    'set call for',
  ];
  
  static const List<String> showScheduledCallsKeywords = [
    'show scheduled calls',
    'list scheduled calls',
    'my scheduled calls',
    'check scheduled calls',
    'pending calls',
  ];
  
  static const List<String> cancelScheduledCallKeywords = [
    'cancel scheduled call',
    'cancel call',
    'remove scheduled call',
    'delete scheduled call',
  ];
  
  // Whitelisted domains for URL opening (security)
  static const List<String> whitelistedDomains = [
    'google.com',
    'youtube.com',
    'github.com',
    'stackoverflow.com',
    'flutter.dev',
    'dart.dev',
    'wikipedia.org',
    'geeksforgeeks.org',
    'leetcode.com',
    'w3schools.com',
  ];
  
  // AI Context Prompt (to guide Gemini's behavior)
  static const String systemPrompt = '''
You are a helpful AI study assistant for students. Your primary role is to:
1. Help with programming concepts (C, C++, Java, Flutter, DSA)
2. Explain academic concepts clearly
3. Assist with debugging and error explanations
4. Provide study tips and learning resources
5. Answer questions in a friendly, educational manner

Keep responses concise, clear, and student-friendly. Use examples when explaining concepts.
If asked about device functions (flashlight, theme, etc.), politely inform that these are handled by the system.
''';
  
  // TTS Settings
  static const double ttsDefaultVolume = 0.8;
  static const double ttsDefaultRate = 0.5;
  static const double ttsDefaultPitch = 1.0;
  
  // UI Settings
  static const int maxChatHistoryLength = 100;
  static const Duration typingIndicatorDelay = Duration(milliseconds: 500);
  
  // Alarm Settings
  static const int alarmDurationSeconds = 60; // Alarm rings for 60 seconds
  static const bool alarmSoundEnabled = true;
}
