// Standalone entry point for running the Farmer module in isolation.
// Use this file during development: `flutter run -t lib/farmer_main.dart`
// This file is NOT part of the shared app – do NOT modify main.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'farmer_dev_config.dart';
import 'app/data/repositories/farmer_firestore_repository.dart';
import 'app/modules/farmer/dashboard/bindings/dashboard_binding.dart';
import 'app/modules/farmer/dashboard/views/farmer_dashboard_view.dart';
import 'app/modules/farmer/farmer_pages.dart';
import 'app/modules/farmer/farmer_theme.dart';

// ── DEV flags ─────────────────────────────────────────────────────────────────
// Set to true ONCE to backfill missing fields on your Firestore products,
// then immediately flip back to false.
const bool _backfillProducts = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // DEV-ONLY: auto sign-in so currentUser != null when running standalone.
  // In the integrated app, Auth module handles this – this block is skipped.
  if (kDebugMode) {
    await _devSignIn();
  }

  // DEV-ONLY: backfill missing fields on Firestore products.
  // Flip _backfillProducts = true above, run once, then set back to false.
  if (kDebugMode && _backfillProducts) {
    await _runBackfill();
  }

  runApp(const FarmerApp());
}

/// Signs in with the test credentials from [FarmerDevConfig].
/// Safe to call even if already signed in.
Future<void> _devSignIn() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser != null) return; // already authenticated

  try {
    await auth.signInWithEmailAndPassword(
      email: FarmerDevConfig.devEmail,
      password: FarmerDevConfig.devPassword,
    );
    if (kDebugMode) {
      // ignore: avoid_print
      print('[FarmerDev] Signed in as ${auth.currentUser?.email}');
    }
  } on FirebaseAuthException catch (e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[FarmerDev] ⚠️ Auto sign-in failed (${e.code}): ${e.message}');
      // ignore: avoid_print
      print('[FarmerDev] Update credentials in lib/farmer_dev_config.dart '
          'or create the test user in Firebase Console.');
    }
    // App continues with anonymous / no auth – Firestore rules may reject reads
  }
}

/// Calls [FarmerFirestoreRepository.backfillMyProducts] to fill in any missing
/// schema fields on existing Firestore product documents.
Future<void> _runBackfill() async {
  try {
    // ignore: avoid_print
    print('[FarmerDev] Starting product backfill...');
    await FarmerFirestoreRepository().backfillMyProducts();
    // ignore: avoid_print
    print('[FarmerDev] Backfill complete.');
  } catch (e) {
    // ignore: avoid_print
    print('[FarmerDev] Backfill failed: $e');
  }
}

class FarmerApp extends StatelessWidget {
  const FarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HarvestHub – Farmer',
      debugShowCheckedModeBanner: false,
      theme: FarmerTheme.lightTheme,
      initialRoute: '/',
      initialBinding: DashboardBinding(),
      getPages: [
        GetPage(
          name: '/',
          page: () => const FarmerDashboardView(),
          binding: DashboardBinding(),
        ),
        ...FarmerPages.farmerPages,
      ],
    );
  }
}
