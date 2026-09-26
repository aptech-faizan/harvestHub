abstract class Routes {
  // Splash & Common Authentication
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const adminLogin = '/login'; // Backward compatibility alias

  // Customer Module
  static const customerShell = '/customer/shell';
  static const customerCheckout = '/customer/checkout';
  static const customerFarmers = '/customer/farmers';
  static const customerFarmerDetails = '/customer/farmers/details';
  static const customerProductDetails = '/customer/products/details';
  static const customerWishlist = '/customer/wishlist';

  // Farmer Module
  static const farmerDashboard = '/farmer/dashboard';
  static const farmerProfile = '/farmer/profile';
  static const farmerProducts = '/farmer/products';
  static const farmerProductForm = '/farmer/products/form';
  static const farmerInventory = '/farmer/inventory';
  static const farmerSlots = '/farmer/slots';
  static const farmerOrders = '/farmer/orders';
  static const farmerOrderDetails = '/farmer/orders/details';
  static const farmerReports = '/farmer/reports';

  // Admin Module
  static const adminDashboard = '/admin/dashboard';
  static const customers = '/admin/customers';
  static const customerDetails = '/admin/customers/details';
  static const farmers = '/admin/farmers';
  static const farmerDetails = '/admin/farmers/details';
  static const categories = '/admin/categories';
  static const markets = '/admin/markets';
  static const marketForm = '/admin/markets/form';
  static const products = '/admin/products';
  static const productDetails = '/admin/products/details';
  static const orders = '/admin/orders';
  static const orderDetails = '/admin/orders/details';
  static const reports = '/admin/reports';
}
