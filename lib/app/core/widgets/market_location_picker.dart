import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/core/utils/location_helper.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap picker that captures a market's exact coordinates.
///
/// The pin sits in the centre of the map, so the admin sets the location by
/// *dragging the map* under it (or tapping anywhere to jump the pin there).
/// This is the same interaction the Google/OSM pickers use, and unlike a
/// draggable overlay it hands movement to the map's own gesture layer -- no
/// manual coordinate maths and no dropped frames.
///
/// [onPositionChanged] fires on every user gesture, not on programmatic camera
/// moves, so the caller never gets a feedback loop when it moves the map.
class MarketLocationPicker extends StatefulWidget {
  /// Current pin, or null when the market has no location yet.
  final LatLng? position;

  final ValueChanged<LatLng> onPositionChanged;

  /// Zoom used on first build. Ignored once the admin starts moving the map.
  final double zoom;

  final bool showLocateButton;
  final double height;

  const MarketLocationPicker({
    super.key,
    required this.position,
    required this.onPositionChanged,
    this.zoom = MapsDefaults.zoom,
    this.showLocateButton = true,
    this.height = 320,
  });

  @override
  State<MarketLocationPicker> createState() => _MarketLocationPickerState();
}

class _MarketLocationPickerState extends State<MarketLocationPicker> {
  final MapController _map = MapController();

  late LatLng _pin = _initialPin;
  bool _locating = false;

  LatLng get _initialPin =>
      widget.position ?? const LatLng(MapsDefaults.lat, MapsDefaults.lng);

  bool get _isPinned => widget.position != null;

  void _publish(LatLng p) => widget.onPositionChanged(p);

  /// Moves the camera and the pin together, e.g. from "use my location".
  void _setPin(LatLng p) {
    setState(() => _pin = p);
    _map.move(p, _map.camera.zoom);
    _publish(p);
  }

  /// Keeps the pin in sync when the parent changes the position from outside
  /// the map, e.g. the admin typed coordinates in manual mode and switched back.
  @override
  void didUpdateWidget(covariant MarketLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.position;
    if (incoming == null || incoming == _pin) return;
    setState(() => _pin = incoming);
    _map.move(incoming, _map.camera.zoom);
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    final pos = await LocationHelper.getCurrentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (pos == null) {
      showError('Could not read your location. Move the pin on the map instead.');
      return;
    }
    _setPin(LatLng(pos.latitude, pos.longitude));
  }

  Widget _pinWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: const Icon(Icons.store, color: Colors.white, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _pin,
                    initialZoom: widget.zoom,
                    minZoom: 3,
                    maxZoom: MapTiles.maxNativeZoom.toDouble(),
                    // Tap jumps the pin to that point.
                    onTap: (_, point) => _setPin(point),
                    // Dragging the map moves the pin with the centre.
                    // hasGesture guards against reacting to our own _setPin moves.
                    onPositionChanged: (mapPosition, hasGesture) {
                      if (!hasGesture) return;
                      final target = mapPosition.center;
                      if (target == _pin) return;
                      setState(() => _pin = target);
                      _publish(target);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapTiles.urlTemplate,
                      userAgentPackageName: MapTiles.userAgentPackageName,
                      maxNativeZoom: MapTiles.maxNativeZoom,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _pin,
                          width: 48,
                          height: 48,
                          child: _pinWidget(),
                        ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [TextSourceAttribution(MapTiles.attribution)],
                    ),
                  ],
                ),
                if (widget.showLocateButton)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'market_location_picker',
                      backgroundColor: AppColors.lightSurface,
                      foregroundColor: AppColors.lightPrimary,
                      onPressed: _locating ? null : _useMyLocation,
                      tooltip: 'Use my current location',
                      child: _locating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                    ),
                  ),
                if (!_isPinned)
                  Positioned(
                    left: 12,
                    right: 60,
                    top: 12,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.lightAccentGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Drag the map or tap to set the location',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isPinned
              ? 'Location: ${_pin.latitude.toStringAsFixed(6)}, ${_pin.longitude.toStringAsFixed(6)}'
              : 'No location set yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
