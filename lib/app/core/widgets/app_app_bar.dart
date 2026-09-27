import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_text.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final bool isLogo;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;
  final bool automaticallyImplyLeading;

  const AppAppBar({
    super.key,
    this.title,
    this.titleText,
    this.isLogo = false,
    this.leading,
    this.actions,
    this.backgroundColor = AppColors.surfaceWhite,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    Widget? effectiveTitle = title;
    if (effectiveTitle == null && titleText != null) {
      effectiveTitle = isLogo
          ? AppText.displayLogo(titleText!)
          : AppText.screenTitle(titleText!);
    }

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: AppSpacing.l,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: effectiveTitle,
      actions: actions != null
          ? [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.l),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!
                      .expand((widget) => [widget, const SizedBox(width: AppSpacing.s)])
                      .toList()
                    ..removeLast(),
                ),
              ),
            ]
          : null,
    );
  }
}

/// Coin/Points gold pill badge used in AppAppBar actions
class AppPointsBadge extends StatelessWidget {
  final int points;
  final VoidCallback? onTap;

  const AppPointsBadge({
    super.key,
    required this.points,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.accentGold,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on,
              size: 16,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              '$points',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
