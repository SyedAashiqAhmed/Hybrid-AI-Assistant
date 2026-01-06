import 'package:flutter/material.dart' hide Intent;
import 'dart:ui';
import '../models/message.dart';
import '../models/intent.dart';
import '../services/intent_engine.dart';
import '../services/gemini_service.dart';
import '../services/system_actions.dart';
import '../widgets/chat_bubble.dart';
import '../config/app_config.dart';

/// Chat Screen - Premium Glassmorphic UI
/// Modern, beautiful interface with smooth animations
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  // Core services
  final IntentEngine _intentEngine = IntentEngine();
  final GeminiService _geminiService = GeminiService();
  final SystemActions _systemActions = SystemActions();

  // UI controllers
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final List<Intent> _intentHistory = [];

  // Animation
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // State
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    
    // Initialize FAB animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _systemActions.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  /// Add welcome message with premium styling
  void _addWelcomeMessage() {
    final welcomeMessage = Message.assistant(
      '✨ Welcome to ${AppConfig.appName}!\n\n'
      'Your intelligent AI companion ready to assist you.\n\n'
      '🎯 **What I can do:**\n\n'
      '🔦 **Device Control**\n'
      '   • Flashlight, Theme switching\n\n'
      '⏰ **Time Management**\n'
      '   • Timers, Alarms, Reminders\n\n'
      '📞 **Phone Calls**\n'
      '   • Schedule automatic calls\n\n'
      '🌐 **Web Navigation**\n'
      '   • Open whitelisted websites\n\n'
      '📚 **Study Assistant**\n'
      '   • Programming help (C, C++, Java, Flutter)\n'
      '   • DSA concepts & explanations\n'
      '   • Code debugging\n\n'
      '💡 **Try saying:**\n'
      '   "Set timer for 5 minutes"\n'
      '   "Remind me to call mom in 30 minutes"\n'
      '   "Schedule call to 1234567890 in 10 minutes"\n'
      '   "Explain binary search"\n'
      '   "Turn on flashlight"',
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
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(theme, isDark),
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(isDark),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Chat messages
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState(theme, isDark)
                      : _buildMessageList(),
                ),

                // Input area
                _buildGlassInputArea(theme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Glass morphic app bar
  PreferredSizeWidget _buildGlassAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            AppConfig.appName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.5,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: isDark
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.3),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined),
          tooltip: 'Clear chat',
          onPressed: _clearChat,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          tooltip: 'About',
          onPressed: _showAboutDialog,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Animated gradient background
  Widget _buildAnimatedBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF334155),
                ]
              : [
                  const Color(0xFFF8FAFC),
                  const Color(0xFFE0E7FF),
                  const Color(0xFFF5F3FF),
                ],
        ),
      ),
    );
  }

  /// Empty state with animation
  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Start a conversation',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Message list with animations
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return const TypingIndicator();
        }
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: ChatBubble(message: _messages[index]),
        );
      },
    );
  }

  /// Glass morphic input area
  Widget _buildGlassInputArea(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleUserInput,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ScaleTransition(
                scale: _fabAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () => _handleUserInput(_textController.text),
                    tooltip: 'Send',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('About'),
          ],
        ),
        content: Text(
          '${AppConfig.appName} - AI Assistant\n\n'
          'A premium hybrid AI mobile assistant featuring:\n\n'
          '✨ Rule-based intent detection\n'
          '🤖 Gemini AI integration\n'
          '📱 Local device control\n'
          '🎯 Smart command processing\n'
          '⏰ Timers, Alarms & Reminders\n\n'
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
