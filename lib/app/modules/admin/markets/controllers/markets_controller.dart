import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/modules/admin/models/market_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class MarketsController extends GetxController {
  final repo = AdminRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final search = ''.obs;
  final markets = <MarketModel>[].obs;
  final slotCounts = <String, int>{}.obs;

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

  int getSlotCount(String marketId) => slotCounts[marketId] ?? 0;

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      markets.assignAll(await repo.getMarkets());
      try {
        final farmers = await repo.getFarmers();
        final farmerToMarket = {for (final f in farmers) f.id: f.marketId};
        final slotsSnap = await FirebaseFirestore.instance.collection(Db.pickupSlots).get();
        final counts = <String, int>{};
        for (final doc in slotsSnap.docs) {
          final fid = (doc.data()['farmerId'] ?? '').toString();
          final mid = farmerToMarket[fid];
          if (mid != null && mid.isNotEmpty) {
            counts[mid] = (counts[mid] ?? 0) + 1;
          }
        }
        slotCounts.assignAll(counts);
      } catch (_) {}
    } catch (e) {
      error.value = 'Could not load markets: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  // Opens the dedicated add/edit form. Pass [m] to edit, omit to add.
  void openForm([MarketModel? m]) {
    Get.toNamed(Routes.marketForm, arguments: m);
  }

  // Toggles the active status of a market
  Future<void> setActive(MarketModel m, bool value) async {
    try {
      await repo.updateMarket(m.id, {'isActive': value});
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
