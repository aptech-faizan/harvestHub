import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_radius.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/theme/app_text_styles.dart';
import 'package:harvest_hub/app/core/utils/validators.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/auth/controllers/register_controller.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Single unified registration screen for Customer and Farmer.
/// Admin registration is prohibited publicly.
class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppAppBar(
        titleText: 'Create Account',
        leadingWidth: 56.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.l),
          child: AppIconButton(
            icon: Icons.arrow_back_rounded,
            iconColor: AppColors.primaryDark,
            backgroundColor: AppColors.surfaceMuted,
            size: 40.0,
            tooltip: 'Back',
            onTap: () => Get.back(),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl, // 24px horizontal padding
              vertical: AppSpacing.l,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420.0),
              child: Form(
                key: controller.formKey,
                // Surface mistakes as the user types rather than all at once
                // when they press Register.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top: Logo + Join HarvestHub + subtitle
                    const AppAuthHeader(
                      title: 'Join HarvestHub',
                      subtitle: 'Select your account type and fill in your details',
                      logoWidth: 120.0,
                    ),

                    const SizedBox(height: 24.0),

                    // Role Selector: Customer or Farmer
                    const AppText.body(
                      'Register as:',
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Obx(() => AppRoleSelector(
                          selectedRole: controller.selectedRole.value,
                          onRoleChanged: controller.setRole,
                        )),

                    const SizedBox(height: AppSpacing.l), // 16px gap

                    // Full Name
                    AppTextField(
                      controller: controller.nameController,
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      validator: AppValidators.name(label: 'Full name'),
                    ),

                    const SizedBox(height: AppSpacing.l), // 16px gap

                    // Email
                    AppTextField(
                      controller: controller.emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      validator: AppValidators.email(),
                    ),

                    const SizedBox(height: AppSpacing.l), // 16px gap

                    // Phone Number
                    AppTextField(
                      controller: controller.phoneController,
                      labelText: 'Phone Number',
                      hintText: '03001234567 or +923001234567',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      validator: AppValidators.phone(),
                    ),

                    const SizedBox(height: AppSpacing.l), // 16px gap

                    // Address
                    AppTextField(
                      controller: controller.addressController,
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      validator: AppValidators.address(),
                    ),

                    // Farmer-only: optionally link the account to a market
                    Obx(() {
                      if (!controller.isFarmer) return const SizedBox.shrink();
                      if (controller.isLoadingMarkets.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          ),
                        );
                      }
                      if (controller.markets.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final ids = controller.markets.map((m) => m.id).toList();
                      final value = ids.contains(controller.selectedMarketId.value)
                          ? controller.selectedMarketId.value
                          : null;
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.l),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: value,
                          style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.surfaceMuted,
                            labelText: 'Market (Optional)',
                            hintText: 'Select your market (optional)',
                            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12.0, right: 8.0),
                              child: Icon(Icons.storefront_outlined, size: 20, color: AppColors.textSecondary),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 20),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 13.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.inputRadius,
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.inputRadius,
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.inputRadius,
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('None / Select later'),
                            ),
                            ...controller.markets.map((m) => DropdownMenuItem(
                                  value: m.id,
                                  child: Text(
                                    m.marketName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                          ],
                          onChanged: controller.setMarket,
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.l), // 16px gap

                    // Password with helper text
                    Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              controller: controller.passwordController,
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              obscureText: controller.hidePassword.value,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => controller.register(),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.hidePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                              validator: AppValidators.password(),
                            ),
                            const SizedBox(height: 4.0),
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: AppText.caption(
                                'Minimum 6 characters',
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )),

                    const SizedBox(height: AppSpacing.xxl), // 24px gap

                    // Register Button (52px, 16px radius, full width)
                    Obx(() => AppButton.primary(
                          label: 'Register',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.register,
                        )),

                    const SizedBox(height: AppSpacing.xxl), // 24px gap

                    // Bottom: "Already have an account?" + "Login"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText.body(
                          'Already have an account?',
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4.0),
                        AppTextButton(
                          label: 'Login',
                          color: AppColors.primaryDark,
                          onPressed: () => Get.toNamed(Routes.login),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

