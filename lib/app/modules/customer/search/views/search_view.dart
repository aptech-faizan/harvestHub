import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/data/models/market_model.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/product_search_controller.dart';
import '../widgets/market_map_view.dart';

// Search + filters screen with a List / Map toggle for the results.
class SearchView extends GetView<ProductSearchController> {
  const SearchView({super.key});

  /// Marker tap -> market summary sheet with a jump-to-products action.
  void _openMarketSheet(BuildContext context, MarketModel market) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                market.marketName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (market.address.isNotEmpty)
                _row(Icons.location_on_outlined, market.address),
              if (market.operatingHours.isNotEmpty)
                _row(Icons.schedule, market.operatingHours),
              Obx(() {
                final label = controller.distanceLabelToMarket(market);
                if (label.isEmpty) return const SizedBox.shrink();
                return _row(Icons.near_me, label);
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    controller.filterByMarket(market);
                  },
                  child: const Text('View Products'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),
      body: Column(
        children: [
          // List / Map toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SizedBox(
              width: double.infinity,
              child: Obx(() => SegmentedButton<SearchViewMode>(
                    segments: const [
                      ButtonSegment<SearchViewMode>(
                        value: SearchViewMode.list,
                        label: Text('List'),
                        icon: Icon(Icons.view_list),
                      ),
                      ButtonSegment<SearchViewMode>(
                        value: SearchViewMode.map,
                        label: Text('Map'),
                        icon: Icon(Icons.map_outlined),
                      ),
                    ],
                    selected: {controller.viewMode.value},
                    onSelectionChanged: (s) {
                      if (s.isNotEmpty) controller.setViewMode(s.first);
                    },
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                // Product name search field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Product',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => controller.query.value = val,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Category dropdown
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedCategoryId.value,
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Categories')),
                          ...controller.categories.map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                          ),
                        ],
                        onChanged: (val) {
                          controller.selectedCategoryId.value = val ?? '';
                          controller.applyFilters();
                        },
                      )),
                    ),
                    const SizedBox(width: 8),
                    // Market dropdown
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedMarketId.value,
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Markets')),
                          ...controller.markets.map((m) =>
                            DropdownMenuItem(value: m.id, child: Text(m.marketName)),
                          ),
                        ],
                        onChanged: (val) {
                          controller.selectedMarketId.value = val ?? '';
                          controller.applyFilters();
                        },
                      )),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Farmer name search field
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Farmer Name'),
                        onChanged: (val) => controller.farmerQuery.value = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Distance dropdown
                    Obx(() => DropdownButton<double>(
                      value: controller.maxDistanceKm.value,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Any dist')),
                        DropdownMenuItem(value: 2, child: Text('2 km')),
                        DropdownMenuItem(value: 5, child: Text('5 km')),
                        DropdownMenuItem(value: 10, child: Text('10 km')),
                        DropdownMenuItem(value: 25, child: Text('25 km')),
                      ],
                      onChanged: (val) => controller.selectDistance(val ?? 0),
                    )),
                    TextButton(
                      onPressed: controller.clearFilters,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.viewMode.value == SearchViewMode.map) {
                return MarketMapView(
                  markets: controller.visibleMarkets,
                  onMarkerTap: (m) => _openMarketSheet(context, m),
                );
              }
              if (controller.results.isEmpty) {
                return const Center(child: Text('No products found'));
              }
              return ListView.builder(
                itemCount: controller.results.length,
                itemBuilder: (context, index) {
                  final p = controller.results[index];
                  final isOutOfStock = p.stockQty <= 0;
                  final distLabel = controller.distanceKmOf(p);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      onTap: () => Get.toNamed(
                        Routes.customerProductDetails,
                        arguments: p,
                      ),
                      title: Text(p.itemName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Farmer: ${p.farmerName} | Market: ${p.marketName}'),
                          Text('Price: Rs. ${p.pricePerUnit} / ${p.unit}'),
                          Text(
                            isOutOfStock ? 'Out of stock' : 'Stock: ${p.stockQty}',
                            style: TextStyle(color: isOutOfStock ? Colors.red : Colors.green),
                          ),
                          if (distLabel.isNotEmpty)
                            Text(distLabel, style: const TextStyle(color: Colors.blueGrey)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: isOutOfStock ? null : () => controller.addToCart(p),
                        child: const Text('Add to cart'),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
