import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Reusable segmented tab toggle widget conforming to Master Rules.
/// Used for switching views like "Current" / "History" orders.
class AppToggleTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<int>? counts;

  const AppToggleTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.divider, width: 1.0),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          final label = tabs[index];
          final count = (counts != null && index < counts!.length)
              ? counts![index]
              : null;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.surfaceWhite : Colors.transparent,
                  borderRadius: BorderRadius.circular(9.0),
                  boxShadow: isSelected ? AppRadius.cardElevation : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: isSelected
                          ? AppTextStyles.cardTitle.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0,
                            )
                          : AppTextStyles.bodyText.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                            ),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.chipHerbsBg
                              : AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
