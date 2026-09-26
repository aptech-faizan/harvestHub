import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/middleware/admin_middleware.dart';
import 'package:harvest_hub/app/middleware/customer_middleware.dart';
import 'package:harvest_hub/app/middleware/farmer_middleware.dart';
import 'package:harvest_hub/app/middleware/guest_middleware.dart';
import 'package:harvest_hub/app/modules/auth/controllers/login_controller.dart';
import 'package:harvest_hub/app/modules/auth/controllers/register_controller.dart';
import 'package:harvest_hub/app/modules/auth/views/login_view.dart';
import 'package:harvest_hub/app/modules/auth/views/register_view.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/controllers/farmer_dashboard_controller.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/views/farmer_dashboard_view.dart';
import 'package:harvest_hub/app/routes/app_pages.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

/// Test implementation of AuthService that decouples Firebase for reliable unit testing
class MockAuthService extends AuthService {
  bool failNextLogin = false;
  String? nextLoginError;
  bool isDeactivatedUser = false;
  String mockRole = '';

  /// Call super to satisfy @mustCallSuper; the parent's try/catch silently
  /// swallows the Firebase-not-initialized error, leaving firebaseUser = null.
  @override
  void onInit() {
    super.onInit(); // safe: AuthService.onInit() wraps Firebase in try/catch
  }

  /// Return null — Firebase Auth is not initialized in tests
  @override
  User? get currentUser => null;

  @override
  bool get isAuthenticated => mockRole.isNotEmpty;

  @override
  bool get isCustomer => mockRole == Roles.customer;

  @override
  bool get isFarmer => mockRole == Roles.farmer;

  @override
  bool get isAdmin => mockRole == Roles.admin;

  @override
  Future<String> login(String email, String password) async {
    if (failNextLogin) {
      throw Exception(nextLoginError ?? 'Invalid credentials');
    }
    if (isDeactivatedUser) {
      throw Exception('This account has been deactivated or blocked.');
    }
    if (mockRole.isEmpty || (mockRole != Roles.customer && mockRole != Roles.farmer && mockRole != Roles.admin)) {
      throw Exception('Invalid or unrecognized user role.');
    }
    role.value = mockRole;
    return mockRole;
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String address,
    required String role,
    String marketId = '',
    String marketName = '',
  }) async {
    final normalized = role.trim().toLowerCase();
    if (normalized != Roles.customer && normalized != Roles.farmer) {
      throw Exception('Public registration is only allowed for Customer or Farmer.');
    }
    if (normalized == Roles.farmer && marketId.isEmpty) {
      throw Exception('Please select the market where you sell your produce.');
    }
    mockRole = normalized;
    this.role.value = normalized;
    return normalized;
  }

  @override
  Future<void> logout() async {
    mockRole = '';
    role.value = '';
    Get.offAllNamed(Routes.login);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuth;

  setUp(() {
    Get.reset();
    Get.testMode = true; // must be after reset() — reset() clears testMode
    mockAuth = MockAuthService();
    Get.put<AuthService>(mockAuth);
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 5 Flow Validation - Role & Navigation Architecture', () {
    test('1 & 2. Role Registration Flow: Customer & Farmer allowed, Admin forbidden', () async {
      // Customer registration
      final customerRole = await mockAuth.register(
        name: 'John Customer',
        email: 'customer@test.com',
        phone: '1234567890',
        password: 'password123',
        address: '123 Test St',
        role: Roles.customer,
      );
      expect(customerRole, equals(Roles.customer));
      expect(mockAuth.isCustomer, isTrue);
      expect(mockAuth.isFarmer, isFalse);
      expect(mockAuth.isAdmin, isFalse);

      // Farmer registration (a market is now mandatory for farmers)
      final farmerRole = await mockAuth.register(
        name: 'Jane Farmer',
        email: 'farmer@test.com',
        phone: '0987654321',
        password: 'password123',
        address: '456 Farm Rd',
        role: Roles.farmer,
        marketId: 'market_central',
        marketName: 'Central Mandi',
      );
      expect(farmerRole, equals(Roles.farmer));
      expect(mockAuth.isFarmer, isTrue);
      expect(mockAuth.isCustomer, isFalse);
      expect(mockAuth.isAdmin, isFalse);

      // A farmer without a market must be rejected
      expect(
        () => mockAuth.register(
          name: 'No Market Farmer',
          email: 'nomarket@test.com',
          phone: '0987654321',
          password: 'password123',
          address: '456 Farm Rd',
          role: Roles.farmer,
        ),
        throwsA(isA<Exception>()),
      );

      // Public Admin registration MUST be rejected
      expect(
        () => mockAuth.register(
          name: 'Hacker Admin',
          email: 'admin@hack.com',
          phone: '0000000000',
          password: 'password123',
          address: 'Admin HQ',
          role: Roles.admin,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('3. Role Login: Correct role resolution and routing determination', () async {
      // Customer login
      mockAuth.mockRole = Roles.customer;
      final role1 = await mockAuth.login('cust@test.com', 'pass123');
      expect(role1, equals(Roles.customer));
      expect(mockAuth.isCustomer, isTrue);

      // Farmer login
      mockAuth.mockRole = Roles.farmer;
      final role2 = await mockAuth.login('farm@test.com', 'pass123');
      expect(role2, equals(Roles.farmer));
      expect(mockAuth.isFarmer, isTrue);

      // Admin login (via same common login method)
      mockAuth.mockRole = Roles.admin;
      final role3 = await mockAuth.login('admin@test.com', 'pass123');
      expect(role3, equals(Roles.admin));
      expect(mockAuth.isAdmin, isTrue);
    });

    test('4. Logout properly resets authentication state', () async {
      mockAuth.mockRole = Roles.customer;
      mockAuth.role.value = Roles.customer;
      expect(mockAuth.isAuthenticated, isTrue);

      await mockAuth.logout();

      expect(mockAuth.isAuthenticated, isFalse);
      expect(mockAuth.role.value, isEmpty);
      expect(mockAuth.isCustomer, isFalse);
    });

    test('7. Invalid credentials handling', () async {
      mockAuth.failNextLogin = true;
      mockAuth.nextLoginError = 'Invalid email or password.';

      expect(
        () => mockAuth.login('wrong@test.com', 'wrongpass'),
        throwsA(predicate((e) => e.toString().contains('Invalid email or password.'))),
      );
    });

    test('8. Missing/invalid role & deactivated user handling', () async {
      // Missing / invalid role
      mockAuth.mockRole = 'unknown_role';
      expect(
        () => mockAuth.login('user@test.com', 'pass'),
        throwsA(predicate((e) => e.toString().contains('Invalid or unrecognized user role.'))),
      );

      // Deactivated user
      mockAuth.isDeactivatedUser = true;
      expect(
        () => mockAuth.login('user@test.com', 'pass'),
        throwsA(predicate((e) => e.toString().contains('deactivated'))),
      );
    });

    test('9. Role Middlewares: Prevent unauthorized cross-role access', () {
      final customerMiddleware = CustomerMiddleware();
      final farmerMiddleware = FarmerMiddleware();
      final adminMiddleware = AdminMiddleware();

      // Case A: Unauthenticated user trying to access any protected module
      mockAuth.mockRole = '';
      expect(customerMiddleware.redirect(Routes.customerShell)?.name, equals(Routes.login));
      expect(farmerMiddleware.redirect(Routes.farmerDashboard)?.name, equals(Routes.login));
      expect(adminMiddleware.redirect(Routes.adminDashboard)?.name, equals(Routes.login));

      // Case B: Customer trying to access Farmer or Admin modules
      mockAuth.mockRole = Roles.customer;
      expect(customerMiddleware.redirect(Routes.customerShell), isNull); // Allowed
      expect(farmerMiddleware.redirect(Routes.farmerDashboard)?.name, equals(Routes.login)); // Blocked
      expect(adminMiddleware.redirect(Routes.adminDashboard)?.name, equals(Routes.login)); // Blocked

      // Case C: Farmer trying to access Customer or Admin modules
      mockAuth.mockRole = Roles.farmer;
      expect(farmerMiddleware.redirect(Routes.farmerDashboard), isNull); // Allowed
      expect(customerMiddleware.redirect(Routes.customerShell)?.name, equals(Routes.login)); // Blocked
      expect(adminMiddleware.redirect(Routes.adminDashboard)?.name, equals(Routes.login)); // Blocked

      // Case D: Admin trying to access Farmer or Customer modules
      mockAuth.mockRole = Roles.admin;
      expect(adminMiddleware.redirect(Routes.adminDashboard), isNull); // Allowed
      expect(customerMiddleware.redirect(Routes.customerShell)?.name, equals(Routes.login)); // Blocked
      expect(farmerMiddleware.redirect(Routes.farmerDashboard)?.name, equals(Routes.login)); // Blocked
    });

    test('5 & 6. GuestMiddleware prevents already-authenticated users from seeing login again', () {
      final guestMiddleware = GuestMiddleware();

      // Unauthenticated user -> can see login
      mockAuth.mockRole = '';
      expect(guestMiddleware.redirect(Routes.login), isNull);

      // Authenticated Customer -> redirected to customer shell
      mockAuth.mockRole = Roles.customer;
      expect(guestMiddleware.redirect(Routes.login)?.name, equals(Routes.customerShell));

      // Authenticated Farmer -> redirected to farmer dashboard
      mockAuth.mockRole = Roles.farmer;
      expect(guestMiddleware.redirect(Routes.login)?.name, equals(Routes.farmerDashboard));

      // Authenticated Admin -> redirected to admin dashboard
      mockAuth.mockRole = Roles.admin;
      expect(guestMiddleware.redirect(Routes.login)?.name, equals(Routes.adminDashboard));
    });

    test('10. Routes definition completeness: Customer, Farmer, Admin and Auth routes', () {
      expect(Routes.login, equals('/login'));
      expect(Routes.register, equals('/register'));
      expect(Routes.splash, equals('/splash'));
      expect(Routes.customerShell, equals('/customer/shell'));
      expect(Routes.customerCheckout, equals('/customer/checkout'));
      expect(Routes.customerFarmers, equals('/customer/farmers'));
      expect(Routes.customerProductDetails, equals('/customer/products/details'));
      expect(Routes.farmerDashboard, equals('/farmer/dashboard'));
      expect(Routes.adminDashboard, equals('/admin/dashboard'));

      final registeredRouteNames = AppPages.pages.map((p) => p.name).toSet();
      expect(registeredRouteNames.contains(Routes.login), isTrue);
      expect(registeredRouteNames.contains(Routes.register), isTrue);
      expect(registeredRouteNames.contains(Routes.customerShell), isTrue);
      expect(registeredRouteNames.contains(Routes.customerCheckout), isTrue);
      expect(registeredRouteNames.contains(Routes.farmerDashboard), isTrue);
      expect(registeredRouteNames.contains(Routes.adminDashboard), isTrue);
    });
  });

  group('UI Architecture Validation - No Role on Login, Role Choice on Register', () {
    testWidgets('LoginView has no role selection (common for all roles)', (tester) async {
      Get.put(LoginController());

      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
          getPages: AppPages.pages,
        ),
      );

      // Verify email and password fields exist
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Verify NO role selector exists on the login screen
      expect(find.text('Customer'), findsNothing);
      expect(find.text('Farmer'), findsNothing);
      expect(find.text('Admin'), findsNothing);
    });

    testWidgets('RegisterView has Customer and Farmer role choices, no Admin', (tester) async {
      Get.put(RegisterController());

      await tester.pumpWidget(
        GetMaterialApp(
          home: const RegisterView(),
          getPages: AppPages.pages,
        ),
      );

      // Verify Customer and Farmer role options exist
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Farmer'), findsOneWidget);

      // Verify Admin option does NOT exist
      expect(find.text('Admin'), findsNothing);

      // Verify input fields exist
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
    });

    testWidgets('FarmerDashboardView renders overview and logout', (tester) async {
      final farmerController = Get.put(FarmerDashboardController());
      farmerController.businessName.value = 'Green Valley Farm';
      farmerController.rating.value = 4.7;

      await tester.pumpWidget(
        GetMaterialApp(
          home: const FarmerDashboardView(),
          getPages: AppPages.pages,
        ),
      );

      expect(find.text('Farmer Dashboard'), findsOneWidget);
      expect(find.text('Green Valley Farm'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });
}
