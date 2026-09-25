import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/repositories/farmer_account_repository.dart';

/// Controller for farmer profile.
class ProfileController extends GetxController {
  final FarmerAccountRepository _repo;
  ProfileController(this._repo);

  FarmerAccountRepository get repository => _repo;

  final RxString name = 'Ahmed Raza'.obs;
  final RxString email = 'ahmed.raza@farm.pk'.obs;
  final RxString phone = '+92 300 1234567'.obs;
  final RxString farmName = 'Green Valley Farm'.obs;
  final RxString location = 'Lahore, Punjab'.obs;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.email != null && user.email!.isNotEmpty) {
        email.value = user.email!;
      }
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        name.value = user.displayName!;
      }
    }
  }
}
