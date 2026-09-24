import 'package:flutter/material.dart';
import '../../../data/models/farmer_order_model.dart';
import '../farmer_theme.dart';

/// Pill-style status chip with soft tinted background and crisp colored text.
class StatusChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusChip({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.icon,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  /// Factory constructor for OrderStatus
  factory StatusChip.fromOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const StatusChip(
          label: 'Pending',
          textColor: FarmerColors.statusPending,
          backgroundColor: FarmerColors.statusPendingBg,
          icon: Icons.access_time_rounded,
        );
      case OrderStatus.confirmed:
        return const StatusChip(
          label: 'Confirmed',
          textColor: FarmerColors.statusConfirmed,
          backgroundColor: FarmerColors.statusConfirmedBg,
          icon: Icons.check_circle_outline_rounded,
        );
      case OrderStatus.readyForPickup:
        return const StatusChip(
          label: 'Ready for Pickup',
          textColor: FarmerColors.statusReady,
          backgroundColor: FarmerColors.statusReadyBg,
          icon: Icons.shopping_bag_outlined,
        );
      case OrderStatus.completed:
        return const StatusChip(
          label: 'Completed',
          textColor: FarmerColors.primaryDark,
          backgroundColor: FarmerColors.statusCompletedBg,
          icon: Icons.done_all_rounded,
        );
      case OrderStatus.cancelled:
        return const StatusChip(
          label: 'Cancelled',
          textColor: FarmerColors.statusCancelled,
          backgroundColor: FarmerColors.statusCancelledBg,
          icon: Icons.cancel_outlined,
        );
    }
  }

  /// Factory constructor for Product Stock status
  factory StatusChip.stockBadge({
    required int stockQty,
    required bool isOutOfStock,
  }) {
    if (isOutOfStock || stockQty <= 0) {
      return const StatusChip(
        label: 'Out of Stock',
        textColor: FarmerColors.outOfStock,
        backgroundColor: FarmerColors.outOfStockBg,
        icon: Icons.block_rounded,
      );
    } else if (stockQty <= 5) {
      return StatusChip(
        label: 'Low Stock ($stockQty)',
        textColor: FarmerColors.lowStock,
        backgroundColor: FarmerColors.lowStockBg,
        icon: Icons.warning_amber_rounded,
      );
    } else {
      return StatusChip(
        label: 'In Stock ($stockQty)',
        textColor: FarmerColors.primaryDark,
        backgroundColor: FarmerColors.inStockBg,
        icon: Icons.check_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
