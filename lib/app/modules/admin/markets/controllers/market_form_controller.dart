import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/modules/admin/markets/controllers/markets_controller.dart';
import 'package:harvest_hub/app/modules/admin/models/market_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';
import 'package:latlong2/latlong.dart';

/// Drives the dedicated Add/Edit market form (replaces the old text dialog).
///
/// Writes `gpsCoordinates` as a Firestore [GeoPoint] per the SRS
/// `Farmers_Market` collection, while keeping the flat `lat`/`lng` keys that
/// existing documents and [MarketModel.hasCoordinates] still rely on.
class MarketFormController extends GetxController {
  final repo = AdminRepository();

  MarketModel? editing;

  final formKey = GlobalKey<FormState>();
  final isSaving = false.obs;

  final isActive = true.obs;
  final manualCoordinates = false.obs;
  final Rxn<LatLng> position = Rxn<LatLng>();

  final nameC = TextEditingController();
  final addressC = TextEditingController();
  final hoursC = TextEditingController();
  final latC = TextEditingController();
  final lngC = TextEditingController();

  bool get isEdit => editing != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is MarketModel) editing = args;
    _prefill();
  }

  @override
  void onClose() {
    nameC.dispose();
    addressC.dispose();
    hoursC.dispose();
    latC.dispose();
    lngC.dispose();
    super.onClose();
  }

  void _prefill() {
    final m = editing;
    if (m == null) return;
    nameC.text = m.marketName;
    addressC.text = m.address;
    hoursC.text = m.operatingHours;
    isActive.value = m.activeStatus;
    if (m.hasCoordinates) {
      setPosition(LatLng(m.latitude, m.longitude), syncFields: true);
    }
  }

  /// Single entry point for coordinate changes (map tap, pin drag, manual input).
  void setPosition(LatLng p, {bool syncFields = true}) {
    position.value = p;
    if (!syncFields) return;
    latC.text = p.latitude.toStringAsFixed(6);
    lngC.text = p.longitude.toStringAsFixed(6);
  }

  void toggleManualCoordinates() {
    manualCoordinates.toggle();
    if (manualCoordinates.value) {
      // Seed the fields so the admin edits real numbers instead of blanks.
      final p = position.value;
      if (p != null) {
        latC.text = p.latitude.toStringAsFixed(6);
        lngC.text = p.longitude.toStringAsFixed(6);
      }
    }
  }

  /// Parses the manual lat/lng fields into [position]. Returns false when invalid.
  bool applyManualCoordinates() {
    final lat = double.tryParse(latC.text.trim());
    final lng = double.tryParse(lngC.text.trim());
    if (lat == null || lng == null) {
      showError('Enter valid numeric latitude and longitude.');
      return false;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      showError('Latitude must be -90 to 90 and longitude -180 to 180.');
      return false;
    }
    setPosition(LatLng(lat, lng), syncFields: false);
    return true;
  }

  Future<void> save() async {
    if (manualCoordinates.value && !applyManualCoordinates()) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final pin = position.value;
    if (pin == null) {
      showError('Set the market location on the map.');
      return;
    }

    isSaving.value = true;
    try {
      final data = <String, dynamic>{
        'marketName': nameC.text.trim(),
        'address': addressC.text.trim(),
        'operatingHours': hoursC.text.trim(),
        'isActive': isActive.value,
        'lat': pin.latitude,
        'lng': pin.longitude,
        'gpsCoordinates': GeoPoint(pin.latitude, pin.longitude),
      };
      if (isEdit) {
        await repo.updateMarket(editing!.id, data);
      } else {
        await repo.addMarket(data);
      }
      // The list behind this screen is already registered, so refresh in place.
      if (Get.isRegistered<MarketsController>()) {
        await Get.find<MarketsController>().load();
      }
      showSuccess(isEdit ? 'Market updated' : 'Market added');
      Get.back();
    } catch (e) {
      showError('Could not save market: ${errorText(e)}');
    } finally {
      isSaving.value = false;
    }
  }
}
