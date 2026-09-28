import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_app_bar.dart';
import 'package:harvest_hub/app/core/widgets/app_button.dart';
import 'package:harvest_hub/app/core/widgets/app_chip.dart';
import 'package:harvest_hub/app/core/widgets/app_icon.dart';
import 'package:harvest_hub/app/core/widgets/app_section_header.dart';
import 'package:harvest_hub/app/core/widgets/state_view.dart';
import 'package:harvest_hub/app/data/models/pickup_slot_model.dart';
import 'package:harvest_hub/app/modules/farmer/pickup_slots/controllers/farmer_slots_controller.dart';

class FarmerSlotsView extends GetView<FarmerSlotsController> {
  const FarmerSlotsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Pickup Slots',
        actions: [
          AppButton.small(
            label: 'Add Slot',
            icon: Icons.add_rounded,
            onPressed: () => controller.createOrEdit(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: controller.load,
          ),
        ],
      ),
      body: Obx(() {
        return StateView(
          isLoading: controller.isLoading.value,
          error: controller.error.value,
          isEmpty: controller.slots.isEmpty,
          emptyText:
              'No pickup slots yet.\nTap "Add Slot" to create your first time slot.',
          onRetry: controller.load,
          child: RefreshIndicator(
            onRefresh: controller.load,
            child: CustomScrollView(
              slivers: [
                // ── Summary pills ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Obx(() {
                    final total = controller.slots.length;
                    final full =
                        controller.slots.where((s) => s.isFull).length;
                    final available = total - full;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.l,
                        AppSpacing.m,
                        AppSpacing.l,
                        AppSpacing.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSectionHeader(
                            title: 'All Slots',
                            actionTitle: '$total slot${total == 1 ? '' : 's'}',
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Wrap(
                            spacing: AppSpacing.s,
                            children: [
                              AppChip.pill(
                                label: '$available Available',
                                backgroundColor: AppColors.chipHerbsBg,
                                textColor: AppColors.primaryDark,
                                iconData: Icons.event_available_rounded,
                              ),
                              if (full > 0)
                                AppChip.pill(
                                  label: '$full Full',
                                  backgroundColor: const Color(0xFFFFEBEE),
                                  textColor: AppColors.accentRed,
                                  iconData: Icons.event_busy_rounded,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                // ── Grouped slot list (by date) ───────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.s,
                    AppSpacing.l,
                    AppSpacing.l,
                  ),
                  sliver: Obx(() {
                    final groups = _groupByDate(controller.slots);
                    final dateKeys = groups.keys.toList()..sort();

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, gi) {
                          final dateKey = dateKeys[gi];
                          final daySlots = groups[dateKey]!;
                          return _DateGroup(
                            dateLabel: _formatDateHeader(dateKey),
                            slots: daySlots,
                            onEdit: (s) => controller.createOrEdit(s),
                            onDelete: (s) => controller.delete(s),
                          );
                        },
                        childCount: dateKeys.length,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Groups slots by calendar date (YYYY-MM-DD string key for sorting)
  Map<String, List<PickupSlotModel>> _groupByDate(
      List<PickupSlotModel> slots) {
    final map = <String, List<PickupSlotModel>>{};
    for (final slot in slots) {
      final d = slot.startTime;
      final key =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(slot);
    }
    // Sort slots within each group by start time
    for (final key in map.keys) {
      map[key]!.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return map;
  }

  String _formatDateHeader(String key) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    final parts = key.split('-');
    final dt = DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final dayName = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    return '$dayName, ${dt.day} $month ${dt.year}';
  }
}

// ---------------------------------------------------------------------------
// Date group header + slot pills/rows for that day
// ---------------------------------------------------------------------------
class _DateGroup extends StatelessWidget {
  final String dateLabel;
  final List<PickupSlotModel> slots;
  final void Function(PickupSlotModel) onEdit;
  final void Function(PickupSlotModel) onDelete;

  const _DateGroup({
    required this.dateLabel,
    required this.slots,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Flag to distinguish today's slots
    final now = DateTime.now();
    final firstSlot = slots.first;
    final isToday = firstSlot.startTime.year == now.year &&
        firstSlot.startTime.month == now.month &&
        firstSlot.startTime.day == now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(
              top: AppSpacing.m, bottom: AppSpacing.s),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primaryDark
                      : AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isToday
                        ? AppColors.primaryDark
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: isToday
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isToday ? 'Today — $dateLabel' : dateLabel,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Slot cards for this date
        ...slots.map((slot) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: _SlotCard(
                slot: slot,
                onEdit: () => onEdit(slot),
                onDelete: () => onDelete(slot),
              ),
            )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual slot card — slot-pill + details + actions
// ---------------------------------------------------------------------------
class _SlotCard extends StatelessWidget {
  final PickupSlotModel slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SlotCard({
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  String _timeRange() {
    String fmt(DateTime dt) {
      final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final p = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $p';
    }

    return '${fmt(slot.startTime)} – ${fmt(slot.endTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final isFull = slot.isFull;
    final bookedRatio = slot.capacity > 0
        ? slot.bookedCount / slot.capacity
        : 0.0;

    // Capacity fill colour
    final Color fillColor;
    if (isFull) {
      fillColor = AppColors.accentRed;
    } else if (bookedRatio >= 0.75) {
      fillColor = AppColors.accentOrange;
    } else {
      fillColor = AppColors.primaryButton;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isFull ? const Color(0xFFFFCDD2) : AppColors.divider,
        ),
        boxShadow: AppRadius.cardElevation,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: slot-pill time + status chip + actions ────
            Row(
              children: [
                // Time pill (replicates the AppSlotPicker selectable pill
                // style, non-interactive here — just display)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isFull
                        ? AppColors.surfaceMuted
                        : AppColors.chipHerbsBg,
                    borderRadius: AppRadius.chipRadius,
                    border: Border.all(
                      color: isFull
                          ? AppColors.divider
                          : AppColors.primaryDark
                              .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFull
                            ? Icons.block_rounded
                            : Icons.schedule_rounded,
                        size: 14,
                        color: isFull
                            ? AppColors.textDisabled
                            : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timeRange(),
                        style: AppTextStyles.chipLabel.copyWith(
                          color: isFull
                              ? AppColors.textDisabled
                              : AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.s),

                // Full badge
                if (isFull)
                  AppChip.pill(
                    label: 'Full',
                    backgroundColor: const Color(0xFFFFEBEE),
                    textColor: AppColors.accentRed,
                    iconData: Icons.event_busy_rounded,
                  ),

                const Spacer(),

                // Edit + Delete icon buttons
                AppIconButton(
                  icon: Icons.edit_rounded,
                  onTap: onEdit,
                  size: 34,
                  iconSize: 17,
                  backgroundColor: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  isCircle: false,
                  tooltip: 'Edit slot',
                ),
                const SizedBox(width: AppSpacing.xs),
                AppIconButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: onDelete,
                  size: 34,
                  iconSize: 17,
                  backgroundColor: const Color(0xFFFFEBEE),
                  iconColor: AppColors.accentRed,
                  isCircle: false,
                  tooltip: 'Delete slot',
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.m),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.m),

            // ── Capacity bar ───────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.people_rounded,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(
                  'Capacity',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  '${slot.bookedCount} / ${slot.capacity} booked',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: bookedRatio.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation<Color>(fillColor),
              ),
            ),

            // ── Available spots pill ───────────────────────────────
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                const Icon(Icons.event_seat_rounded,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  isFull
                      ? 'No spots available — slot is full'
                      : '${slot.capacity - slot.bookedCount} spot${(slot.capacity - slot.bookedCount) == 1 ? '' : 's'} available',
                  style: AppTextStyles.caption.copyWith(
                    color: isFull
                        ? AppColors.accentRed
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
