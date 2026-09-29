import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/market_model.dart';
import 'package:harvest_hub/app/data/repositories/market_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class RegisterController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  /// Built on first farmer-market load. Kept lazy so merely opening the screen
  /// (and widget-testing it) never touches Firestore.
  MarketRepository? _marketRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  /// Role selection: Customer or Farmer only. Public Admin registration is forbidden.
  final RxString selectedRole = Roles.customer.obs;

  /// Active markets offered in the Farmer market dropdown.
  final markets = <MarketModel>[].obs;
  final isLoadingMarkets = false.obs;

  /// Empty means "not chosen yet", which is what the validator treats as invalid.
  final selectedMarketId = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool hidePassword = true.obs;

  bool _marketsRequested = false;

  /// Whether the user reached this screen by navigating over an existing login
  /// screen, which is then still sitting in the route stack underneath us.
  ///
  /// Captured once in [onInit] because it has to be read at the moment this
  /// screen was entered; by the time the user submits, [Get.previousRoute] has
  /// moved on.
  late final bool _loginRouteIsUnderneath;

  bool get isFarmer => selectedRole.value == Roles.farmer;

  @override
  void onInit() {
    super.onInit();
    _loginRouteIsUnderneath = Get.previousRoute == Routes.login;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Loads the active markets a Farmer can register into. Fired when the role
  /// flips to Farmer, so Customers never pay for a query they cannot use.
  Future<void> loadMarkets() async {
    if (_marketsRequested || isLoadingMarkets.value) return;
    _marketsRequested = true;
    isLoadingMarkets.value = true;
    try {
      _marketRepo ??= MarketRepository();
      markets.assignAll(await _marketRepo!.getActiveMarkets());
    } catch (e) {
      _marketsRequested = false; // let the admin retry
      showError('Could not load markets: ${errorText(e)}');
    } finally {
      isLoadingMarkets.value = false;
    }
  }

  void togglePasswordVisibility() {
    hidePassword.toggle();
  }

  void setRole(String role) {
    if (role == Roles.customer || role == Roles.farmer) {
      selectedRole.value = role;
      // Drop a stale choice so switching Customer -> Farmer -> Customer -> Farmer
      // never submits a market the admin no longer wants.
      if (role != Roles.farmer) {
        selectedMarketId.value = '';
      } else {
        loadMarkets();
      }
    }
  }

  void setMarket(String? marketId) {
    selectedMarketId.value = marketId ?? '';
  }

  MarketModel? get selectedMarket {
    for (final m in markets) {
      if (m.id == selectedMarketId.value) return m;
    }
    return null;
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Registration failed: ${e.code}';
    }
  }

  /// Returns the user to the login screen with a confirmation toast.
  void _redirectToLogin() {
    // The login screen the user came from is normally still in the route stack
    // underneath this one, with a live LoginController bound to it. Pushing a
    // *second* /login over the top with `Get.offAllNamed` makes GetX tear the
    // old /login down at the same time as it builds the new one, and the
    // controller the new screen was handed ends up disposed - so its
    // TextFields throw "A TextEditingController was used after being disposed"
    // the moment the user touches them.
    //
    // Popping back to the screen that is already there avoids creating a second
    // one altogether, and leaves the user with the same single-entry stack
    // (they cannot navigate back into the finished registration form).
    if (_loginRouteIsUnderneath) {
      Get.until((route) => route.settings.name == Routes.login);

      // Get.until returns void, so confirm it actually landed on login. If the
      // route was not there after all, never leave the user on a bare navigator.
      if (Get.currentRoute != Routes.login) {
        Get.offAllNamed(Routes.login);
      }
    } else {
      // Arrived here without a login screen underneath (a deep link, say), so
      // there is nothing to collide with and a clean stack is what is wanted.
      Get.offAllNamed(Routes.login);
    }

    // Raised after the redirect, in a post-frame callback. `Get.showSnackbar`
    // attaches to the current overlay, and the navigation above is still
    // settling at this point, so a toast raised before it is silently lost.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSuccess('Account created successfully! Please log in.');
    });
  }

  /// Registers a new Customer or Farmer, then returns them to the login screen.
  ///
  /// Registration deliberately does NOT sign the new account in: the user must
  /// log in with the credentials they just chose, so the login screen is shown
  /// with a confirmation toast instead of dropping them into their home.
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedRole.value != Roles.customer && selectedRole.value != Roles.farmer) {
      showError('Please select a valid role (Customer or Farmer).');
      return;
    }

    // Farmers can optionally be linked to a market on registration, or later via profile.
    MarketModel? market;
    if (isFarmer && selectedMarketId.value.isNotEmpty) {
      market = selectedMarket;
    }

    isLoading.value = true;
    var created = false;
    try {
      await authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        address: addressController.text.trim(),
        role: selectedRole.value,
        marketId: market?.id ?? '',
        marketName: market?.marketName ?? '',
      );
      created = true;
    } on FirebaseAuthException catch (e) {
      showError(_getAuthErrorMessage(e));
    } catch (e) {
      showError(errorText(e));
    } finally {
      // Runs before the redirect below, so the loading flag is cleared while
      // this controller is still alive rather than after offAllNamed disposes
      // the route.
      isLoading.value = false;
    }

    // Only follow the happy path into the login screen. A failure has already
    // surfaced its own error and must leave the form up so it can be corrected.
    if (!created) return;

    // Firebase signs the new account in as part of creating it, and
    // AuthService.register also caches the role and profile. Drop both before
    // redirecting: `/login` is guarded by GuestMiddleware, which sends any
    // still-authenticated user straight back to their home screen, which would
    // silently undo the redirect below.
    await authService.endSessionAfterRegistration();
    _redirectToLogin();
  }
}
