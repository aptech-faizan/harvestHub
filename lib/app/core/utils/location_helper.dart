import 'package:geolocator/geolocator.dart';

/// Device GPS access shared by every module that needs a position
/// (admin market pin, customer distance filter).
class LocationHelper {
  // Location permission check karke current position return karta hai (null on fail)
  static Future<Position?> getCurrentPosition() async {
    // Service on hai ya nahi check karo
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // Permission status check karo
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    // Position fetch karo
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  /// Straight line distance in kilometres, or null when either point is unset.
  static double? distanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    if (toLat == 0.0 && toLng == 0.0) return null;
    final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
    return meters / 1000;
  }
}
