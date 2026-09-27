import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Shared chat bubble widget — two variants driven by [isUser].
///
/// - [isUser] = true  → right-aligned, primaryButton green bg, white text,
///                       rounded all corners except bottom-right (tear-drop tail).
/// - [isUser] = false → left-aligned, surfaceWhite bg, divider border, dark text,
///                       avatar circle on the far left, rounded all except bottom-left.
///
/// Styled exclusively with AppColors / AppTextStyles / AppRadius tokens.
class AppChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  /// Label shown inside the assistant avatar circle (e.g. "H" for Harvey).
  /// Ignored when [isUser] is true.
  final String assistantLabel;

  const AppChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.assistantLabel = 'H',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: isUser ? _UserBubble(text: text) : _AssistantBubble(text: text, label: assistantLabel),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User bubble — right-aligned, green background
// ─────────────────────────────────────────────────────────────────────────────
class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryButton,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.card),
            topRight: Radius.circular(AppRadius.card),
            bottomLeft: Radius.circular(AppRadius.card),
            bottomRight: Radius.circular(4), // tail
          ),
          boxShadow: AppRadius.cardElevation,
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyText.copyWith(
            color: Colors.white,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Assistant bubble — left-aligned, white card bg, with avatar
// ─────────────────────────────────────────────────────────────────────────────
class _AssistantBubble extends StatelessWidget {
  final String text;
  final String label;
  const _AssistantBubble({required this.text, required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Harvey avatar circle
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
                label,
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
          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border.all(color: AppColors.divider, width: 1.0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  topRight: Radius.circular(AppRadius.card),
                  bottomLeft: Radius.circular(4), // tail
                  bottomRight: Radius.circular(AppRadius.card),
                ),
                boxShadow: AppRadius.cardElevation,
              ),
              child: Text(
                text,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
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
