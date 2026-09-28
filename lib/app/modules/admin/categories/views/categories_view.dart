import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/modules/admin/categories/controllers/categories_controller.dart';
import 'package:harvest_hub/app/modules/admin/models/category_model.dart';
import 'package:harvest_hub/app/modules/admin/widgets/admin_drawer.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppAppBar(
        titleText: 'Categories',
        leading: Builder(
          builder: (ctx) => AppIconButton(
            icon: Icons.menu,
            iconSize: 22,
            backgroundColor: Colors.transparent,
            iconColor: AppColors.textPrimary,
            isCircle: false,
            onTap: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          AppIconButton(
            icon: Icons.refresh_rounded,
            iconSize: 20,
            backgroundColor: AppColors.surfaceMuted,
            iconColor: AppColors.primaryDark,
            tooltip: 'Refresh',
            onTap: controller.load,
          ),
          AppButton.small(
            label: 'Add Category',
            icon: Icons.add,
            onPressed: () => _showCategoryForm(context),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────────
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: AppSearchBar(
              hintText: 'Search categories...',
              onChanged: (v) => controller.search.value = v,
            ),
          ),

          const SizedBox(height: AppSpacing.s),

          // ── Category List ────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryButton),
                );
              }

              if (controller.error.value.isNotEmpty) {
                return _buildErrorState(context);
              }

              final list = controller.filtered;

              if (list.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.s,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (_, i) => _CategoryRow(
                  category: list[i],
                  onEdit: () => _showCategoryForm(context, list[i]),
                  onDelete: () => controller.delete(list[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.chipHerbsBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category_outlined,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'No categories yet',
              style: AppTextStyles.sectionHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Add your first category to start organising your produce.',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: 'Add Category',
              icon: Icons.add,
              onPressed: () => _showCategoryForm(context),
              width: 180,
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.m),
            Text(
              controller.error.value,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton.small(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: controller.load,
            ),
          ],
        ),
      ),
    );
  }

  // ── Add / Edit Bottom-Sheet Form ────────────────────────────────────────────
  void _showCategoryForm(BuildContext context, [CategoryModel? category]) {
    final isEditing = category != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Title row
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.chipHerbsBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Text(
                    isEditing ? 'Edit Category' : 'Add Category',
                    style: AppTextStyles.sectionHeading,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: AppSpacing.l),

              // Field label
              Text(
                'Category Name',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              AppTextField.outlined(
                hintText: 'e.g. Fresh Vegetables',
                prefixIcon: const Icon(
                  Icons.label_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonPrimaryRadius,
                        ),
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: AppButton.primary(
                      label: isEditing ? 'Save Changes' : 'Add Category',
                      icon: isEditing ? Icons.check : Icons.add,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        controller.save(category);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Row Card ─────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryRow({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = AppChip.getCategoryBgColor(category.name);
    final iconData = AppChip.getCategoryIcon(category.name);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          // ── Category Icon Bubble ────────────────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, size: 24, color: AppColors.primaryDark),
          ),
          const SizedBox(width: AppSpacing.m),

          // ── Name & Label ────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Category',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Edit / Delete Actions ───────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconButton(
                icon: Icons.edit_outlined,
                iconSize: 18,
                size: 36,
                backgroundColor: AppColors.chipHerbsBg,
                iconColor: AppColors.primaryDark,
                tooltip: 'Edit',
                onTap: onEdit,
                isCircle: false,
              ),
              const SizedBox(width: AppSpacing.s),
              AppIconButton(
                icon: Icons.delete_outline_rounded,
                iconSize: 18,
                size: 36,
                backgroundColor: const Color(0xFFFFEBEE),
                iconColor: AppColors.accentRed,
                tooltip: 'Delete',
                onTap: onDelete,
                isCircle: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
