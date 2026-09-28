import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/customer/shell/controllers/customer_shell_controller.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Order Success view displayed after placing a customer reservation order.
class OrderSuccessView extends StatefulWidget {
  const OrderSuccessView({super.key});

  @override
  State<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<OrderSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToOrders() {
    Get.offAllNamed(Routes.customerShell);
    if (Get.isRegistered<CustomerShellController>()) {
      Get.find<CustomerShellController>().changeTab(3);
    }
  }

  void _navigateToHome() {
    Get.offAllNamed(Routes.customerShell);
    if (Get.isRegistered<CustomerShellController>()) {
      Get.find<CustomerShellController>().changeTab(0);
    }
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: valueStyle ?? AppTextStyles.cardTitle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map<String, dynamic>?) ?? {};

    final orderId = args['orderId']?.toString();
    final itemCount = args['itemCount'] is int ? args['itemCount'] as int : null;
    final pickupSlot = args['pickupSlot']?.toString();
    final farmerName = args['farmerName']?.toString();
    final totalAmount = args['totalAmount'] is num ? (args['totalAmount'] as num).toDouble() : null;

    final shortOrderId = (orderId != null && orderId.isNotEmpty)
        ? (orderId.length > 12 ? '#${orderId.substring(0, 10)}...' : '#$orderId')
        : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateToHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceWhite,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: AppSpacing.l,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppSpacing.l),

                          // Animated Hero Checkmark + Confetti Burst
                          AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(140, 140),
                                    painter: _ConfettiBurstPainter(
                                      progress: _animController.value,
                                    ),
                                  ),
                                  // Soft primary tint ring
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  // Solid primary button circle with white check icon
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryButton,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x2643A047),
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.l),

                          // Title
                          Text(
                            'Order Placed!',
                            style: AppTextStyles.screenTitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.s),

                          // Subtitle
                          Text(
                            'Thank you for supporting local farmers. Your order has been received.',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Order Summary Card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: AppRadius.cardRadius,
                              border: Border.all(
                                color: AppColors.divider,
                                width: 1.0,
                              ),
                              boxShadow: AppRadius.cardElevation,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.l),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (shortOrderId != null)
                                  _buildSummaryRow(
                                    label: 'Order ID',
                                    value: shortOrderId,
                                  ),
                                if (itemCount != null && itemCount > 0)
                                  _buildSummaryRow(
                                    label: 'Items',
                                    value: '$itemCount ${itemCount == 1 ? "item" : "items"}',
                                  ),
                                if (pickupSlot != null && pickupSlot.isNotEmpty)
                                  _buildSummaryRow(
                                    label: 'Pickup Slot',
                                    value: pickupSlot,
                                  ),
                                if (farmerName != null && farmerName.isNotEmpty)
                                  _buildSummaryRow(
                                    label: 'Farmer / Market',
                                    value: farmerName,
                                  ),
                                if (totalAmount != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  const Divider(
                                    color: AppColors.divider,
                                    height: 16,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: AppTextStyles.sectionHeading,
                                      ),
                                      Text(
                                        '₹${totalAmount.toStringAsFixed(0)}',
                                        style: AppTextStyles.totalPriceText,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.m),

                          // Small Info Line with clock icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 15,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'You can track or change your pickup slot from Orders.',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),

                  // Bottom pinned buttons
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton.primary(
                          label: 'View My Orders',
                          onPressed: _navigateToOrders,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        AppTextButton(
                          label: 'Continue Shopping',
                          onPressed: _navigateToHome,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering a celebratory burst of small particles / leaves.
class _ConfettiBurstPainter extends CustomPainter {
  final double progress;

  _ConfettiBurstPainter({required this.progress});

  static const List<Color> _palette = [
    AppColors.primaryButton,
    AppColors.primaryDark,
    AppColors.accentGold,
    AppColors.accentOrange,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.05) return;

    final center = Offset(size.width / 2, size.height / 2);
    final count = 12;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi / count) * i + (pi / 12);
      final color = _palette[i % _palette.length];
      final minRadius = 40.0;
      final maxRadius = 66.0;
      final distance = minRadius + (maxRadius - minRadius) * progress;

      final particleX = center.dx + cos(angle) * distance;
      final particleY = center.dy + sin(angle) * distance;

      final paint = Paint()
        ..color = color.withValues(alpha: (1.0 - progress * 0.4).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final radius = (i % 2 == 0) ? 3.5 : 2.5;
      canvas.drawCircle(Offset(particleX, particleY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
