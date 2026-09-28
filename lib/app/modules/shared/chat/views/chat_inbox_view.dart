import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../controllers/chat_inbox_controller.dart';
import '../controllers/chat_room_controller.dart' show ChatRoomArgs;

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

/// Conversation list, shared by customers and farmers.
/// Restyled with light theme tokens, AppCard.list rows, and 16px screen padding.
class ChatInboxView extends GetView<ChatInboxController> {
  const ChatInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    final role = controller.role;

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Chats',
        automaticallyImplyLeading: true,
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            onTap: controller.listen,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.accentRed),
                    const SizedBox(height: AppSpacing.m),
                    AppText.cardTitle(
                      'Connection Issue',
                      color: AppColors.accentRed,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    AppText.caption(
                      controller.error.value,
                      textAlign: TextAlign.center,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    AppButton.primary(
                      label: 'Retry',
                      icon: Icons.refresh_rounded,
                      onPressed: controller.listen,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final chats = controller.chats;
        if (chats.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.chipHerbsBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 36,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const AppText.sectionHeading(
                    'No chats yet',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  AppText.body(
                    role == 'farmer'
                        ? 'No customer conversations yet.\nThey will appear here once a customer messages you.'
                        : 'No conversations yet.\nTap "Chat with Farmer" on a farmer, product or market to start one.',
                    textAlign: TextAlign.center,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final c = chats[i];
            final unread = c.hasUnreadFor(role);
            final peerName = c.peerName(role);
            final initial = peerName.trim().isNotEmpty
                ? peerName.trim()[0].toUpperCase()
                : (role == 'farmer' ? 'C' : 'F');

            return AppCard(
              onTap: () {
                controller.markRead(c.id);
                Get.toNamed(
                  Routes.chatRoom,
                  arguments: ChatRoomArgs(
                    chatId: c.id,
                    peerId: c.peerId(role),
                    peerName: peerName,
                    myRole: role,
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
              child: Row(
                children: [
                  // Circular avatar (primary-tinted with peer initial)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.chipHerbsBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  // Name & Last message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.cardTitle(
                          peerName.isEmpty ? 'Chat' : peerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        AppText.caption(
                          c.lastMessage.isEmpty ? 'No messages yet' : c.lastMessage,
                          color: unread ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  // Time on the right + unread chip
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (c.lastMessageAt != null)
                        AppText.caption(
                          _formatChatTimestamp(c.lastMessageAt),
                          color: AppColors.textSecondary,
                        ),
                      if (unread) ...[
                        const SizedBox(height: 4),
                        const AppChip.pill(
                          label: 'New',
                          backgroundColor: AppColors.primaryButton,
                          textColor: AppColors.surfaceWhite,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
