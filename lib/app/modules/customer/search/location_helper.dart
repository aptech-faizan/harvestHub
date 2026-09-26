// location_helper.dart — STUB
//
// NOTE (Scope Limitation): GPS-based Location/Distance filter is excluded from
// the current release scope. This file is retained as a stub so the dependency
// graph stays intact and the feature can be wired in a future sprint.
//
// To re-enable: add `geolocator` back to active imports, implement
// getCurrentPosition() using the Geolocator package, and wire selectDistance()
// back into ProductSearchController.

// Ye file abhi sirf placeholder hai — geolocator dependency hata di gayi hai.
class LocationHelper {
  // Future sprint mein GPS distance filter yahan implement hoga.
  // Abhi sirf null return karta hai.
  static Future<Object?> getCurrentPosition() async => null;
}
