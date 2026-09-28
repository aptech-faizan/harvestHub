import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/farmer_model.dart';
import 'package:harvest_hub/app/data/models/market_model.dart';
import 'package:harvest_hub/app/data/models/user_model.dart';
import 'package:harvest_hub/app/data/repositories/farmer_repository.dart';
import 'package:harvest_hub/app/data/repositories/market_repository.dart';
import 'package:harvest_hub/app/data/repositories/product_repository.dart';
import 'package:harvest_hub/app/data/repositories/user_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/controllers/farmer_dashboard_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmerProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _farmerRepo = FarmerRepository();
  final _userRepo = UserRepository();
  final _marketRepo = MarketRepository();
  final _productRepo = ProductRepository();
  final _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final hideCurrent = true.obs;
  final hideNew = true.obs;

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final addressC = TextEditingController();
  final businessC = TextEditingController();
  final descriptionC = TextEditingController();
  final currentPassC = TextEditingController();
  final newPassC = TextEditingController();

  final markets = <MarketModel>[].obs;
  final selectedMarketId = ''.obs;
  final rating = 0.0.obs;
  final lowStockThreshold = 5.obs;
  final email = ''.obs;
  final isVerified = false.obs;
  final farmerDocId = ''.obs;

  String get uid => authService.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    businessC.dispose();
    descriptionC.dispose();
    currentPassC.dispose();
    newPassC.dispose();
    super.onClose();
  }

  Future<void> load() async {
    if (isClosed || uid.isEmpty) return;
    isLoading.value = true;
    try {
      final activeMarkets = await _marketRepo.getActiveMarkets();
      if (isClosed) return;
      markets.assignAll(activeMarkets);

      final user = await _userRepo.getUser(uid);
      if (isClosed) return;

      final farmer = (await _farmerRepo.getFarmerById(uid)) ??
          (await _farmerRepo.getFarmerByUserId(uid));
      if (isClosed) return;

      email.value = user?.email ?? authService.currentUser?.email ?? '';
      nameC.text = user?.name ?? '';
      phoneC.text = user?.phone ?? '';
      addressC.text = user?.address ?? '';

      farmerDocId.value = farmer?.id ?? uid;
      businessC.text = farmer?.businessName.isNotEmpty == true
          ? farmer!.businessName
          : (user?.name ?? '');
      descriptionC.text = farmer?.description ?? '';
      selectedMarketId.value = farmer?.marketId ?? '';
      rating.value = farmer?.rating ?? 0;
      lowStockThreshold.value = farmer?.lowStockThreshold ?? 5;
      isVerified.value = farmer?.isVerified ?? false;
    } catch (e) {
      if (!isClosed) {
        showError('Could not load profile: ${errorText(e)}');
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> save() async {
    if (isClosed || uid.isEmpty) return;
    final name = nameC.text.trim();
    final phone = phoneC.text.trim();
    final business = businessC.text.trim();
    if (name.isEmpty || phone.isEmpty || business.isEmpty) {
      showError('Name, phone and business name are required.');
      return;
    }

    isSaving.value = true;
    try {
      await _userRepo.updateUser(uid, {
        'name': name,
        'phone': phone,
        'address': addressC.text.trim(),
      });
      if (isClosed) return;

      final selectedMarket = markets.firstWhereOrNull(
        (m) => m.id == selectedMarketId.value,
      );
      final effectiveMarketId = selectedMarket != null ? selectedMarket.id : '';
      final effectiveMarketName =
          selectedMarket != null ? selectedMarket.marketName : '';

      final targetDocId = farmerDocId.value.isNotEmpty ? farmerDocId.value : uid;
      final farmer = FarmerModel(
        id: targetDocId,
        userId: uid,
        marketId: effectiveMarketId,
        marketName: effectiveMarketName,
        businessName: business,
        description: descriptionC.text.trim(),
        rating: rating.value,
        lowStockThreshold: lowStockThreshold.value,
        isVerified: isVerified.value,
      );
      await _farmerRepo.upsertFarmer(farmer);
      if (isClosed) return;

      if (farmer.marketId.isNotEmpty) {
        final market = await _marketRepo.getMarketById(farmer.marketId);
        if (isClosed) return;
        await _productRepo.syncFarmerDenormOnProducts(
          farmerId: uid,
          farmerName: farmer.businessName,
          marketId: farmer.marketId,
          marketName: market?.marketName ?? '',
          lat: market?.lat ?? 0,
          lng: market?.lng ?? 0,
        );
        if (isClosed) return;
      }

      authService.currentUserModel.value = UserModel(
        uid: uid,
        name: name,
        email: email.value,
        phone: phone,
        address: addressC.text.trim(),
        role: Roles.farmer,
        isActive: true,
        photoUrl: authService.currentUserModel.value?.photoUrl ?? '',
      );

      if (Get.isRegistered<FarmerDashboardController>()) {
        await Get.find<FarmerDashboardController>().loadFarmerData();
      }
      if (!isClosed) {
        showSuccess('Profile saved');
      }
    } catch (e) {
      if (!isClosed) {
        showError('Save failed: ${errorText(e)}');
      }
    } finally {
      if (!isClosed) {
        isSaving.value = false;
      }
    }
  }

  Future<void> changePassword() async {
    if (isClosed) return;
    final current = currentPassC.text;
    final next = newPassC.text;
    if (next.length < 6) {
      showError('New password must be at least 6 characters.');
      return;
    }
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;
    isSaving.value = true;
    try {
      final cred = EmailAuthProvider.credential(email: user.email!, password: current);
      await user.reauthenticateWithCredential(cred);
      if (isClosed) return;
      await user.updatePassword(next);
      if (!isClosed) {
        currentPassC.clear();
        newPassC.clear();
        showSuccess('Password updated');
      }
    } on FirebaseAuthException catch (e) {
      if (!isClosed) {
        showError(e.message ?? 'Could not change password');
      }
    } catch (e) {
      if (!isClosed) {
        showError(errorText(e));
      }
    } finally {
      if (!isClosed) {
        isSaving.value = false;
      }
    }
  }
}
