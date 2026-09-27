import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppNavItem {
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final int badgeCount;

  const AppNavItem({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.0,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              final iconColor = isSelected ? AppColors.primary : AppColors.textSecondary;
              final textStyle = isSelected
                  ? AppTextStyles.navLabelActive
                  : AppTextStyles.navLabelInactive;

              Widget iconWidget = Icon(
                isSelected ? item.filledIcon : item.outlineIcon,
                size: 22.0,
                color: iconColor,
              );

              if (item.badgeCount > 0) {
                iconWidget = Badge(
                  label: Text('${item.badgeCount}'),
                  backgroundColor: AppColors.accentRed,
                  child: iconWidget,
                );
              }

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconWidget,
                        const SizedBox(height: 3.0),
                        Text(
                          item.label,
                          style: textStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
