import 'package:flutter/material.dart';
import '../farmer_theme.dart';
import 'primary_button.dart';

/// Premium illustration-style empty state with layered circles,
/// title, descriptive subtitle, and optional CTA button.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color iconColor;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.iconColor = FarmerColors.primary,
    this.iconSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Layered tinted circle illustration
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.08),
              ),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withValues(alpha: 0.16),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: FarmerTextStyles.title.copyWith(
                fontWeight: FontWeight.w700,
                color: FarmerColors.text,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: FarmerTextStyles.body.copyWith(
                color: FarmerColors.muted,
                height: 1.4,
              ),
            ),

            // Optional CTA button
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onActionPressed,
                icon: Icons.add_rounded,
                width: 180,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
