import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/data/models/user_model.dart';
import 'package:harvest_hub/app/data/services/fcm_service.dart';
import 'package:harvest_hub/app/modules/customer/cart/controllers/cart_controller.dart';
import 'package:harvest_hub/app/modules/customer/follow/controllers/follow_controller.dart';
import 'package:harvest_hub/app/modules/customer/orders/controllers/orders_controller.dart';
import 'package:harvest_hub/app/modules/customer/wishlist/controllers/wishlist_controller.dart';
import 'package:harvest_hub/app/modules/farmer/orders/controllers/farmer_orders_controller.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Centralized authentication service managing auth state, user profile, and role-based routing.
class AuthService extends GetxService {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  AuthService({this.auth, this.firestore});

  FirebaseAuth get _auth => auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  final Rxn<User> firebaseUser = Rxn<User>();
  final RxString role = ''.obs;
  final Rxn<UserModel> currentUserModel = Rxn<UserModel>();

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get isAuthenticated => currentUser != null && role.value.isNotEmpty;
  bool get isCustomer => isAuthenticated && role.value == Roles.customer;
  bool get isFarmer => isAuthenticated && role.value == Roles.farmer;
  bool get isAdmin => isAuthenticated && role.value == Roles.admin;

  @override
  void onInit() {
    super.onInit();
    try {
      firebaseUser.value = _auth.currentUser;
    } catch (_) {}
  }

  /// Loads the authenticated user's role and profile data from Firestore.
  /// If the document is missing, the account is deactivated, or the role is invalid,
  /// the user is safely signed out and state is cleared.
  Future<String?> loadUserRoleAndProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _clearState();
      return null;
    }

    try {
      final doc = await _db.collection(Db.users).doc(user.uid).get();
      if (!doc.exists || doc.data() == null) {
        await _auth.signOut();
        _clearState();
        return null;
      }

      final data = doc.data()!;
      final isActive = data['isActive'] as bool? ?? true;
      if (!isActive) {
        await _auth.signOut();
        _clearState();
        throw Exception('This account has been deactivated or blocked.');
      }

      final userRole = (data['role'] as String? ?? '').trim().toLowerCase();
      if (userRole != Roles.customer &&
          userRole != Roles.farmer &&
          userRole != Roles.admin) {
        await _auth.signOut();
        _clearState();
        throw Exception('Invalid or unrecognized user role.');
      }

      firebaseUser.value = user;
      role.value = userRole;
      currentUserModel.value = UserModel.fromMap(data, doc.id);
      return userRole;
    } catch (e) {
      _clearState();
      rethrow;
    }
  }

  /// Preserved for backward compatibility with existing admin controllers.
  Future<bool> loadRole() async {
    try {
      final userRole = await loadUserRoleAndProfile();
      return userRole == Roles.admin;
    } catch (_) {
      return false;
    }
  }

  /// Common login method for Customer, Farmer, and Admin.
  /// Authenticates credentials, reads the user role from Firestore, and sets state.
  Future<String> login(String email, String password) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw Exception('Email and password must not be empty.');
    }

    await _auth.signInWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final resolvedRole = await loadUserRoleAndProfile();
    if (resolvedRole == null || resolvedRole.isEmpty) {
      await _auth.signOut();
      _clearState();
      throw Exception('User profile or role not found.');
    }

    return resolvedRole;
  }

  /// Preserved for backward compatibility.
  Future<void> loginAdmin(String email, String password) async {
    final userRole = await login(email, password);
    if (userRole != Roles.admin) {
      await logout();
      throw Exception('This account does not have admin access.');
    }
  }

  /// Common registration method for Customer and Farmer.
  /// Public registration for Admin is strictly prevented.
  ///
  /// [marketId] is optional for Farmers and stored in `farmers/{uid}` alongside
  /// the denormalised [marketName] so lists never need a second lookup.
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
    final normalizedRole = role.trim().toLowerCase();
    if (normalizedRole != Roles.customer && normalizedRole != Roles.farmer) {
      throw Exception('Public registration is only allowed for Customer or Farmer.');
    }

    if (name.trim().isEmpty) throw Exception('Name cannot be empty.');
    if (email.trim().isEmpty || !email.contains('@')) throw Exception('Enter a valid email.');
    if (phone.trim().isEmpty) throw Exception('Phone number cannot be empty.');
    if (password.length < 6) throw Exception('Password must be at least 6 characters.');

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    // Create user profile in Firestore
    await _db.collection(Db.users).doc(uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'role': normalizedRole,
      'fcmToken': '',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // If farmer, also create base farmer entry linked to the chosen market
    if (normalizedRole == Roles.farmer) {
      await _db.collection(Db.farmers).doc(uid).set({
        'userId': uid,
        'businessName': name.trim(),
        'description': '',
        'rating': 0.0,
        'lowStockThreshold': 5,
        'marketId': marketId.trim(),
        'marketName': marketName.trim(),
      });
    }

    final resolvedRole = await loadUserRoleAndProfile();
    return resolvedRole ?? normalizedRole;
  }

  /// Ends the session that a freshly created account implicitly gained.
  ///
  /// `createUserWithEmailAndPassword` signs the new user in as part of creating
  /// them, so registration leaves a live session behind that must be dropped:
  /// `/login` is guarded by `GuestMiddleware`, which redirects any
  /// authenticated user straight back to their role home.
  ///
  /// [logout] is deliberately not reused for this. It unregisters the device's
  /// FCM token, and a token is only re-registered at app start or on platform
  /// rotation, so a brand-new account would end up with no push notifications
  /// until the app was restarted. Cart, wishlist and follow state are left
  /// alone too - the previous session was already cleared by the logout that
  /// brought the user to the registration screen.
  Future<void> endSessionAfterRegistration() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    _clearState();
  }

  /// Centralized logout clearing Firebase Auth, in-memory state, cart, and wishlist.
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}

    _clearState();

    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clear();
    }
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().clearAll();
    }
    // Follow state is per-account, so drop the previous user's follows.
    if (Get.isRegistered<FollowController>()) {
      Get.find<FollowController>().refreshForCurrentUser();
    }
    // Both of these controllers hold the previous account's rows in an RxList.
    // GetX's route-scoped disposal probably already drops them when the module
    // route is removed, so this is a deliberate belt-and-braces guarantee rather
    // than a fix for an observed leak: no per-user order data survives a session
    // boundary regardless of how the route lifecycle is configured later, and a
    // load still in flight from the old session cannot land in a controller the
    // next user goes on to read. Deleted outright rather than emptied for that
    // reason. The owning bindings re-register on the next visit.
    //
    // Note: `OrdersController` here is the CUSTOMER one. An unrelated
    // `admin/orders/controllers/orders_controller.dart` declares a different
    // class under the same name; it is deliberately not imported in this file,
    // so this reference is unambiguous - but the duplicate name is worth
    // renaming at some point.
    if (Get.isRegistered<OrdersController>()) {
      Get.delete<OrdersController>(force: true);
    }
    if (Get.isRegistered<FarmerOrdersController>()) {
      Get.delete<FarmerOrdersController>(force: true);
    }
    // Drop this device's push token so the next user on the same handset does
    // not inherit the previous account's notifications.
    if (Get.isRegistered<FcmService>()) {
      await Get.find<FcmService>().unregisterCurrentDevice();
    }

    Get.offAllNamed(Routes.login);
  }

  /// Routes the user to their respective module based on their verified role.
  void navigateToRoleHome(String userRole) {
    // Whoever signs in, register this device for push now that a uid exists.
    // FcmService.init() ran at app start with nobody signed in, so its own
    // registration attempt was a no-op; without this the token would only ever
    // be written if the platform happened to rotate it, which is rare.
    if (Get.isRegistered<FcmService>()) {
      Get.find<FcmService>().registerCurrentDevice();
    }

    switch (userRole.toLowerCase()) {
      case Roles.customer:
        if (Get.isRegistered<WishlistController>()) {
          Get.find<WishlistController>().loadWishlist();
        }
        // Follow state is per-account, so re-point its stream at the new user.
        if (Get.isRegistered<FollowController>()) {
          Get.find<FollowController>().refreshForCurrentUser();
        }
        Get.offAllNamed(Routes.customerShell);
        break;
      case Roles.farmer:
        Get.offAllNamed(Routes.farmerDashboard);
        break;
      case Roles.admin:
        Get.offAllNamed(Routes.adminDashboard);
        break;
      default:
        Get.offAllNamed(Routes.login);
    }
  }

  void _clearState() {
    role.value = '';
    currentUserModel.value = null;
    firebaseUser.value = null;
  }
}
