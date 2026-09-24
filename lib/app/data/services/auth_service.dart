import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';

// Keeps the logged-in user's role so middleware and controllers can check it.
class AuthService extends GetxService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final role = ''.obs;

  bool get isAdmin => _auth.currentUser != null && role.value == Roles.admin;

  // Reads users/{uid}.role from Firestore. Returns true if the user is an admin.
  Future<bool> loadRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      role.value = '';
      return false;
    }
    final doc = await _db.collection(Db.users).doc(user.uid).get();
    role.value = (doc.data()?['role'] ?? '').toString().toLowerCase();
    return isAdmin;
  }

  Future<void> loginAdmin(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    final ok = await loadRole();
    if (!ok) {
      await logout();
      throw Exception('This account does not have admin access.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    role.value = '';
  }
}
