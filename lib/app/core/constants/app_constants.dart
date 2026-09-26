// Firestore collection names
class Db {
  static const users = 'users';
  static const farmers = 'farmers';
  static const products = 'products';
  static const orders = 'orders';
  static const markets = 'markets';
  static const categories = 'categories';
  static const pickupSlots = 'pickup_slots';
}

/// Unsigned Cloudinary upload for product images.
/// Override at build time with --dart-define=CLOUDINARY_CLOUD_NAME=... and
/// --dart-define=CLOUDINARY_UPLOAD_PRESET=...
/// OpenStreetMap raster tiles. No API key, no billing, no quotas.
///
/// The standard OSM tile server is fine for development and demos but its usage
/// policy forbids heavy/commercial traffic. To move to a hosted provider later
/// (or your own tile server) change only [urlTemplate] here -- every map in the
/// app reads it from this one place.
class MapTiles {
  static const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// OSM requires a real identifying User-Agent so their tile servers can
  /// contact you. Keep this in sync with `applicationId` in
  /// android/app/build.gradle.kts.
  static const userAgentPackageName = 'com.example.harvest_hub';

  /// Attribution is mandatory when using OSM tiles. Keep it visible in the UI.
  static const attribution = '© OpenStreetMap contributors';

  /// Highest zoom the tile server actually has imagery for. Requests beyond
  /// this get upscaled, so flutter_map stops asking there.
  static const maxNativeZoom = 19;
}

/// Default camera target before an admin has placed a market pin
/// (Gujranwala, Punjab). Keeps every map in the app's service area.
class MapsDefaults {
  static const lat = 32.1877;
  static const lng = 74.1945;
  static const zoom = 13.0;
}

class CloudinaryConfig {
  static const cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'wxodse28',
  );
  static const uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'harvest_hub_preset',
  );
}

// Roles are stored in lowercase in users/{uid}.role
class Roles {
  static const admin = 'admin';
  static const customer = 'customer';
  static const farmer = 'farmer';
}

class OrderStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const ready = 'ready_for_pickup';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const all = [pending, confirmed, ready, completed, cancelled];
}
