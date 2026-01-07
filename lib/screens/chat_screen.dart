import 'package:flutter/material.dart' hide Intent;
import '../models/message.dart';
import '../models/intent.dart';
import '../services/intent_engine.dart';
import '../services/gemini_service.dart';
import '../services/system_actions.dart';
import '../widgets/chat_bubble.dart';
import '../config/app_config.dart';

/// Chat Screen - Professional Clean UI
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Core services
  final IntentEngine _intentEngine = IntentEngine();
  final GeminiService _geminiService = GeminiService();
  final SystemActions _systemActions = SystemActions();

  // UI controllers
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final List<Intent> _intentHistory = [];

  // State
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _systemActions.dispose();
    super.dispose();
  }

  /// Add welcome message
  void _addWelcomeMessage() {
    final welcomeMessage = Message.assistant(
      'Welcome to ${AppConfig.appName}!\n\n'
      'Your intelligent AI companion ready to assist you.\n\n'
      'What I can do:\n\n'
      '• Device Control (Flashlight, Theme switching)\n'
      '• Time Management (Timers, Alarms, Reminders)\n'
      '• Phone Calls (Schedule automatic calls)\n'
      '• Web Navigation (Open whitelisted websites)\n'
      '• Study Assistant (Programming help, DSA concepts)\n\n'
      'Try saying:\n'
      '  "Set timer for 5 minutes"\n'
      '  "Remind me to call mom in 30 minutes"\n'
      '  "Explain binary search"\n'
      '  "Turn on flashlight"',
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  /// Handle user input
  Future<void> _handleUserInput(String input) async {
    if (input.trim().isEmpty) return;

    _textController.clear();

    final userMessage = Message.user(input);
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });
    _scrollToBottom();

    final intent = _intentEngine.detectIntentWithContext(input, _intentHistory);
    _intentHistory.add(intent);

    debugPrint('Intent detected: ${_intentEngine.getIntentDescription(intent)}');

    if (intent.isSystemCommand) {
      await _handleSystemCommand(intent);
    } else {
      await _handleAiQuery(input);
    }

    setState(() {
      _isTyping = false;
    });
    _scrollToBottom();
  }

  /// Handle system commands
  Future<void> _handleSystemCommand(Intent intent) async {
    final result = await _systemActions.executeAction(intent, context);

    final responseMessage = result.success
        ? Message.systemAction(result.message)
        : Message.error(result.message);

    setState(() {
      _messages.add(responseMessage);
    });
  }

  /// Handle AI queries
  Future<void> _handleAiQuery(String query) async {
    try {
      final aiResponse = await _geminiService.generateResponse(query);
      
      final responseMessage = Message.assistant(
        aiResponse,
        type: MessageType.aiResponse,
      );

      setState(() {
        _messages.add(responseMessage);
      });
    } catch (e) {
      final errorMessage = Message.error(
        'Failed to get AI response: ${e.toString()}',
      );
      setState(() {
        _messages.add(errorMessage);
      });
    }
  }

  /// Scroll to bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Clear chat
  void _clearChat() {
    setState(() {
      _messages.clear();
      _intentHistory.clear();
      _geminiService.clearHistory();
      _addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF212121) : const Color(0xFFF5F5F5),
      appBar: _buildAppBar(theme, isDark),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(theme, isDark)
                : _buildMessageList(),
          ),

          // Input area
          _buildInputArea(theme, isDark),
        ],
      ),
    );
  }

  /// Simple app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      title: Text(
        AppConfig.appName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Clear chat',
          onPressed: _clearChat,
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'About',
          onPressed: _showAboutDialog,
        ),
      ],
    );
  }

  /// Empty state
  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Message list
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return const TypingIndicator();
        }
        return ChatBubble(message: _messages[index]);
      },
    );
  }

  /// Simple input area
  Widget _buildInputArea(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[500],
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _handleUserInput,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _handleUserInput(_textController.text),
              tooltip: 'Send',
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Text(
          '${AppConfig.appName} - AI Assistant\n\n'
          'A hybrid AI mobile assistant featuring:\n\n'
          '• Rule-based intent detection\n'
          '• Gemini AI integration\n'
          '• Local device control\n'
          '• Smart command processing\n'
          '• Timers, Alarms & Reminders\n\n'
          'Version: ${AppConfig.appVersion}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
