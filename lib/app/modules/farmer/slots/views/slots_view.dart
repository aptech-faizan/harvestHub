import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../farmer_theme.dart';
import '../../widgets/farmer_widgets.dart';
import '../controllers/slots_controller.dart';

/// Modern Pickup Slots scheduling screen with interactive date strip,
/// slot capacity progress cards, and bottom sheet slot creator/editor.
class SlotsView extends StatefulWidget {
  const SlotsView({super.key});

  @override
  State<SlotsView> createState() => _SlotsViewState();
}

class _SlotsViewState extends State<SlotsView> {
  final SlotsController controller = Get.find<SlotsController>();
  int _selectedDayIndex = 0;

  // Mock slot data for UI demonstration until backend slot API is connected
  final List<_PickupSlotData> _slots = [
    _PickupSlotData(
      id: 'slot_1',
      startTime: '08:00 AM',
      endTime: '10:00 AM',
      bookedOrders: 8,
      maxCapacity: 10,
      isActive: true,
    ),
    _PickupSlotData(
      id: 'slot_2',
      startTime: '10:30 AM',
      endTime: '12:30 PM',
      bookedOrders: 10,
      maxCapacity: 10,
      isActive: true,
    ),
    _PickupSlotData(
      id: 'slot_3',
      startTime: '02:00 PM',
      endTime: '04:00 PM',
      bookedOrders: 3,
      maxCapacity: 12,
      isActive: true,
    ),
    _PickupSlotData(
      id: 'slot_4',
      startTime: '04:30 PM',
      endTime: '06:30 PM',
      bookedOrders: 0,
      maxCapacity: 8,
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Back',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: FarmerColors.text),
            onPressed: () => Get.back(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pickup Slots',
              style: TextStyle(
                color: FarmerColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Manage farm gate customer collections',
              style: FarmerTextStyles.caption.copyWith(
                color: FarmerColors.muted,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: FarmerColors.border, height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSlotEditorSheet(context, null),
        backgroundColor: FarmerColors.primaryDark,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Add Slot',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          // 1. Horizontal Date Strip Selector
          StaggeredFadeSlide(
            index: 0,
            child: _HorizontalDateStrip(
              selectedIndex: _selectedDayIndex,
              onSelectDay: (idx) {
                setState(() {
                  _selectedDayIndex = idx;
                });
              },
            ),
          ),
          const SizedBox(height: 18),

          // 2. Capacity Overview Banner
          StaggeredFadeSlide(
            index: 1,
            child: _SlotsOverviewHeader(slots: _slots),
          ),
          const SizedBox(height: 16),

          // 3. Slot Cards
          if (_slots.isEmpty)
            const EmptyState(
              icon: Icons.access_time_rounded,
              title: 'No Slots for this Date',
              message: 'Tap "+ Add Slot" to open a pickup window for buyers.',
            )
          else
            ...List.generate(_slots.length, (index) {
              final slot = _slots[index];
              return StaggeredFadeSlide(
                index: index + 2,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PickupSlotCard(
                    slot: slot,
                    onEdit: () => _openSlotEditorSheet(context, slot),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _openSlotEditorSheet(BuildContext context, _PickupSlotData? existing) {
    final startCtrl = TextEditingController(text: existing?.startTime ?? '09:00 AM');
    final endCtrl = TextEditingController(text: existing?.endTime ?? '11:00 AM');
    final capacityCtrl =
        TextEditingController(text: existing?.maxCapacity.toString() ?? '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FarmerColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                existing == null ? 'Create Pickup Slot' : 'Edit Pickup Window',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: FarmerColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Designate collection hours and maximum order handling quota.',
                style: FarmerTextStyles.caption.copyWith(color: FarmerColors.muted),
              ),
              const SizedBox(height: 20),

              // Time fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startCtrl,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: const Icon(Icons.access_time_rounded,
                            size: 18, color: FarmerColors.primary),
                        filled: true,
                        fillColor: FarmerColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: FarmerColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endCtrl,
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        prefixIcon: const Icon(Icons.access_time_filled_rounded,
                            size: 18, color: FarmerColors.primary),
                        filled: true,
                        fillColor: FarmerColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: FarmerColors.border),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Max Capacity
              TextField(
                controller: capacityCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max Orders Allowed',
                  hintText: 'e.g. 10',
                  prefixIcon: const Icon(Icons.group_outlined,
                      size: 20, color: FarmerColors.primary),
                  filled: true,
                  fillColor: FarmerColors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: FarmerColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                label: existing == null ? 'Save Pickup Slot' : 'Update Slot',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Get.snackbar(
                    'Success',
                    'Pickup slot scheduled successfully.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: FarmerColors.primary,
                    colorText: Colors.white,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Horizontal Date Strip ─────────────────────────────────────────────────────

class _HorizontalDateStrip extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectDay;

  const _HorizontalDateStrip({
    required this.selectedIndex,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: List.generate(7, (index) {
          final day = now.add(Duration(days: index));
          final isSelected = selectedIndex == index;
          final weekdayStr = DateFormat('EEE').format(day);
          final dayStr = DateFormat('d').format(day);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '$weekdayStr $dayStr',
              child: InkWell(
                onTap: () => onSelectDay(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FarmerColors.primaryDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? FarmerColors.primaryDark
                          : FarmerColors.border,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: FarmerColors.primaryDark
                                  .withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : FarmerColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        weekdayStr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white70 : FarmerColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayStr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : FarmerColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? FarmerColors.secondary
                              : (index < 3
                                  ? FarmerColors.primary
                                  : Colors.transparent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Overview Header Banner ────────────────────────────────────────────────────

class _SlotsOverviewHeader extends StatelessWidget {
  final List<_PickupSlotData> slots;
  const _SlotsOverviewHeader({required this.slots});

  @override
  Widget build(BuildContext context) {
    final totalCapacity = slots.fold<int>(0, (sum, s) => sum + s.maxCapacity);
    final totalBooked = slots.fold<int>(0, (sum, s) => sum + s.bookedOrders);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FarmerColors.border),
        boxShadow: FarmerColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FarmerColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_rounded,
                color: FarmerColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Collection Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: FarmerColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalBooked of $totalCapacity pickup slots reserved',
                  style: FarmerTextStyles.caption.copyWith(
                    color: FarmerColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: FarmerColors.secondaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${slots.length} Windows',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: FarmerColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pickup Slot Card ──────────────────────────────────────────────────────────

class _PickupSlotCard extends StatelessWidget {
  final _PickupSlotData slot;
  final VoidCallback onEdit;

  const _PickupSlotCard({
    required this.slot,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final double capacityProgress =
        (slot.bookedOrders / slot.maxCapacity).clamp(0.0, 1.0);
    final bool isFull = slot.bookedOrders >= slot.maxCapacity;

    Color progressColor;
    if (isFull) {
      progressColor = FarmerColors.error;
    } else if (capacityProgress >= 0.75) {
      progressColor = FarmerColors.lowStock;
    } else {
      progressColor = FarmerColors.inStock;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time Interval
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: FarmerColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.access_time_rounded,
                        color: FarmerColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${slot.startTime} – ${slot.endTime}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: FarmerColors.text,
                    ),
                  ),
                ],
              ),

              // Status Chip
              if (!slot.isActive)
                const StatusChip(
                  label: 'Closed',
                  textColor: FarmerColors.muted,
                  backgroundColor: FarmerColors.surfaceMuted,
                  icon: Icons.block_rounded,
                )
              else if (isFull)
                const StatusChip(
                  label: 'Full',
                  textColor: FarmerColors.outOfStock,
                  backgroundColor: FarmerColors.outOfStockBg,
                  icon: Icons.cancel_rounded,
                )
              else
                StatusChip(
                  label: '${slot.maxCapacity - slot.bookedOrders} Open',
                  textColor: FarmerColors.inStock,
                  backgroundColor: FarmerColors.inStockBg,
                  icon: Icons.check_circle_rounded,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Capacity Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booked: ${slot.bookedOrders}/${slot.maxCapacity} orders',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
              Text(
                '${(capacityProgress * 100).toInt()}% Capacity',
                style: FarmerTextStyles.caption.copyWith(
                  color: FarmerColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: capacityProgress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8EFE5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined,
                    size: 15, color: FarmerColors.primary),
                label: const Text(
                  'Edit Slot',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: FarmerColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickupSlotData {
  final String id;
  final String startTime;
  final String endTime;
  final int bookedOrders;
  final int maxCapacity;
  final bool isActive;

  _PickupSlotData({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.bookedOrders,
    required this.maxCapacity,
    required this.isActive,
  });
}
