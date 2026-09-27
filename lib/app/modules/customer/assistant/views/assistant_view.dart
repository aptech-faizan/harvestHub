import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/assistant_controller.dart';
import '../data/chat_message.dart';
import '../../../../core/theme/app_colors.dart';

// View rendering Harvey chat screen for HarvestHub farm assistant
class AssistantView extends GetView<AssistantController> {
  const AssistantView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harvey'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
          ),
          _buildSuggestionChips(),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Harvey is thinking...',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          _buildInputBar(),
        ],
      ),
    );
  }

  // Single message bubble widget with user or assistant alignment
  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: isUser ? Colors.green.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 14),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }

  // Input text bar with send button
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.inputController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => controller.sendMessage(),
              decoration: const InputDecoration(
                hintText: 'Ask about vegetables, storage, orders...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () => controller.sendMessage(),
          ),
        ],
      ),
    );
  }

  // Farm-related quick suggestion chips list — farm_knowledge.dart ke questions ke short versions
  static const List<_ChipData> _suggestions = [
    _ChipData('Vitamin C fruits?', 'Which fruits are rich in Vitamin C?'),
    _ChipData('Tomato storage tips', 'How should I store fresh tomatoes?'),
    _ChipData('Seasonal vegetables', 'What are the common seasonal vegetables?'),
    _ChipData('Healthy salad ideas', 'Which vegetables are best for fresh salads?'),
    _ChipData('Book a pickup slot', 'How do I book a pickup slot?'),
    _ChipData('Check fresh veggies', 'How can I check if vegetables are fresh?'),
  ];

  // Horizontally scrollable suggestion chip row — welcome state mein dikhta hai
  Widget _buildSuggestionChips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = _suggestions[index];
          return _buildSingleChip(chip);
        },
      ),
    );
  }

  // Ek individual chip widget jisme tap se controller.sendFromChip() call hota hai
  Widget _buildSingleChip(_ChipData chip) {
    return GestureDetector(
      onTap: () => controller.sendFromChip(chip.fullQuestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          chip.label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Chip ka display label aur full question store karne ka simple data class
class _ChipData {
  final String label;
  final String fullQuestion;
  const _ChipData(this.label, this.fullQuestion);
}

