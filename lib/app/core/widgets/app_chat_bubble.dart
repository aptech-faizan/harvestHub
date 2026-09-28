import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Shared chat bubble widget — supports both peer-to-peer conversations
/// and assistant dialogues.
///
/// Spec requirements:
/// - sent: right aligned, primaryButton bg, white text, corner nearest sender at 4px
/// - received: left aligned, surfaceMuted bg, textPrimary text, corner nearest sender at 4px
/// - 16px radius everywhere else, max width 75%, 12px padding, 8px vertical gap
/// - timestamp in caption style (white 70% on sent, textSecondary on received)
class AppChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String? timestamp;
  final bool showAvatar;
  final String? assistantLabel;

  const AppChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.timestamp,
    this.showAvatar = false,
    this.assistantLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = showAvatar || (assistantLabel != null && assistantLabel!.isNotEmpty && !isUser);

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primaryButton : AppColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              color: isUser ? Colors.white : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (timestamp != null && timestamp!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              timestamp!,
              style: AppTextStyles.caption.copyWith(
                color: isUser
                    ? Colors.white.withValues(alpha: 0.70)
                    : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );

    if (hasAvatar) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryButton, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    assistantLabel ?? 'H',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Flexible(child: bubble),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: bubble,
      ),
    );
  }
}

/// Animated "Harvey is thinking…" typing indicator — three bouncing dots.
/// Uses the same design tokens as [AppChatBubble] for the assistant side.
class AppChatTypingIndicator extends StatefulWidget {
  final String assistantLabel;
  const AppChatTypingIndicator({super.key, this.assistantLabel = 'H'});

  @override
  State<AppChatTypingIndicator> createState() => _AppChatTypingIndicatorState();
}

class _AppChatTypingIndicatorState extends State<AppChatTypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true, period: Duration(milliseconds: 900 + i * 150));
    });
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: -6).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    // Stagger the dots
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryButton, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.assistantLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            // Dots container
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border.all(color: AppColors.divider, width: 1.0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  topRight: Radius.circular(AppRadius.card),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(AppRadius.card),
                ),
                boxShadow: AppRadius.cardElevation,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _animations[i],
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _animations[i].value),
                      child: Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.60),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
