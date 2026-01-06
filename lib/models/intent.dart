/// Intent Model
/// Represents the detected intent from user input
class Intent {
  final IntentType type;
  final String originalInput;
  final Map<String, dynamic> parameters;
  final double confidence;

  Intent({
    required this.type,
    required this.originalInput,
    this.parameters = const {},
    this.confidence = 1.0,
  });

  /// Check if this is a system command
  bool get isSystemCommand => type != IntentType.aiQuery;

  /// Check if this requires AI processing
  bool get requiresAI => type == IntentType.aiQuery;

  @override
  String toString() {
    return 'Intent(type: $type, confidence: $confidence, params: $parameters)';
  }
}

/// Intent Type Enum
/// Defines all possible intents the system can detect
enum IntentType {
  // System Commands (Rule-based)
  flashlightOn,
  flashlightOff,
  themeChange,
  openUrl,
  readAloud,
  
  // Timer and Alarm Commands
  setTimer,
  cancelTimer,
  setAlarm,
  showAlarms,
  setReminder,
  showReminders,
  
  // Phone Call Commands
  makeCall,           // Immediate call
  scheduleCall,       // Scheduled call
  showScheduledCalls,
  cancelScheduledCall,
  
  // AI-powered queries
  aiQuery,
  
  // Special
  unknown,
}

/// Intent Result
/// Contains the result of intent processing
class IntentResult {
  final bool success;
  final String message;
  final dynamic data;

  IntentResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory IntentResult.success(String message, {dynamic data}) {
    return IntentResult(
      success: true,
      message: message,
      data: data,
    );
  }

  factory IntentResult.failure(String message) {
    return IntentResult(
      success: false,
      message: message,
    );
  }
}
