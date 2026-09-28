import 'package:get/get.dart';
import 'package:harvest_hub/app/middleware/admin_middleware.dart';
import 'package:harvest_hub/app/middleware/auth_middleware.dart';
import 'package:harvest_hub/app/middleware/customer_middleware.dart';
import 'package:harvest_hub/app/middleware/farmer_middleware.dart';
import 'package:harvest_hub/app/middleware/guest_middleware.dart';
import 'package:harvest_hub/app/modules/admin/categories/bindings/categories_binding.dart';
import 'package:harvest_hub/app/modules/admin/categories/views/categories_view.dart';
import 'package:harvest_hub/app/modules/admin/customers/bindings/customers_binding.dart';
import 'package:harvest_hub/app/modules/admin/customers/views/customer_details_view.dart';
import 'package:harvest_hub/app/modules/admin/customers/views/customers_view.dart';
import 'package:harvest_hub/app/modules/admin/dashboard/bindings/dashboard_binding.dart';
import 'package:harvest_hub/app/modules/admin/dashboard/views/dashboard_view.dart';
import 'package:harvest_hub/app/modules/admin/farmers/bindings/farmers_binding.dart';
import 'package:harvest_hub/app/modules/admin/farmers/views/farmer_details_view.dart';
import 'package:harvest_hub/app/modules/admin/farmers/views/farmers_view.dart';
import 'package:harvest_hub/app/modules/admin/markets/bindings/market_form_binding.dart';
import 'package:harvest_hub/app/modules/admin/markets/bindings/markets_binding.dart';
import 'package:harvest_hub/app/modules/admin/markets/views/market_form_view.dart';
import 'package:harvest_hub/app/modules/admin/markets/views/markets_view.dart';
import 'package:harvest_hub/app/modules/admin/orders/bindings/orders_binding.dart';
import 'package:harvest_hub/app/modules/admin/orders/views/order_details_view.dart';
import 'package:harvest_hub/app/modules/admin/orders/views/orders_view.dart';
import 'package:harvest_hub/app/modules/admin/products/bindings/products_binding.dart';
import 'package:harvest_hub/app/modules/admin/products/views/product_details_view.dart';
import 'package:harvest_hub/app/modules/admin/products/views/products_view.dart';
import 'package:harvest_hub/app/modules/admin/reports/bindings/reports_binding.dart';
import 'package:harvest_hub/app/modules/admin/reports/views/reports_view.dart';
import 'package:harvest_hub/app/modules/auth/bindings/login_binding.dart';
import 'package:harvest_hub/app/modules/auth/bindings/register_binding.dart';
import 'package:harvest_hub/app/modules/auth/views/login_view.dart';
import 'package:harvest_hub/app/modules/auth/views/register_view.dart';
import 'package:harvest_hub/app/modules/customer/assistant/bindings/assistant_binding.dart';
import 'package:harvest_hub/app/modules/customer/assistant/views/assistant_view.dart';
import 'package:harvest_hub/app/modules/customer/checkout/bindings/checkout_binding.dart';
import 'package:harvest_hub/app/modules/customer/checkout/views/checkout_view.dart';
import 'package:harvest_hub/app/modules/customer/checkout/views/order_success_view.dart';
import 'package:harvest_hub/app/modules/customer/farmers/bindings/farmers_binding.dart'
    as customer_farmers_bind;
import 'package:harvest_hub/app/modules/customer/farmers/views/farmer_details_view.dart'
    as customer_farmer_details;
import 'package:harvest_hub/app/modules/customer/farmers/views/farmers_view.dart'
    as customer_farmers;
import 'package:harvest_hub/app/modules/customer/product_details/bindings/product_details_binding.dart';
import 'package:harvest_hub/app/modules/customer/product_details/views/product_details_view.dart'
    as customer_product_details;
import 'package:harvest_hub/app/modules/customer/shell/bindings/customer_shell_binding.dart';
import 'package:harvest_hub/app/modules/customer/shell/views/customer_shell_view.dart';
import 'package:harvest_hub/app/modules/customer/wishlist/bindings/wishlist_binding.dart';
import 'package:harvest_hub/app/modules/customer/follow/views/followed_farmers_view.dart';
import 'package:harvest_hub/app/modules/customer/profile/bindings/profile_binding.dart';
import 'package:harvest_hub/app/modules/customer/profile/views/change_password_view.dart';
import 'package:harvest_hub/app/modules/customer/profile/views/personal_info_view.dart';
import 'package:harvest_hub/app/modules/shared/chat/bindings/chat_binding.dart';
import 'package:harvest_hub/app/modules/shared/chat/views/chat_inbox_view.dart';
import 'package:harvest_hub/app/modules/shared/chat/views/chat_room_view.dart';
import 'package:harvest_hub/app/modules/customer/wishlist/views/wishlist_view.dart';
import 'package:harvest_hub/app/modules/customer/about/bindings/about_binding.dart';
import 'package:harvest_hub/app/modules/customer/about/views/about_view.dart';
import 'package:harvest_hub/app/modules/customer/contact/bindings/contact_binding.dart';
import 'package:harvest_hub/app/modules/customer/contact/views/contact_view.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/bindings/farmer_dashboard_binding.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/views/farmer_dashboard_view.dart';
import 'package:harvest_hub/app/modules/farmer/inventory/bindings/farmer_inventory_binding.dart';
import 'package:harvest_hub/app/modules/farmer/inventory/views/farmer_inventory_view.dart';
import 'package:harvest_hub/app/modules/farmer/orders/bindings/farmer_orders_binding.dart';
import 'package:harvest_hub/app/modules/farmer/orders/views/farmer_order_details_view.dart';
import 'package:harvest_hub/app/modules/farmer/orders/views/farmer_orders_view.dart';
import 'package:harvest_hub/app/modules/farmer/pickup_slots/bindings/farmer_slots_binding.dart';
import 'package:harvest_hub/app/modules/farmer/pickup_slots/views/farmer_slots_view.dart';
import 'package:harvest_hub/app/modules/farmer/products/bindings/farmer_product_form_binding.dart';
import 'package:harvest_hub/app/modules/farmer/products/bindings/farmer_products_binding.dart';
import 'package:harvest_hub/app/modules/farmer/products/views/farmer_product_form_view.dart';
import 'package:harvest_hub/app/modules/farmer/products/views/farmer_products_view.dart';
import 'package:harvest_hub/app/modules/farmer/profile/bindings/farmer_profile_binding.dart';
import 'package:harvest_hub/app/modules/farmer/profile/views/farmer_profile_view.dart';
import 'package:harvest_hub/app/modules/farmer/profile/views/farmer_bio_view.dart';
import 'package:harvest_hub/app/modules/farmer/profile/views/farmer_address_view.dart';
import 'package:harvest_hub/app/modules/farmer/profile/views/farmer_contact_view.dart';
import 'package:harvest_hub/app/modules/farmer/profile/views/farmer_change_password_view.dart';
import 'package:harvest_hub/app/modules/farmer/reports/bindings/farmer_reports_binding.dart';
import 'package:harvest_hub/app/modules/farmer/reports/views/farmer_reports_view.dart';
import 'package:harvest_hub/app/modules/splash/bindings/splash_binding.dart';
import 'package:harvest_hub/app/modules/splash/views/splash_view.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final pages = <GetPage>[
    // ----- Splash -----
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // ----- Common Auth -----
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      middlewares: [GuestMiddleware()],
    ),

    // ----- Customer Module -----
    GetPage(
      name: Routes.customerShell,
      page: () => const CustomerShellView(),
      binding: CustomerShellBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.customerCheckout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.orderSuccess,
      page: () => const OrderSuccessView(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.customerFarmers,
      page: () => const customer_farmers.FarmersView(),
      binding: customer_farmers_bind.FarmersBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.customerFarmerDetails,
      page: () => const customer_farmer_details.FarmerDetailsView(),
      binding: customer_farmers_bind.FarmersBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.customerProductDetails,
      page: () => const customer_product_details.ProductDetailsView(),
      binding: ProductDetailsBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.customerWishlist,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.customerFollowedFarmers,
      page: () => const FollowedFarmersView(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.customerPersonalInfo,
      page: () => const PersonalInfoView(),
      binding: ProfileBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.customerChangePassword,
      page: () => const ChangePasswordView(),
      binding: ProfileBinding(),
      middlewares: [CustomerMiddleware()],
    ),

    // ----- Shared Module (customer + farmer) -----
    GetPage(
      name: Routes.chatInbox,
      page: () => const ChatInboxView(),
      binding: ChatBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.chatRoom,
      page: () => const ChatRoomView(),
      binding: ChatBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.assistantScreen,
      page: () => const AssistantView(),
      binding: AssistantBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.aboutUs,
      page: () => const AboutView(),
      binding: AboutBinding(),
      middlewares: [CustomerMiddleware()],
    ),
    GetPage(
      name: Routes.contactUs,
      page: () => const ContactView(),
      binding: ContactBinding(),
      middlewares: [CustomerMiddleware()],
    ),

    // ----- Farmer Module -----
    GetPage(
      name: Routes.farmerDashboard,
      page: () => const FarmerDashboardView(),
      binding: FarmerDashboardBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerProfile,
      page: () => const FarmerProfileView(),
      binding: FarmerProfileBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerBio,
      page: () => const FarmerBioView(),
      binding: FarmerProfileBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerAddress,
      page: () => const FarmerAddressView(),
      binding: FarmerProfileBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerContact,
      page: () => const FarmerContactView(),
      binding: FarmerProfileBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerChangePassword,
      page: () => const FarmerChangePasswordView(),
      binding: FarmerProfileBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerProducts,
      page: () => const FarmerProductsView(),
      binding: FarmerProductsBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerProductForm,
      page: () => const FarmerProductFormView(),
      binding: FarmerProductFormBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerInventory,
      page: () => const FarmerInventoryView(),
      binding: FarmerInventoryBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerSlots,
      page: () => const FarmerSlotsView(),
      binding: FarmerSlotsBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerOrders,
      page: () => const FarmerOrdersView(),
      binding: FarmerOrdersBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerOrderDetails,
      page: () => const FarmerOrderDetailsView(),
      binding: FarmerOrdersBinding(),
      middlewares: [FarmerMiddleware()],
    ),
    GetPage(
      name: Routes.farmerReports,
      page: () => const FarmerReportsView(),
      binding: FarmerReportsBinding(),
      middlewares: [FarmerMiddleware()],
    ),

    // ----- Admin Module -----
    GetPage(
      name: Routes.adminDashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.customers,
      page: () => const CustomersView(),
      binding: CustomersBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.customerDetails,
      page: () => const CustomerDetailsView(),
      binding: CustomersBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.farmers,
      page: () => const FarmersView(),
      binding: FarmersBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.farmerDetails,
      page: () => const FarmerDetailsView(),
      binding: FarmersBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.markets,
      page: () => const MarketsView(),
      binding: MarketsBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.marketForm,
      page: () => const MarketFormView(),
      binding: MarketFormBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.products,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.productDetails,
      page: () => const ProductDetailsView(),
      binding: ProductsBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.orders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => const OrderDetailsView(),
      binding: OrdersBinding(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: Routes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      middlewares: [AdminMiddleware()],
    ),
  ];
}
