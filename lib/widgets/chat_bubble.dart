import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../models/message.dart';

/// Premium Chat Bubble Widget with Glassmorphism
/// Beautiful message display with smooth animations
class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildPremiumAvatar(false, theme, isDark),
          if (!isUser) const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildGlassBubble(theme, isDark),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 12),
          if (isUser) _buildPremiumAvatar(true, theme, isDark),
        ],
      ),
    );
  }

  /// Premium avatar with gradient and glow
  Widget _buildPremiumAvatar(bool isUser, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUser
              ? [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ]
              : [
                  theme.colorScheme.secondary,
                  theme.colorScheme.tertiary,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary)
                .withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent,
        child: Icon(
          isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Glass morphic bubble
  Widget _buildGlassBubble(ThemeData theme, bool isDark) {
    final isUser = message.isUser;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        gradient: _getBubbleGradient(theme, isDark),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(theme).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser && message.type == MessageType.systemAction)
                  _buildSystemBadge(theme),
                if (!isUser && message.type == MessageType.systemAction)
                  const SizedBox(height: 8),
                Text(
                  message.text,
                  style: TextStyle(
                    color: _getTextColor(theme),
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// System action badge
  Widget _buildSystemBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.2),
            theme.colorScheme.secondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.settings_suggest_rounded,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'System Action',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Get bubble gradient
  Gradient _getBubbleGradient(ThemeData theme, bool isDark) {
    if (message.isError) {
      return LinearGradient(
        colors: [
          theme.colorScheme.errorContainer.withOpacity(isDark ? 0.3 : 0.8),
          theme.colorScheme.errorContainer.withOpacity(isDark ? 0.2 : 0.6),
        ],
      );
    }
    
    if (message.isUser) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withOpacity(isDark ? 0.4 : 1.0),
          theme.colorScheme.secondary.withOpacity(isDark ? 0.3 : 0.9),
        ],
      );
    }
    
    if (message.type == MessageType.systemAction) {
      return LinearGradient(
        colors: [
          theme.colorScheme.secondaryContainer.withOpacity(isDark ? 0.3 : 0.8),
          theme.colorScheme.tertiaryContainer.withOpacity(isDark ? 0.2 : 0.6),
        ],
      );
    }
    
    return LinearGradient(
      colors: [
        (isDark ? Colors.white : theme.colorScheme.surface).withOpacity(isDark ? 0.1 : 0.9),
        (isDark ? Colors.white : theme.colorScheme.surface).withOpacity(isDark ? 0.05 : 0.8),
      ],
    );
  }

  /// Get shadow color
  Color _getShadowColor(ThemeData theme) {
    if (message.isError) return theme.colorScheme.error;
    if (message.isUser) return theme.colorScheme.primary;
    if (message.type == MessageType.systemAction) return theme.colorScheme.secondary;
    return theme.colorScheme.primary;
  }

  /// Get text color
  Color _getTextColor(ThemeData theme) {
    if (message.isError) {
      return theme.colorScheme.onErrorContainer;
    }
    if (message.isUser) {
      return Colors.white;
    }
    if (message.type == MessageType.systemAction) {
      return theme.colorScheme.onSecondaryContainer;
    }
    return theme.colorScheme.onSurface;
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}

/// Premium Typing Indicator with Pulse Animation
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Avatar with pulse animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.secondary.withOpacity(0.3 + (_controller.value * 0.3)),
                      blurRadius: 12 + (_controller.value * 8),
                      spreadRadius: 2 + (_controller.value * 2),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // Glass bubble with animated dots
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDark ? Colors.white : theme.colorScheme.surface).withOpacity(isDark ? 0.1 : 0.9),
                  (isDark ? Colors.white : theme.colorScheme.surface).withOpacity(isDark ? 0.05 : 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedDot(0, theme),
                    const SizedBox(width: 6),
                    _buildAnimatedDot(1, theme),
                    const SizedBox(width: 6),
                    _buildAnimatedDot(2, theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index, ThemeData theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = (_controller.value - (index * 0.25)) % 1.0;
        final scale = 0.6 + (value < 0.5 ? value : 1 - value) * 0.8;
        final opacity = 0.3 + (value < 0.5 ? value : 1 - value) * 0.7;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(opacity),
                  theme.colorScheme.secondary.withOpacity(opacity),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(opacity * 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
