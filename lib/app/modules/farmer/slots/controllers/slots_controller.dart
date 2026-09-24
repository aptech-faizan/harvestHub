import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repository.dart';

/// Placeholder controller for pickup-slot scheduling.
/// Full implementation is planned for the next sprint.
class SlotsController extends GetxController {
  final FarmerRepository _repo;
  SlotsController(this._repo);

  FarmerRepository get repository => _repo;
}
