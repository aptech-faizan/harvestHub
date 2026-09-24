import 'package:flutter/foundation.dart';

import '../repositories/farmer_firestore_repository.dart';
import '../repositories/farmer_mock_repository.dart';
import '../repositories/farmer_repository.dart';

/// Shared repository factory for all Farmer module bindings.
///
/// Set [FarmerRepoFactory.useMock] = true to force the in-memory mock
/// (useful for UI-only development or widget tests without Firebase).
abstract class FarmerRepoFactory {
  /// If true, always return [FarmerMockRepository] regardless of build mode.
  static bool useMock = false;

  /// Returns the appropriate [FarmerRepository] instance:
  ///   - Release mode → always Firestore
  ///   - Debug/Profile mode + useMock==false → Firestore
  ///   - Debug/Profile mode + useMock==true  → Mock
  static FarmerRepository create() {
    if (kReleaseMode || !useMock) {
      return FarmerFirestoreRepository();
    }
    return FarmerMockRepository();
  }
}
