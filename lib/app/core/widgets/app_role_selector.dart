import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Segmented role toggle widget (Customer / Farmer) conforming to the HarvestHub Design System.
/// 48px height, surfaceMuted track with 12px radius, selected option filled primaryButton.
class AppRoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const AppRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    const roles = [
      (role: Roles.customer, label: 'Customer', icon: Icons.person_outline),
      (role: Roles.farmer, label: 'Farmer', icon: Icons.agriculture_outlined),
    ];

    return Container(
      height: 48.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.divider, width: 1.0),
      ),
      child: Row(
        children: roles.map((item) {
          final isSelected = selectedRole == item.role;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onRoleChanged(item.role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryButton
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: isSelected ? AppRadius.cardElevation : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 20.0,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.0,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
