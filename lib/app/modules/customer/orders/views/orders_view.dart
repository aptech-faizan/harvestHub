import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/data/models/order_model.dart';
import 'package:harvest_hub/app/data/repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../shell/controllers/customer_shell_controller.dart';
import '../controllers/orders_controller.dart';

/// Customer Orders screen conforming to the HarvestHub Design System:
/// - AppAppBar with title
/// - AppToggleTabs for "Current" / "History" views
/// - Vertical list of AppCard.list order items:
///   - Order ID and date (AppText)
///   - Status shown as AppChip (consistent color palettes)
///   - Item summary line with farmer & slot information
///   - Total price & contextual actions (AppTextButton "Change Slot" / "Cancel" / "Reorder")
class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  static final RxInt _selectedTab = 0.obs;

  void _openChangeSlotSheet(OrderModel order) {
    controller.loadSlotsFor(order);
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Pickup Slot',
                    style: AppTextStyles.sectionHeading,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Select a new available time slot for this order.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Obx(() {
                if (controller.availableSlots.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                    child: Center(
                      child: Text(
                        'No other pickup slots available for this farmer right now.',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return AppSlotPicker(
                  slots: controller.availableSlots,
                  selectedSlotId: order.pickupSlotId,
                  onSlotSelected: (slot) => controller.changeSlot(order, slot),
                );
              }),
              const SizedBox(height: AppSpacing.m),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCancelDialog(OrderModel order) {
    Get.defaultDialog(
      title: 'Cancel Order',
      titleStyle: AppTextStyles.sectionHeading,
      middleText: 'Are you sure you want to cancel this order?',
      middleTextStyle: AppTextStyles.bodyText,
      textConfirm: 'Yes, Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.accentRed,
      textCancel: 'Keep Order',
      cancelTextColor: AppColors.textPrimary,
      onConfirm: () {
        Get.back();
        controller.cancelOrder(order);
      },
    );
  }

  Future<void> _reorder(OrderModel order) async {
    try {
      final cart = Get.isRegistered<CartController>()
          ? Get.find<CartController>()
          : Get.put(CartController());
      int addedCount = 0;
      for (final item in order.items) {
        final pid = item['productId'] as String?;
        if (pid != null && pid.isNotEmpty) {
          final product = await ProductRepository().getProductById(pid);
          if (product != null && product.isActive && product.stockQty > 0) {
            cart.add(product);
            addedCount++;
          }
        }
      }
      if (addedCount > 0) {
        Get.snackbar(
          'Reorder',
          'Added $addedCount ${addedCount == 1 ? "item" : "items"} to your cart',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Notice',
          'Items from this order are currently out of stock',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not reorder: $e');
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Date not available';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: const AppAppBar(
        automaticallyImplyLeading: false,
        titleText: 'My Orders',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final allOrders = controller.orders;
        final currentOrders = allOrders.where((o) {
          return o.status != OrderStatus.completed &&
              o.status != OrderStatus.cancelled;
        }).toList();

        final historyOrders = allOrders.where((o) {
          return o.status == OrderStatus.completed ||
              o.status == OrderStatus.cancelled;
        }).toList();

        final displayedOrders = _selectedTab.value == 0 ? currentOrders : historyOrders;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadOrders,
          child: Column(
            children: [
              // Segmented Toggle Tabs: "Current" / "History"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                  vertical: AppSpacing.m,
                ),
                child: AppToggleTabs(
                  tabs: const ['Current', 'History'],
                  selectedIndex: _selectedTab.value,
                  counts: [currentOrders.length, historyOrders.length],
                  onTabChanged: (index) => _selectedTab.value = index,
                ),
              ),

              // Orders List or Empty State
              Expanded(
                child: displayedOrders.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 44,
                                  color: AppColors.textDisabled,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.l),
                              AppText.sectionHeading(
                                _selectedTab.value == 0
                                    ? 'No Active Orders'
                                    : 'No Order History',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AppText.body(
                                _selectedTab.value == 0
                                    ? 'You do not have any active orders being prepared or delivered.'
                                    : 'You have not completed or cancelled any orders yet.',
                                textAlign: TextAlign.center,
                                color: AppColors.textSecondary,
                              ),
                              if (_selectedTab.value == 0) ...[
                                const SizedBox(height: AppSpacing.xl),
                                AppButton.primary(
                                  label: 'Explore Fresh Produce',
                                  icon: Icons.search_rounded,
                                  width: 220,
                                  onPressed: () {
                                    if (Get.isRegistered<CustomerShellController>()) {
                                      Get.find<CustomerShellController>().changeTab(1);
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.screenHorizontalPadding,
                          right: AppSpacing.screenHorizontalPadding,
                          top: AppSpacing.xs,
                          bottom: AppSpacing.xxl,
                        ),
                        itemCount: displayedOrders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.m),
                        itemBuilder: (context, index) {
                          final order = displayedOrders[index];
                          final orderShortId = order.id.length >= 6
                              ? order.id.substring(0, 6).toUpperCase()
                              : order.id.toUpperCase();
                          final orderDate = _formatDate(order.createdAt);

                          return AppCard.list(
                            padding: const EdgeInsets.all(AppSpacing.l),
                            children: [
                              // Order ID, Date & Status Chip Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText.cardTitle(
                                        'Order #$orderShortId',
                                        fontWeight: FontWeight.w700,
                                      ),
                                      const SizedBox(height: 2),
                                      AppText.caption(
                                        orderDate,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                  AppChip.status(status: order.status),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.m),
                              const Divider(
                                color: AppColors.divider,
                                height: 1,
                              ),
                              const SizedBox(height: AppSpacing.m),

                              // Item Summary Line
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      order.items
                                          .map((i) =>
                                              '${i['name']} x${i['qty']}')
                                          .join(', '),
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // Farmer Name
                              if (order.farmerName.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.storefront_outlined,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Farmer: ${order.farmerName}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // Pickup Slot
                              if (order.pickupSlotTime.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_outlined,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Pickup Slot: ${order.pickupSlotTime}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: AppSpacing.m),
                              const Divider(
                                color: AppColors.divider,
                                height: 1,
                              ),
                              const SizedBox(height: AppSpacing.s),

                              // Price and Actions Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: AppTextStyles.caption,
                                      ),
                                      Text(
                                        'Rs. ${order.totalPrice.toStringAsFixed(0)}',
                                        style: AppTextStyles.priceText,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (order.canModify) ...[
                                        AppTextButton(
                                          label: 'Change Slot',
                                          leadingIcon: Icons.schedule_rounded,
                                          onPressed: () =>
                                              _openChangeSlotSheet(order),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        AppTextButton(
                                          label: 'Cancel',
                                          leadingIcon: Icons.close_rounded,
                                          color: AppColors.accentRed,
                                          onPressed: () =>
                                              _showCancelDialog(order),
                                        ),
                                      ] else if (order.status ==
                                              OrderStatus.completed ||
                                          order.status ==
                                              OrderStatus.cancelled) ...[
                                        AppTextButton(
                                          label: 'Reorder',
                                          leadingIcon: Icons.replay_rounded,
                                          color: AppColors.primary,
                                          onPressed: () => _reorder(order),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
