import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/theme/app_spacing.dart';
import 'package:harvest_hub/app/core/utils/validators.dart';
import 'package:harvest_hub/app/core/widgets/app_widgets.dart';
import 'package:harvest_hub/app/modules/auth/controllers/login_controller.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Single unified login screen for Customer, Farmer, and Admin.
/// Role is determined automatically from the user's data after authentication.
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl, // 24px horizontal padding
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420.0),
              child: Form(
                key: controller.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top: Logo + Welcome back + subtitle
                    const AppAuthHeader(
                      title: 'Welcome back',
                      subtitle: 'Sign in to your account',
                      logoWidth: 160.0,
                    ),

                    const SizedBox(height: 32.0), // 32px gap before form

                    // Email Field
                    AppTextField(
                      controller: controller.emailController,
                      hintText: 'Enter your email',
                      labelText: 'Email',
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

                    // Password Field with show/hide toggle
                    Obx(() => AppTextField(
                          controller: controller.passwordController,
                          hintText: 'Enter your password',
                          labelText: 'Password',
                          obscureText: controller.hidePassword.value,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => controller.login(),
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
                          validator: AppValidators.password(minLength: 1),
                        )),

                    const SizedBox(height: AppSpacing.xxl), // 24px gap

                    // Login Button (52px, 16px radius, full width)
                    Obx(() => AppButton.primary(
                          label: 'Login',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                        )),

                    const SizedBox(height: AppSpacing.xxl), // 24px gap

                    // Bottom: "Don't have an account?" + "Register"
                    //
                    // Wrap rather than Row: the two labels take their natural
                    // width, which overflowed by ~4px on a narrow surface. Wrap
                    // keeps them on one line when there is room and breaks to
                    // two when there is not - no clipping, no ellipsis.
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.0,
                      children: [
                        AppText.body(
                          "Don't have an account?",
                          color: AppColors.textSecondary,
                        ),
                        AppTextButton(
                          label: 'Register',
                          color: AppColors.primaryDark,
                          onPressed: () => Get.toNamed(Routes.register),
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

