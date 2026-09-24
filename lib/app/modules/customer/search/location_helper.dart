import 'package:geolocator/geolocator.dart';

// Ye device ki current GPS position safely fetch karne ka helper hai
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
}
