import 'package:get/get.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Checks authentication state and stored role on app startup and redirects accordingly.
class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    checkAuthAndRedirect();
  }

  Future<void> checkAuthAndRedirect() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      if (_authService.currentUser == null) {
        Get.offAllNamed(Routes.login);
        return;
      }

      final role = await _authService.loadUserRoleAndProfile();
      if (role != null && role.isNotEmpty) {
        _authService.navigateToRoleHome(role);
      } else {
        await _authService.logout();
      }
    } catch (_) {
      await _authService.logout();
    }
  }
}
