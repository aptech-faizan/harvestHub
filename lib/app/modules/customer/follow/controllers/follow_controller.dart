import 'dart:async';

import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/farmer_model.dart';
import 'package:harvest_hub/app/data/repositories/follow_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

/// Followed-farmers state, shared across every customer screen.
///
/// Registered permanently in `main.dart` so the follow button on the product
/// page, the farmer page and the market sheet all react to one subscription
/// instead of each screen re-querying.
class FollowController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _repo = FollowRepository();

  final followedIds = <String>{}.obs;
  final followedFarmers = <FarmerModel>[].obs;
  final isLoading = false.obs;

  /// Set when Firestore refuses the read or write, e.g. security rules are not
  /// deployed yet. Surfaces in the UI instead of showing a silently empty list.
  final error = ''.obs;

  StreamSubscription<Set<String>>? _sub;
  Worker? _authWorker;
  String _streamUid = '';

  String get uid => authService.currentUser?.uid ?? '';

  /// Convenience accessor so views do not need null checks.
  static FollowController get instance {
    if (Get.isRegistered<FollowController>()) {
      return Get.find<FollowController>();
    }
    return Get.put(FollowController(), permanent: true);
  }

  @override
  void onInit() {
    super.onInit();

    // This controller is permanent, so it is constructed at app start - before
    // anybody has logged in - when there is no uid to watch. Subscribing only
    // once here left the stream dead for the whole session, so the follow button
    // never updated. Re-subscribe whenever the signed-in user changes.
    _authWorker = ever(authService.firebaseUser, (_) => _startWatching());
    _startWatching();
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    _sub?.cancel();
    super.onClose();
  }

  /// (Re)points the live subscription at the current user.
  void _startWatching() {
    _sub?.cancel();
    _sub = null;

    followedIds.clear();
    followedFarmers.clear();
    error.value = '';

    final id = uid;
    if (id.isEmpty) {
      _streamUid = '';
      return;
    }
    // Already streaming this account; do not restart the listener.
    if (_streamUid == id && _sub != null) return;
    _streamUid = id;

    isLoading.value = true;
    _sub = _repo.watchFollowedFarmerIds(id).listen(
      (ids) {
        isLoading.value = false;
        error.value = '';
        followedIds.assignAll(ids);
        loadFollowedFarmers(ids);
      },
      onError: (Object e) {
        isLoading.value = false;
        // Most often an undeployed/restrictive firestore.rules denying the read.
        error.value =
            'Could not load your followed farmers. Check that Firestore rules '
            'are deployed. (${errorText(e)})';
      },
    );
  }

  /// Called after logout / login so the next account does not inherit state.
  void refreshForCurrentUser() => _startWatching();

  bool isFollowing(String farmerId) => followedIds.contains(farmerId);

  Future<void> loadFollowedFarmers([Set<String>? ids]) async {
    final use = ids ?? followedIds.toSet();
    if (uid.isEmpty || use.isEmpty) {
      followedFarmers.clear();
      return;
    }
    try {
      followedFarmers.assignAll(await _repo.getFollowedFarmers(uid));
    } catch (e) {
      error.value = 'Could not load farmer profiles: ${errorText(e)}';
    }
  }

  /// Follows or unfollows [farmerId].
  ///
  /// Local state is updated immediately after the write succeeds so the button
  /// responds instantly; the live stream then confirms. If the write is
  /// rejected (for example rules are not deployed) nothing changes locally and
  /// the reason is surfaced to the user rather than the button silently
  /// appearing broken.
  Future<void> toggle(String farmerId, {String farmerName = ''}) async {
    if (uid.isEmpty) {
      showError('Please log in first.');
      return;
    }
    if (farmerId.isEmpty) {
      showError('This farmer could not be identified.');
      return;
    }

    final wasFollowing = isFollowing(farmerId);
    try {
      if (wasFollowing) {
        await _repo.unfollow(uid: uid, farmerId: farmerId);
      } else {
        await _repo.follow(
          uid: uid,
          farmerId: farmerId,
          farmerName: farmerName,
        );
      }
      error.value = '';
      _applyLocal(farmerId, wasFollowing);
    } catch (e) {
      final msg = errorText(e);
      // Permission denied almost always means firestore.rules is not deployed.
      if (msg.toLowerCase().contains('permission')) {
        showError(
          'Follow was blocked by Firestore (permission denied). '
          'Deploy your security rules with: firebase deploy --only firestore:rules',
        );
      } else {
        showError('Could not update follow: $msg');
      }
    }
  }

  /// Mirrors a confirmed write into local state.
  void _applyLocal(String farmerId, bool wasFollowing) {
    final next = followedIds.toSet();
    if (wasFollowing) {
      next.remove(farmerId);
    } else {
      next.add(farmerId);
    }
    followedIds.assignAll(next);
    loadFollowedFarmers(next);
  }
}
