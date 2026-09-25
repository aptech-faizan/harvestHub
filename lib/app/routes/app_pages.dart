import 'package:get/get.dart';
import 'package:harvest_hub/app/middleware/admin_middleware.dart';
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
import 'package:harvest_hub/app/modules/admin/markets/bindings/markets_binding.dart';
import 'package:harvest_hub/app/modules/admin/markets/views/markets_view.dart';
import 'package:harvest_hub/app/modules/admin/orders/bindings/orders_binding.dart';
import 'package:harvest_hub/app/modules/admin/orders/views/order_details_view.dart';
import 'package:harvest_hub/app/modules/admin/orders/views/orders_view.dart';
import 'package:harvest_hub/app/modules/admin/products/bindings/products_binding.dart';
import 'package:harvest_hub/app/modules/admin/products/views/product_details_view.dart';
import 'package:harvest_hub/app/modules/admin/products/views/products_view.dart';
import 'package:harvest_hub/app/modules/admin/reports/bindings/reports_binding.dart';
import 'package:harvest_hub/app/modules/admin/reports/views/reports_view.dart';
import 'package:harvest_hub/app/modules/auth/bindings/admin_login_binding.dart';
import 'package:harvest_hub/app/modules/auth/views/admin_login_view.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';


class AppPages {
  // Every admin page (except login) is protected by AdminMiddleware.
  static final pages = <GetPage>[
    GetPage(
      name: Routes.adminLogin,
      page: () => const AdminLoginView(),
      binding: AdminLoginBinding(),
    ),
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
