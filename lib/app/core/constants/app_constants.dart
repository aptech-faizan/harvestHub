// Firestore collection names
class Db {
  static const users = 'users';
  static const farmers = 'farmers';
  static const products = 'products';
  static const orders = 'orders';
  static const markets = 'markets';
  static const categories = 'categories';
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
