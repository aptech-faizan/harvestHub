import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/widgets/edit_dialog.dart';
import 'package:harvest_hub/app/modules/admin/models/market_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';

class MarketsController extends GetxController {
  final repo = AdminRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final search = ''.obs;
  final markets = <MarketModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  List<MarketModel> get filtered {
    final q = search.value.trim().toLowerCase();
    if (q.isEmpty) return markets.toList();
    return markets
        .where((m) => m.marketName.toLowerCase().contains(q) || m.address.toLowerCase().contains(q))
        .toList();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      markets.assignAll(await repo.getMarkets());
    } catch (e) {
      error.value = 'Could not load markets: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  // Add when [m] is null, edit otherwise.
  Future<void> save([MarketModel? m]) async {
    final r = await showEditDialog(m == null ? 'Add market' : 'Edit market', [
      FieldDef('marketName', 'Market name', initial: m?.marketName ?? ''),
      FieldDef('address', 'Address', initial: m?.address ?? '', lines: 2),
      FieldDef('latitude', 'Latitude', initial: m == null ? '' : '${m.latitude}', numeric: true),
      FieldDef('longitude', 'Longitude', initial: m == null ? '' : '${m.longitude}', numeric: true),
      FieldDef('operatingHours', 'Operating hours (e.g. 8am - 6pm)',
          initial: m?.operatingHours ?? ''),
    ]);
    if (r == null) return;

    final lat = double.parse(r['latitude']!);
    final lng = double.parse(r['longitude']!);
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      showError('Latitude must be -90 to 90 and longitude -180 to 180');
      return;
    }
    final data = <String, dynamic>{
      'marketName': r['marketName'],
      'address': r['address'],
      'latitude': lat,
      'longitude': lng,
      'operatingHours': r['operatingHours'],
    };
    try {
      if (m == null) {
        await repo.addMarket({...data, 'activeStatus': true});
      } else {
        await repo.updateMarket(m.id, data);
      }
      showSuccess(m == null ? 'Market added' : 'Market updated');
      await load();
    } catch (e) {
      showError('Could not save market: ${errorText(e)}');
    }
  }

  Future<void> setActive(MarketModel m, bool value) async {
    try {
      await repo.updateMarket(m.id, {'activeStatus': value});
      await load();
    } catch (e) {
      showError('Could not change status: ${errorText(e)}');
    }
  }

  Future<void> delete(MarketModel m) async {
    final ok = await confirmDialog('Delete market', 'Delete "${m.marketName}"?');
    if (!ok) return;
    try {
      await repo.deleteMarket(m.id);
      markets.removeWhere((x) => x.id == m.id);
      showSuccess('Market deleted');
    } catch (e) {
      showError(errorText(e));
    }
  }
}
