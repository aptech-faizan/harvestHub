import 'package:flutter/material.dart';
import 'app_bounceable.dart';
import '../theme/app_colors.dart';

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = 20.0,
    this.color,
  });

  // Pre-configured icon tokens
  static const IconData search = Icons.search;
  static const IconData filter = Icons.tune;
  static const IconData notification = Icons.notifications_none_outlined;
  static const IconData notificationActive = Icons.notifications;
  static const IconData coin = Icons.monetization_on;
  static const IconData heartOutlined = Icons.favorite_border;
  static const IconData heartFilled = Icons.favorite;
  static const IconData star = Icons.star;
  static const IconData chevronRight = Icons.chevron_right;
  static const IconData plus = Icons.add;
  static const IconData minus = Icons.remove;
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;
  static const IconData explore = Icons.explore_outlined;
  static const IconData exploreFilled = Icons.explore;
  static const IconData cart = Icons.shopping_cart_outlined;
  static const IconData cartFilled = Icons.shopping_cart;
  static const IconData profile = Icons.person_outline;
  static const IconData profileFilled = Icons.person;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? AppColors.textSecondary,
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final Border? border;
  final String? tooltip;
  final bool isCircle;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.backgroundColor = AppColors.surfaceMuted,
    this.iconColor = AppColors.textPrimary,
    this.border,
    this.tooltip,
    this.isCircle = true,
  });

  // Wishlist heart button spec: circular, white bg, 1px divider border (default 32px or 40px)
  factory AppIconButton.wishlist({
    Key? key,
    required bool isWishlisted,
    required VoidCallback onTap,
    double size = 32.0,
    double iconSize = 18.0,
  }) {
    return AppIconButton(
      key: key,
      icon: isWishlisted ? AppIcon.heartFilled : AppIcon.heartOutlined,
      onTap: onTap,
      size: size,
      iconSize: iconSize,
      backgroundColor: AppColors.surfaceWhite,
      iconColor: isWishlisted ? AppColors.accentRed : AppColors.textSecondary,
      border: Border.all(color: AppColors.divider, width: 1.0),
      isCircle: true,
      tooltip: isWishlisted ? 'Remove from Wishlist' : 'Add to Wishlist',
    );
  }

  // Filter icon button for search bar: 48x48px, radius 12px
  factory AppIconButton.filter({
    Key? key,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return AppIconButton(
      key: key,
      icon: AppIcon.filter,
      onTap: onTap,
      size: 48.0,
      iconSize: 20.0,
      backgroundColor: isActive ? AppColors.chipHerbsBg : AppColors.surfaceMuted,
      iconColor: isActive ? AppColors.primaryDark : AppColors.textPrimary,
      isCircle: false,
      tooltip: 'Filter',
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = isCircle ? BorderRadius.circular(size / 2) : BorderRadius.circular(12.0);

    Widget button = Material(
      color: backgroundColor ?? Colors.transparent,
      shape: isCircle
          ? CircleBorder(side: border?.top ?? BorderSide.none)
          : RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: border?.top ?? BorderSide.none,
            ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: isCircle ? const CircleBorder() : RoundedRectangleBorder(borderRadius: borderRadius),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return AppBounceable(
      onTap: null, // InkWell handles actual onTap
      enabled: onTap != null,
      child: button,
    );
  }
}
