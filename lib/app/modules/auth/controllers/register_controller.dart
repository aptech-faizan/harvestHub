import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/market_model.dart';
import 'package:harvest_hub/app/data/repositories/market_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

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

  bool get isFarmer => selectedRole.value == Roles.farmer;

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

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedRole.value != Roles.customer && selectedRole.value != Roles.farmer) {
      showError('Please select a valid role (Customer or Farmer).');
      return;
    }

    // Farmers must be tied to a market; products and orders both depend on it.
    MarketModel? market;
    if (isFarmer) {
      market = selectedMarket;
      if (market == null) {
        showError(markets.isEmpty
            ? 'No active markets are available yet. Ask an admin to add one.'
            : 'Please select the market where you sell your produce.');
        return;
      }
    }

    isLoading.value = true;
    try {
      final role = await authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        address: addressController.text.trim(),
        role: selectedRole.value,
        marketId: market?.id ?? '',
        marketName: market?.marketName ?? '',
      );
      showSuccess('Registration successful!');
      authService.navigateToRoleHome(role);
    } on FirebaseAuthException catch (e) {
      showError(_getAuthErrorMessage(e));
    } catch (e) {
      showError(errorText(e));
    } finally {
      isLoading.value = false;
    }
  }
}
