import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/intent.dart';

/// Intent Engine - The Core of Hybrid AI System
/// This is the BRAIN that decides: System Command vs AI Query
/// 
/// PRINCIPLE: Rule-based detection FIRST, AI fallback SECOND
class IntentEngine {
  /// Main method: Analyze user input and detect intent
  Intent detectIntent(String userInput) {
    final input = userInput.toLowerCase().trim();

    // STEP 1: Check for system commands using rule-based detection
    
    // Check flashlight ON
    if (_matchesKeywords(input, AppConfig.flashlightOnKeywords)) {
      return Intent(
        type: IntentType.flashlightOn,
        originalInput: userInput,
        confidence: 0.95,
      );
    }

    // Check flashlight OFF
    if (_matchesKeywords(input, AppConfig.flashlightOffKeywords)) {
      return Intent(
        type: IntentType.flashlightOff,
        originalInput: userInput,
        confidence: 0.95,
      );
    }

    // Check theme change
    if (_matchesKeywords(input, AppConfig.themeChangeKeywords)) {
      // Extract theme preference if mentioned
      String? themePreference;
      if (input.contains('dark')) {
        themePreference = 'dark';
      } else if (input.contains('light')) {
        themePreference = 'light';
      }
      
      return Intent(
        type: IntentType.themeChange,
        originalInput: userInput,
        parameters: {'theme': themePreference},
        confidence: 0.9,
      );
    }

    // Check URL opening
    final urlIntent = _detectUrlIntent(input, userInput);
    if (urlIntent != null) {
      return urlIntent;
    }

    // Check read aloud request
    if (_isReadAloudRequest(input)) {
      return Intent(
        type: IntentType.readAloud,
        originalInput: userInput,
        confidence: 0.85,
      );
    }

    // Check timer commands
    final timerIntent = _detectTimerIntent(input, userInput);
    if (timerIntent != null) {
      return timerIntent;
    }

    // Check reminder commands (before alarms)
    final reminderIntent = _detectReminderIntent(input, userInput);
    if (reminderIntent != null) {
      return reminderIntent;
    }

    // Check alarm commands
    final alarmIntent = _detectAlarmIntent(input, userInput);
    if (alarmIntent != null) {
      return alarmIntent;
    }

    // Check phone call commands
    final callIntent = _detectPhoneCallIntent(input, userInput);
    if (callIntent != null) {
      return callIntent;
    }

    // STEP 2: No system command matched → Fallback to AI
    return Intent(
      type: IntentType.aiQuery,
      originalInput: userInput,
      confidence: 0.8,
    );
  }

  /// Detect timer intent and extract duration
  Intent? _detectTimerIntent(String input, String originalInput) {
    // Check for set timer
    if (_matchesKeywords(input, AppConfig.setTimerKeywords)) {
      // Extract duration (minutes, seconds, hours)
      final duration = _extractDuration(input);
      
      return Intent(
        type: IntentType.setTimer,
        originalInput: originalInput,
        parameters: {'duration': duration},
        confidence: duration > 0 ? 0.9 : 0.7,
      );
    }
    
    // Check for cancel timer
    if (_matchesKeywords(input, AppConfig.cancelTimerKeywords)) {
      return Intent(
        type: IntentType.cancelTimer,
        originalInput: originalInput,
        confidence: 0.95,
      );
    }
    
    return null;
  }

  /// Detect alarm intent and extract time
  Intent? _detectAlarmIntent(String input, String originalInput) {
    // Check for set alarm
    if (_matchesKeywords(input, AppConfig.setAlarmKeywords)) {
      // Extract time (e.g., "7 AM", "19:30", "7:00")
      final time = _extractTime(input);
      
      return Intent(
        type: IntentType.setAlarm,
        originalInput: originalInput,
        parameters: {'time': time},
        confidence: time.isNotEmpty ? 0.9 : 0.7,
      );
    }
    
    // Check for show alarms
    if (_matchesKeywords(input, AppConfig.showAlarmsKeywords)) {
      return Intent(
        type: IntentType.showAlarms,
        originalInput: originalInput,
        confidence: 0.95,
      );
    }
    
    return null;
  }

  /// Detect reminder intent and extract message + duration
  Intent? _detectReminderIntent(String input, String originalInput) {
    // Check for set reminder
    if (_matchesKeywords(input, AppConfig.setReminderKeywords)) {
      // Extract duration
      final duration = _extractDuration(input);
      
      // Extract reminder message
      String message = _extractReminderMessage(input);
      
      return Intent(
        type: IntentType.setReminder,
        originalInput: originalInput,
        parameters: {
          'duration': duration,
          'message': message,
        },
        confidence: duration > 0 ? 0.9 : 0.7,
      );
    }
    
    // Check for show reminders
    if (_matchesKeywords(input, AppConfig.showRemindersKeywords)) {
      return Intent(
        type: IntentType.showReminders,
        originalInput: originalInput,
        confidence: 0.95,
      );
    }
    
    return null;
  }

  /// Detect phone call intent and extract phone number + duration
  Intent? _detectPhoneCallIntent(String input, String originalInput) {
    debugPrint('🔵 _detectPhoneCallIntent called with: "$input"');
    
    // Check for show scheduled calls
    if (_matchesKeywords(input, AppConfig.showScheduledCallsKeywords)) {
      return Intent(
        type: IntentType.showScheduledCalls,
        originalInput: originalInput,
        confidence: 0.95,
      );
    }
    
    // Check for cancel scheduled call
    if (_matchesKeywords(input, AppConfig.cancelScheduledCallKeywords)) {
      return Intent(
        type: IntentType.cancelScheduledCall,
        originalInput: originalInput,
        confidence: 0.95,
      );
    }
    
    // Check if this is a call command at all
    final hasCallKeyword = _matchesKeywords(input, AppConfig.makeCallKeywords) || 
                          _matchesKeywords(input, AppConfig.scheduleCallKeywords);
    
    if (!hasCallKeyword) {
      debugPrint('🔴 No call keyword found');
      return null;
    }
    
    // Extract phone number
    final phoneNumber = _extractPhoneNumber(input);
    debugPrint('🔵 Extracted phone number: "$phoneNumber"');
    
    if (phoneNumber.isEmpty) {
      debugPrint('🔴 No phone number found');
      return null;
    }
    
    // Check for time keywords (in, after, wait, for)
    final hasTimeKeyword = input.contains(RegExp(r'\b(in|after|wait|for)\b', caseSensitive: false));
    debugPrint('🔵 hasTimeKeyword: $hasTimeKeyword');
    
    // If there's a time keyword, try to extract duration
    if (hasTimeKeyword) {
      final duration = _extractDuration(input);
      debugPrint('🔵 Extracted duration: $duration seconds');
      
      // If we found a valid duration, it's a scheduled call
      if (duration > 0) {
        debugPrint('🟡 Detected as SCHEDULED call with duration: $duration seconds');
        
        return Intent(
          type: IntentType.scheduleCall,
          originalInput: originalInput,
          parameters: {
            'phoneNumber': phoneNumber,
            'duration': duration,
          },
          confidence: 0.9,
        );
      }
    }
    
    // No time keyword or no valid duration = immediate call
    debugPrint('🟢 Detected as IMMEDIATE call');
    
    return Intent(
      type: IntentType.makeCall,
      originalInput: originalInput,
      parameters: {
        'phoneNumber': phoneNumber,
      },
      confidence: 0.9,
    );
  }

  /// Extract phone number from input
  String _extractPhoneNumber(String input) {
    // Match various phone number formats
    // Examples: "1234567890", "+1-234-567-8900", "(123) 456-7890", "123 456 7890"
    
    // Pattern 1: 10-digit number (most common)
    final pattern1 = RegExp(r'\b(\d{10})\b');
    final match1 = pattern1.firstMatch(input);
    if (match1 != null) {
      return match1.group(1)!;
    }
    
    // Pattern 2: Number with country code (+91, +1, etc.)
    final pattern2 = RegExp(r'\+?(\d{1,3})?[-.\s]?\(?(\d{3})\)?[-.\s]?(\d{3})[-.\s]?(\d{4})');
    final match2 = pattern2.firstMatch(input);
    if (match2 != null) {
      final countryCode = match2.group(1) ?? '';
      final part1 = match2.group(2) ?? '';
      final part2 = match2.group(3) ?? '';
      final part3 = match2.group(4) ?? '';
      return '$countryCode$part1$part2$part3'.replaceAll(RegExp(r'[^\d+]'), '');
    }
    
    // Pattern 3: Any sequence of 10+ digits
    final pattern3 = RegExp(r'(\d{10,})');
    final match3 = pattern3.firstMatch(input);
    if (match3 != null) {
      return match3.group(1)!;
    }
    
    return '';
  }


  /// Extract reminder message from input
  String _extractReminderMessage(String input) {
    // Pattern: "remind me to [message] in [duration]"
    // or "remind me [message] in [duration]"
    
    // Try to extract text between "remind me" and time indicators
    final patterns = [
      RegExp(r'remind me to (.+?) in \d+', caseSensitive: false),
      RegExp(r'remind me to (.+)', caseSensitive: false),
      RegExp(r'remind me (.+?) in \d+', caseSensitive: false),
      RegExp(r'reminder to (.+?) in \d+', caseSensitive: false),
      RegExp(r'reminder (.+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    
    // Fallback: return the original input without the command part
    return input
        .replaceAll(RegExp(r'remind me to?', caseSensitive: false), '')
        .replaceAll(RegExp(r'in \d+\s*\w+', caseSensitive: false), '')
        .trim();
  }
  /// Extract duration in seconds from input
  int _extractDuration(String input) {
    int totalSeconds = 0;
    
    // Only extract duration if there are time-related keywords
    final hasTimeContext = input.contains(RegExp(r'\b(in|after|wait|for)\b', caseSensitive: false));
    
    if (!hasTimeContext) {
      return 0; // No time context, return 0
    }
    
    // Match patterns like "5 minutes", "30 seconds", "1 hour"
    final minuteMatch = RegExp(r'(\d+)\s*(?:minute|min)s?\b', caseSensitive: false).firstMatch(input);
    final secondMatch = RegExp(r'(\d+)\s*(?:second|sec)s?\b', caseSensitive: false).firstMatch(input);
    final hourMatch = RegExp(r'(\d+)\s*(?:hour|hr)s?\b', caseSensitive: false).firstMatch(input);
    
    if (minuteMatch != null) {
      totalSeconds += int.parse(minuteMatch.group(1)!) * 60;
    }
    if (secondMatch != null) {
      totalSeconds += int.parse(secondMatch.group(1)!);
    }
    if (hourMatch != null) {
      totalSeconds += int.parse(hourMatch.group(1)!) * 3600;
    }
    
    // If no unit specified but has "in X" pattern, assume minutes
    if (totalSeconds == 0) {
      final inNumberMatch = RegExp(r'\bin\s+(\d+)\b', caseSensitive: false).firstMatch(input);
      if (inNumberMatch != null) {
        totalSeconds = int.parse(inNumberMatch.group(1)!) * 60;
      }
    }
    
    return totalSeconds;
  }

  /// Extract time from input (returns in HH:MM format)
  String _extractTime(String input) {
    // Match patterns like "7 AM", "7:30 PM", "19:30"
    
    // Pattern 1: "7 AM" or "7 PM"
    final amPmMatch = RegExp(r'(\d{1,2})\s*(?::|\.)?(\d{2})?\s*(am|pm)', caseSensitive: false).firstMatch(input);
    if (amPmMatch != null) {
      int hour = int.parse(amPmMatch.group(1)!);
      final minute = amPmMatch.group(2) ?? '00';
      final period = amPmMatch.group(3)!.toLowerCase();
      
      if (period == 'pm' && hour != 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;
      
      return '${hour.toString().padLeft(2, '0')}:$minute';
    }
    
    // Pattern 2: "19:30" or "7:30"
    final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(input);
    if (timeMatch != null) {
      final hour = timeMatch.group(1)!.padLeft(2, '0');
      final minute = timeMatch.group(2)!;
      return '$hour:$minute';
    }
    
    // Pattern 3: Just a number (assume AM/PM based on context)
    final numberMatch = RegExp(r'(\d{1,2})').firstMatch(input);
    if (numberMatch != null) {
      int hour = int.parse(numberMatch.group(1)!);
      // If input contains "wake" or "morning", assume AM
      if (input.contains('wake') || input.contains('morning')) {
        return '${hour.toString().padLeft(2, '0')}:00';
      }
    }
    
    return '';
  }

  /// Check if input matches any keyword in the list
  bool _matchesKeywords(String input, List<String> keywords) {
    for (final keyword in keywords) {
      // Use word boundaries to match whole phrases only
      // This prevents "in" from matching inside "9385516590"
      final pattern = RegExp(r'\b' + RegExp.escape(keyword) + r'\b', caseSensitive: false);
      if (pattern.hasMatch(input)) {
        return true;
      }
    }
    return false;
  }

  /// Detect URL opening intent with security check
  Intent? _detectUrlIntent(String input, String originalInput) {
    // Check if input contains URL opening keywords
    bool hasUrlKeyword = false;
    for (final keyword in AppConfig.urlOpenKeywords) {
      if (input.startsWith(keyword)) {
        hasUrlKeyword = true;
        break;
      }
    }

    if (!hasUrlKeyword) return null;

    // Extract potential URL or domain
    final words = input.split(' ');
    String? targetUrl;

    // Look for domain names or URLs
    for (final word in words) {
      // Check if word looks like a domain
      if (word.contains('.com') || 
          word.contains('.org') || 
          word.contains('.net') ||
          word.contains('.dev') ||
          word.contains('http')) {
        targetUrl = word;
        break;
      }
    }

    // If no explicit URL, try to infer from context
    if (targetUrl == null) {
      // Check for known sites
      if (input.contains('youtube')) targetUrl = 'youtube.com';
      else if (input.contains('google')) targetUrl = 'google.com';
      else if (input.contains('github')) targetUrl = 'github.com';
      else if (input.contains('stackoverflow')) targetUrl = 'stackoverflow.com';
      else if (input.contains('flutter')) targetUrl = 'flutter.dev';
    }

    if (targetUrl != null) {
      // Security check: Validate against whitelist
      final isWhitelisted = _isWhitelistedDomain(targetUrl);
      
      return Intent(
        type: IntentType.openUrl,
        originalInput: originalInput,
        parameters: {
          'url': targetUrl,
          'isWhitelisted': isWhitelisted,
        },
        confidence: isWhitelisted ? 0.9 : 0.6,
      );
    }

    return null;
  }

  /// Check if domain is in whitelist
  bool _isWhitelistedDomain(String url) {
    final cleanUrl = url.replaceAll('https://', '').replaceAll('http://', '');
    
    for (final domain in AppConfig.whitelistedDomains) {
      if (cleanUrl.contains(domain)) {
        return true;
      }
    }
    return false;
  }

  /// Detect read aloud requests
  bool _isReadAloudRequest(String input) {
    final readAloudKeywords = [
      'read aloud',
      'read this',
      'speak',
      'say this',
      'read out',
      'voice',
    ];

    return _matchesKeywords(input, readAloudKeywords);
  }

  /// Get intent description for debugging
  String getIntentDescription(Intent intent) {
    switch (intent.type) {
      case IntentType.flashlightOn:
        return '🔦 System Command: Turn flashlight ON';
      case IntentType.flashlightOff:
        return '🔦 System Command: Turn flashlight OFF';
      case IntentType.themeChange:
        final theme = intent.parameters['theme'] ?? 'toggle';
        return '🎨 System Command: Change theme to $theme';
      case IntentType.openUrl:
        final url = intent.parameters['url'];
        final whitelisted = intent.parameters['isWhitelisted'];
        return '🌐 System Command: Open $url ${whitelisted ? '✓' : '⚠️'}';
      case IntentType.readAloud:
        return '🔊 System Command: Read aloud';
      case IntentType.setTimer:
        final duration = intent.parameters['duration'];
        return '⏲️ System Command: Set timer for $duration seconds';
      case IntentType.cancelTimer:
        return '⏲️ System Command: Cancel timer';
      case IntentType.setAlarm:
        final time = intent.parameters['time'];
        return '⏰ System Command: Set alarm for $time';
      case IntentType.showAlarms:
        return '⏰ System Command: Show alarms';
      case IntentType.setReminder:
        final duration = intent.parameters['duration'];
        final message = intent.parameters['message'];
        return '⏰ System Command: Set reminder "$message" in $duration seconds';
      case IntentType.showReminders:
        return '⏰ System Command: Show reminders';
      case IntentType.makeCall:
        final phoneNumber = intent.parameters['phoneNumber'];
        return '📞 System Command: Call $phoneNumber now';
      case IntentType.scheduleCall:
        final phoneNumber = intent.parameters['phoneNumber'];
        final duration = intent.parameters['duration'];
        return '📞 System Command: Schedule call to $phoneNumber in $duration seconds';
      case IntentType.showScheduledCalls:
        return '📞 System Command: Show scheduled calls';
      case IntentType.cancelScheduledCall:
        return '📞 System Command: Cancel scheduled call';
      case IntentType.aiQuery:
        return '🤖 AI Query: Sending to Gemini';
      case IntentType.unknown:
        return '❓ Unknown intent';
    }
  }

  /// Context-aware intent detection (for follow-up commands)
  Intent detectIntentWithContext(String userInput, List<Intent> previousIntents) {
    final input = userInput.toLowerCase().trim();

    // Handle context-aware follow-ups
    if (previousIntents.isNotEmpty) {
      final lastIntent = previousIntents.last;

      // "yes" or "ok" after a theme change suggestion
      if (lastIntent.type == IntentType.themeChange && 
          (input == 'yes' || input == 'ok' || input == 'sure')) {
        return lastIntent; // Repeat the theme change
      }

      // "turn it off" after flashlight on
      if (lastIntent.type == IntentType.flashlightOn &&
          (input.contains('off') || input.contains('turn it off'))) {
        return Intent(
          type: IntentType.flashlightOff,
          originalInput: userInput,
          confidence: 0.95,
        );
      }
    }

    // Default detection
    return detectIntent(userInput);
  }
}
