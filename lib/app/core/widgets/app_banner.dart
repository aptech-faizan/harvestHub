import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Widget? trailingImage;
  final VoidCallback? onTap;
  final bool isDiscount;
  final String? ctaText;

  const AppBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.trailingImage,
    this.onTap,
    this.ctaText,
  }) : isDiscount = false;

  const AppBanner.discount({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText = '50% Off',
    this.trailingImage,
    this.onTap,
    this.ctaText,
  }) : isDiscount = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144.0,
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardRadius,
        gradient: isDiscount
            ? const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFC62828)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.bannerBgStart, AppColors.bannerBgEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: AppRadius.cardElevation,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Stack(
            children: [
              // Subtle background decorative circles
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDiscount ? Colors.white : AppColors.primary)
                        .withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Row(
                  children: [
                    // Text Column
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (badgeText != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: isDiscount
                                    ? Colors.white
                                    : AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badgeText!,
                                style: AppTextStyles.caption.copyWith(
                                  color: isDiscount
                                      ? AppColors.accentRed
                                      : AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s),
                          ],
                          Text(
                            title,
                            style: AppTextStyles.sectionHeading.copyWith(
                              color: isDiscount ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle!,
                              style: AppTextStyles.caption.copyWith(
                                color: isDiscount
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (ctaText != null) ...[
                            const SizedBox(height: AppSpacing.s),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ctaText!,
                                  style: AppTextStyles.linkText.copyWith(
                                    color: isDiscount
                                        ? Colors.white
                                        : AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: isDiscount
                                      ? Colors.white
                                      : AppColors.primaryDark,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    // Trailing Graphic or Image
                    Expanded(
                      flex: 4,
                      child: trailingImage ??
                          Center(
                            child: Icon(
                              isDiscount ? Icons.local_offer : Icons.eco,
                              size: 70,
                              color: (isDiscount
                                      ? Colors.white
                                      : AppColors.primaryDark)
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
