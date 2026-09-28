import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Floating AI Assistant (Harvey) button for the Customer shell.
/// Conforms to Section 5 & Master Rules: 52x52 circular button,
/// primaryButton background (#43A047), white smart_toy_outlined icon,
/// elevationCard shadow, and a "Harvey" tooltip/label.
class AppAssistantFab extends StatelessWidget {
  final VoidCallback? onTap;

  const AppAssistantFab({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Harvey AI Assistant',
      button: true,
      child: Tooltip(
        message: 'Harvey',
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.surfaceWhite),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(8.0),
        ),
        preferBelow: false,
        verticalOffset: 34.0,
        child: Container(
          width: 52.0,
          height: 52.0,
          decoration: BoxDecoration(
            color: AppColors.primaryButton,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x3343A047), // 20% primary glow
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
              ...AppRadius.cardElevation,
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap ?? () => Get.toNamed(Routes.assistantScreen),
              customBorder: const CircleBorder(),
              splashColor: AppColors.primaryButtonPressed.withValues(alpha: 0.3),
              highlightColor: AppColors.primaryButtonPressed.withValues(alpha: 0.2),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  size: 26.0,
                  color: AppColors.surfaceWhite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom FAB location for Harvey:
/// Positions the button at bottom-RIGHT (endFloat) with 16px right margin and 16px above
/// the bottom navigation bar (with clearance for pinned checkout bar on Cart).
class AppAssistantFabLocation extends FloatingActionButtonLocation {
  final bool hasPinnedBottomBar;

  const AppAssistantFabLocation({this.hasPinnedBottomBar = false});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabWidth = scaffoldGeometry.floatingActionButtonSize.width;
    final double fabX = scaffoldGeometry.scaffoldSize.width - fabWidth - 16.0;
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double extraOffset = hasPinnedBottomBar ? 88.0 : 0.0;
    final double fabY = contentBottom - fabHeight - 16.0 - extraOffset;
    return Offset(fabX, fabY);
  }
}
