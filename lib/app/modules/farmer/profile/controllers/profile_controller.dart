import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repository.dart';

/// Placeholder controller for farmer profile.
/// Full implementation will use the auth team's user model.
class ProfileController extends GetxController {
  final FarmerRepository _repo;
  ProfileController(this._repo);

  // Mocked profile data – will be replaced with auth team's currentUser
  final RxString name = 'Ahmed Raza'.obs;
  final RxString email = 'ahmed.raza@farm.pk'.obs;
  final RxString phone = '+92 300 1234567'.obs;
  final RxString farmName = 'Green Valley Farm'.obs;
  final RxString location = 'Lahore, Punjab'.obs;
}
