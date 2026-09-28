import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import '../controllers/chat_room_controller.dart';

/// Formats chat timestamps as "28 Sep, 1:30 PM".
String _formatChatTimestamp(DateTime? d) {
  if (d == null) return '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final month = months[d.month - 1];
  final hour = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} $month, $hour:$minute $period';
}

/// One real-time conversation between customer and farmer.
/// Restyled with light theme tokens, AppChatBubble, and pinned light input bar.
class ChatRoomView extends GetView<ChatRoomController> {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final peer = controller.args.peerName;
    final myRole = controller.args.myRole;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppAppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          size: 40.0,
          backgroundColor: AppColors.surfaceMuted,
          iconColor: AppColors.primaryDark,
          tooltip: 'Back',
          onTap: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.cardTitle(
              peer.isEmpty ? 'Chat' : peer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            AppText.caption(
              myRole == 'farmer' ? 'Customer' : 'Farmer',
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Messages List ────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (controller.error.value.isNotEmpty &&
                  controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 44,
                          color: AppColors.accentRed,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        AppText.body(
                          controller.error.value,
                          textAlign: TextAlign.center,
                          color: AppColors.accentRed,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final messages = controller.messages;
              if (messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.chipHerbsBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const AppText.sectionHeading(
                          'Say Hello!',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const AppText.caption(
                          'No messages yet. Send a message to start the conversation.',
                          textAlign: TextAlign.center,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                  vertical: AppSpacing.m,
                ),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final mine = m.senderId == controller.uid;
                  return AppChatBubble(
                    text: m.text,
                    isUser: mine,
                    timestamp: _formatChatTimestamp(m.createdAt),
                  );
                },
              );
            }),
          ),

          // ── Pinned Bottom Input Bar ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                  vertical: AppSpacing.s,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: controller.inputC,
                        hintText: 'Type a message...',
                        onSubmitted: (_) => controller.send(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    AppIconButton(
                      icon: Icons.send_rounded,
                      size: 48.0,
                      iconSize: 20.0,
                      backgroundColor: AppColors.primaryButton,
                      iconColor: AppColors.surfaceWhite,
                      tooltip: 'Send',
                      onTap: controller.send,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
