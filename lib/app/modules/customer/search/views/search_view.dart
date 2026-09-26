import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/product_search_controller.dart';

// Search & Filter screen
// Layout:
//   1. Search bar (debounced 300ms, auto-filter on keystroke)
//   2. Category chips row (horizontal scroll) — home screen pattern
//   3. Market & Farmer dropdowns row
//   4. Active filter count badge + "Clear Filters" button
//   5. Product results list with thumbnail image
//   6. Friendly empty state when 0 results
class SearchView extends GetView<ProductSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _SearchBar(controller: controller),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Category chips (same pattern as Home screen) ──────────────────
          _CategoryChipsRow(controller: controller),
          const Divider(height: 1),

          // ── Market & Farmer dropdowns ─────────────────────────────────────
          _DropdownFiltersRow(controller: controller, theme: theme),
          const Divider(height: 1),

          // ── Active filter count + Clear button ────────────────────────────
          _FilterStatusBar(controller: controller, theme: theme),

          // ── Results list ──────────────────────────────────────────────────
          Expanded(child: _ResultsList(controller: controller)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar widget
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller});
  final ProductSearchController controller;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.controller.query.value);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Agar clearFilters() call ho to text field bhi reset ho
      final ctrlVal = widget.controller.query.value;
      if (_textCtrl.text != ctrlVal && ctrlVal.isEmpty) {
        _textCtrl.clear();
      }
      return TextField(
        controller: _textCtrl,
        decoration: InputDecoration(
          hintText: 'Product name se search karo...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ctrlVal.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _textCtrl.clear();
                    widget.controller.query.value = '';
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true,
        ),
        onChanged: (val) => widget.controller.query.value = val,
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category chips — same horizontal-scroll pattern as Home screen
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryChipsRow extends StatelessWidget {
  const _CategoryChipsRow({required this.controller});
  final ProductSearchController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: [
              // "All" chip
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: controller.selectedCategoryId.value.isEmpty,
                  onSelected: (_) {
                    controller.selectedCategoryId.value = '';
                    controller.applyFilters();
                  },
                ),
              ),
              // Dynamic category chips
              ...controller.categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: controller.selectedCategoryId.value == cat.id,
                      onSelected: (_) {
                        controller.selectedCategoryId.value = cat.id;
                        controller.applyFilters();
                      },
                    ),
                  )),
            ],
          )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Market & Farmer dropdown row
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownFiltersRow extends StatelessWidget {
  const _DropdownFiltersRow({required this.controller, required this.theme});
  final ProductSearchController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Obx(() => Row(
            children: [
              // Market dropdown
              Expanded(
                child: _StyledDropdown<String>(
                  hint: 'Market',
                  icon: Icons.store_outlined,
                  value: controller.selectedMarketId.value.isEmpty
                      ? null
                      : controller.selectedMarketId.value,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Markets')),
                    ...controller.markets.map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.marketName, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (val) {
                    controller.selectedMarketId.value = val ?? '';
                    controller.applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Farmer dropdown
              Expanded(
                child: _StyledDropdown<String>(
                  hint: 'Farmer',
                  icon: Icons.agriculture_outlined,
                  value: controller.selectedFarmerId.value.isEmpty
                      ? null
                      : controller.selectedFarmerId.value,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Farmers')),
                    ...controller.farmers.map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(f.name, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (val) {
                    controller.selectedFarmerId.value = val ?? '';
                    controller.applyFilters();
                  },
                ),
              ),
            ],
          )),
    );
  }
}

// Reusable styled dropdown wrapper
class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      ),
      isExpanded: true,
      items: items,
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter status bar — active count + Clear Filters
// ─────────────────────────────────────────────────────────────────────────────
class _FilterStatusBar extends StatelessWidget {
  const _FilterStatusBar({required this.controller, required this.theme});
  final ProductSearchController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.activeFilterCount;
      final hasQuery = controller.query.value.isNotEmpty;
      final hasAny = count > 0 || hasQuery;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: hasAny ? 36 : 0,
        child: hasAny
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _filterLabel(count, hasQuery),
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear Filters'),
                      onPressed: controller.clearFilters,
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }

  String _filterLabel(int count, bool hasQuery) {
    final parts = <String>[];
    if (hasQuery) parts.add('search');
    if (count > 0) parts.add('$count filter${count > 1 ? 's' : ''}');
    return '${parts.join(' + ')} active';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results list
// ─────────────────────────────────────────────────────────────────────────────
class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.controller});
  final ProductSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final products = controller.results;

      if (products.isEmpty) {
        return _EmptyState(
          hasFilters: controller.activeFilterCount > 0 ||
              controller.query.value.isNotEmpty,
          onClear: controller.clearFilters,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          final isOutOfStock = p.stockQty <= 0;

          // Product thumbnail — URL ho to load karo, warna placeholder
          final Widget thumbnail = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: p.imageUrl.isEmpty
                ? Container(
                    width: 56,
                    height: 56,
                    color: Colors.green.shade50,
                    child: const Icon(Icons.eco_outlined, size: 30, color: Colors.green),
                  )
                : Image.network(
                    p.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.green.shade50,
                      child: const Icon(Icons.broken_image_outlined,
                          size: 30, color: Colors.grey),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade100,
                            child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                  ),
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: ListTile(
              leading: thumbnail,
              onTap: () =>
                  Get.toNamed(Routes.customerProductDetails, arguments: p),
              title: Text(p.itemName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p.farmerName}  ·  ${p.marketName}',
                      style: const TextStyle(fontSize: 12)),
                  Text('Rs. ${p.pricePerUnit} / ${p.unit}'),
                  Text(
                    isOutOfStock ? 'Out of stock' : 'Stock: ${p.stockQty}',
                    style: TextStyle(
                        color: isOutOfStock ? Colors.red : Colors.green,
                        fontSize: 12),
                  ),
                ],
              ),
              trailing: SizedBox(
                height: 36,
                width: 105,
                child: ElevatedButton(
                  onPressed:
                      isOutOfStock ? null : () => controller.addToCart(p),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(fontSize: 13)),
                  child: const Text('Add to cart'),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters, required this.onClear});
  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Koi product nahi mila',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Applied filters ke sath koi match nahi hua.\nFilters clear karke dobara try karo.'
                  : 'Kuch aur search karo ya filters change karo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
