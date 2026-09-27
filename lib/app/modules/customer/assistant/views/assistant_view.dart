import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/assistant_controller.dart';
import '../data/chat_message.dart';

/// Harvey AI Assistant screen — revamped per UI Master Rules.
/// Structure:
///  AppAppBar (Harvey avatar + name) → scrollable message list (AppChatBubble)
///  → AppChatTypingIndicator while loading → suggestion chips row
///  → AppTextField input bar + send AppIconButton.
/// AI response logic, streaming, and message-handling are untouched.
class AssistantView extends GetView<AssistantController> {
  const AssistantView({super.key});

  // Suggestion chips — tap fills the input + fires sendFromChip()  [LOGIC UNCHANGED]
  static const List<_ChipData> _suggestions = [
    _ChipData('Vitamin C fruits?', 'Which fruits are rich in Vitamin C?'),
    _ChipData('Tomato storage tips', 'How should I store fresh tomatoes?'),
    _ChipData('Seasonal vegetables', 'What are the common seasonal vegetables?'),
    _ChipData('Healthy salad ideas', 'Which vegetables are best for fresh salads?'),
    _ChipData('Book a pickup slot', 'How do I book a pickup slot?'),
    _ChipData('Check fresh veggies', 'How can I check if vegetables are fresh?'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      // ── App Bar: Harvey avatar + name ─────────────────────────────────────
      appBar: AppAppBar(
        title: Row(
          children: [
            // Harvey avatar
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryButton, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'H',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Harvey', style: AppTextStyles.cardTitle),
                Text(
                  'Farm AI Assistant',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Online indicator dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.primaryButton,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceWhite, width: 2),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Message List ────────────────────────────────────────────────
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontalPadding,
                    AppSpacing.m,
                    AppSpacing.screenHorizontalPadding,
                    AppSpacing.s,
                  ),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final ChatMessage msg = controller.messages[index];
                    return AppChatBubble(
                      text: msg.text,
                      isUser: msg.isUser,
                      assistantLabel: 'H',
                    );
                  },
                )),
          ),

          // ── Typing Indicator (while AI is loading) ─────────────────────
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontalPadding,
                0,
                AppSpacing.screenHorizontalPadding,
                AppSpacing.s,
              ),
              child: const AppChatTypingIndicator(assistantLabel: 'H'),
            );
          }),

          // ── Suggestion Chips (welcome state only) ─────────────────────
          Obx(() {
            if (!controller.showSuggestions.value) return const SizedBox.shrink();
            return SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                  vertical: AppSpacing.s,
                ),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
                itemBuilder: (context, index) {
                  final chip = _suggestions[index];
                  return _SuggestionChip(
                    label: chip.label,
                    onTap: () => controller.sendFromChip(chip.fullQuestion),
                  );
                },
              ),
            );
          }),

          // ── Input Bar ───────────────────────────────────────────────────
          _InputBar(controller: controller),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Input bar — AppTextField + send AppIconButton
// ─────────────────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final AssistantController controller;
  const _InputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontalPadding,
        AppSpacing.s,
        AppSpacing.screenHorizontalPadding,
        AppSpacing.m,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input
            Expanded(
              child: AppTextField(
                controller: controller.inputController,
                hintText: 'Ask about vegetables, storage, orders...',
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            // Send button
            Obx(() => _SendButton(
                  onTap: controller.isLoading.value
                      ? null
                      : () => controller.sendMessage(),
                  isLoading: controller.isLoading.value,
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Circular send button with loading state
// ─────────────────────────────────────────────────────────────────────────────
class _SendButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const _SendButton({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? AppColors.textDisabled : AppColors.primaryButton,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Styled suggestion chip
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.chipHerbsBg,
      borderRadius: AppRadius.chipRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chipRadius,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.chipRadius,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.chipLabel.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Data class for suggestion chip display label + full question
// ─────────────────────────────────────────────────────────────────────────────
class _ChipData {
  final String label;
  final String fullQuestion;
  const _ChipData(this.label, this.fullQuestion);
}
