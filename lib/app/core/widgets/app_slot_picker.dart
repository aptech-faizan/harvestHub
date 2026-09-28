import 'package:flutter/material.dart';
import '../../data/models/pickup_slot_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable time slot picker matching AppChip selectable pill styles.
/// Conforms to Master Rules and Section 6.5.
/// Used in Customer Checkout and Farmer App Pickup Slots screen.
class AppSlotPicker extends StatelessWidget {
  final List<PickupSlotModel> slots;
  final String? selectedSlotId;
  final ValueChanged<PickupSlotModel>? onSlotSelected;
  final String emptyMessage;

  const AppSlotPicker({
    super.key,
    required this.slots,
    this.selectedSlotId,
    this.onSlotSelected,
    this.emptyMessage = 'No pickup slots available',
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.divider, width: 1.0),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                emptyMessage,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: slots.map((slot) {
        final isSelected = selectedSlotId == slot.id;
        final isFull = slot.isFull;

        final Color backgroundColor;
        final Color textColor;
        final Color iconColor;
        final Border border;

        if (isFull) {
          backgroundColor = AppColors.surfaceMuted;
          textColor = AppColors.textDisabled;
          iconColor = AppColors.textDisabled;
          border = Border.all(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 1.0,
          );
        } else if (isSelected) {
          backgroundColor = AppColors.primaryDark;
          textColor = Colors.white;
          iconColor = Colors.white;
          border = Border.all(color: AppColors.primaryDark, width: 1.0);
        } else {
          backgroundColor = AppColors.surfaceWhite;
          textColor = AppColors.textPrimary;
          iconColor = AppColors.textSecondary;
          border = Border.all(color: AppColors.divider, width: 1.0);
        }

        return Material(
          color: backgroundColor,
          borderRadius: AppRadius.chipRadius,
          child: InkWell(
            onTap: isFull ? null : () => onSlotSelected?.call(slot),
            borderRadius: AppRadius.chipRadius,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.chipRadius,
                border: border,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFull
                        ? Icons.block_rounded
                        : (isSelected
                            ? Icons.check_circle_outline
                            : Icons.schedule_rounded),
                    size: 15,
                    color: iconColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    slot.label,
                    style: AppTextStyles.chipLabel.copyWith(
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (isFull) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Full',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
