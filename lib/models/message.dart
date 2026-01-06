/// Message Model
/// Represents a single chat message in the conversation
class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final bool isError;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.isError = false,
  });

  /// Create a user message
  factory Message.user(String text) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  /// Create an AI/system response message
  factory Message.assistant(String text, {MessageType type = MessageType.text}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: type,
    );
  }

  /// Create an error message
  factory Message.error(String text) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.error,
      isError: true,
    );
  }

  /// Create a system action confirmation message
  factory Message.systemAction(String text) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.systemAction,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'isError': isError,
    };
  }

  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      isError: json['isError'] ?? false,
    );
  }
}

/// Message Type Enum
enum MessageType {
  text,           // Regular text message
  systemAction,   // System action confirmation (flashlight, theme, etc.)
  error,          // Error message
  aiResponse,     // AI-generated response
}
