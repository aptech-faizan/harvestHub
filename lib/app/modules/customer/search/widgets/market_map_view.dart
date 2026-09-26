import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/data/models/market_model.dart';
import 'package:latlong2/latlong.dart';

/// Read-only OpenStreetMap view of the active farmers markets.
///
/// Markets without coordinates are left out on purpose -- plotting them would
/// stack every one of them on Null Island (0, 0) in the Gulf of Guinea.
class MarketMapView extends StatefulWidget {
  final List<MarketModel> markets;
  final void Function(MarketModel market) onMarkerTap;

  const MarketMapView({
    super.key,
    required this.markets,
    required this.onMarkerTap,
  });

  @override
  State<MarketMapView> createState() => _MarketMapViewState();
}

class _MarketMapViewState extends State<MarketMapView> {
  final MapController _map = MapController();

  /// Markets that have real coordinates, in map order.
  List<MarketModel> get _located =>
      widget.markets.where((m) => m.hasCoordinates).toList();

  @override
  void initState() {
    super.initState();
    // The camera only exists once the map has been laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fitCamera();
    });
  }

  @override
  void didUpdateWidget(covariant MarketMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refit only when the set of plotted markets changes, not on every rebuild
    // (the distance filter rebuilds this on each user position tick).
    final before = oldWidget.markets.map((m) => m.id).toSet();
    final after = widget.markets.map((m) => m.id).toSet();
    if (before.length != after.length || !before.containsAll(after)) {
      _fitCamera();
    }
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _fitCamera() {
    final located = _located;
    if (located.isEmpty) return;
    if (located.length == 1) {
      _map.move(_pointOf(located.first), MapsDefaults.zoom + 1);
      return;
    }
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: located.map(_pointOf).toList(),
        padding: const EdgeInsets.all(48),
        maxZoom: 15,
      ),
    );
  }

  LatLng _pointOf(MarketModel m) => LatLng(m.lat, m.lng);

  Widget _marker(MarketModel m) {
    return GestureDetector(
      onTap: () => widget.onMarkerTap(m),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightPrimary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: const Icon(Icons.store, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final located = _located;

    if (located.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.markets.isEmpty
                ? 'No active markets to show.'
                : 'No active markets have a location set yet.\nAsk an admin to add coordinates.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: _pointOf(located.first),
        initialZoom: MapsDefaults.zoom,
        minZoom: 3,
        maxZoom: MapTiles.maxNativeZoom.toDouble(),
      ),
      children: [
        TileLayer(
          urlTemplate: MapTiles.urlTemplate,
          userAgentPackageName: MapTiles.userAgentPackageName,
          maxNativeZoom: MapTiles.maxNativeZoom,
        ),
        MarkerLayer(
          markers: [
            for (final m in located)
              Marker(
                point: _pointOf(m),
                width: 44,
                height: 44,
                child: _marker(m),
              ),
          ],
        ),
        RichAttributionWidget(
          attributions: [TextSourceAttribution(MapTiles.attribution)],
        ),
      ],
    );
  }
}
