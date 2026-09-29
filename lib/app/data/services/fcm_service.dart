import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';

/// Handles this device's FCM registration and foreground banners.
///
/// The app never holds a credential capable of *sending* a notification. All
/// sending happens in Cloud Functions with the Admin SDK
/// (`functions/index.js`); this class only registers the device token and
/// displays notifications the platform delivers.
class FcmService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  final _local = FlutterLocalNotificationsPlugin();

  /// This device's current FCM token, or '' when unavailable (e.g. web, or a
  /// device with no Play Services).
  final token = ''.obs;

  /// Set when registration fails, surfaced in the UI instead of failing silently.
  final error = ''.obs;

  static const _tokenSubcollection = 'fcm_tokens';

  /// Must be a top-level function; the platform calls it when a notification
  /// arrives while the app is terminated.
  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    // Nothing to do here: the OS displays the notification itself.
  }

  Future<FcmService> init() async {
    try {
      // Static in firebase_messaging 16.x.
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

      // Ask for permission. iOS needs it explicitly; Android 13+ too.
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM permission status: ${settings.authorizationStatus}');

      await _initLocalNotifications();

      final t = await _messaging.getToken();
      if (t != null && t.isNotEmpty) {
        token.value = t;
      }
      await _registerTokenLocally();

      // A device token can be rotated by the platform, so keep the stored copy
      // in step rather than only reading it once at startup. This one is an
      // instance getter, unlike onMessage / onBackgroundMessage above.
      _messaging.onTokenRefresh.listen((fresh) async {
        token.value = fresh;
        await _registerTokenLocally();
      });

      // Foreground messages are not shown by the OS, so display them ourselves.
      FirebaseMessaging.onMessage.listen(_showForeground);

      debugPrint('FCM initialised, token present: ${token.value.isNotEmpty}');
    } catch (e) {
      error.value = 'Notifications unavailable: ${errorText(e)}';
      debugPrint('FCM init failed: $e');
    }
    return this;
  }

  Future<void> _initLocalNotifications() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested via FCM above
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    // flutter_local_notifications 22.x takes named arguments.
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
  }

  /// Shared presentation for a notification, so foreground banners and any
  /// locally-raised message look identical.
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'harvesthub_channel',
      'HarvestHub notifications',
      channelDescription:
          'Order updates, restock alerts and messages from farmers.',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _showForeground(RemoteMessage message) async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    final notification = message.notification;
    await _local.show(
      id: message.hashCode,
      title: notification?.title ?? 'HarvestHub',
      body: notification?.body ?? '',
      notificationDetails: _details,
    );
  }

  /// Registers this device's token for the currently signed-in user.
  ///
  /// Public on purpose: [init] runs at app start, before anyone has signed in,
  /// so its own registration attempt finds no uid and bails out. Without a
  /// public entry point there was nothing to call once a user *had* signed in,
  /// so the token was only ever written if the platform happened to rotate it -
  /// which is rare. The result was that most devices had no token document at
  /// all and could never be reached by a notification.
  ///
  /// Safe to call repeatedly: the document id is derived from the token, so a
  /// repeat call overwrites the same entry instead of duplicating it.
  Future<void> registerCurrentDevice() => _registerTokenLocally();

  /// Stores the token under `users/{uid}/fcm_tokens/{hash}`.
  ///
  /// Keyed by a hash of the token so re-registering after a rotation replaces
  /// the entry rather than accumulating one document per token.
  Future<void> _registerTokenLocally() async {
    final t = token.value;
    final uid = _currentUid();
    if (t.isEmpty || uid.isEmpty) return;
    try {
      await _db
          .collection(Db.users)
          .doc(uid)
          .collection(_tokenSubcollection)
          .doc(_docIdFor(t))
          .set({
        'token': t,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      error.value = 'Could not register for notifications: ${errorText(e)}';
    }
  }

  String _currentUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Strips characters Firestore disallows in a document id.
  static String _docIdFor(String token) {
    final cleaned = token.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    // 128 chars keeps the id readable while staying collision-safe in practice.
    return cleaned.length <= 120 ? cleaned : cleaned.substring(0, 120);
  }

  /// Removes this device's token, called on logout.
  Future<void> unregisterCurrentDevice() async {
    final t = token.value;
    final uid = _currentUid();
    if (t.isEmpty || uid.isEmpty) return;
    try {
      await _db
          .collection(Db.users)
          .doc(uid)
          .collection(_tokenSubcollection)
          .doc(_docIdFor(t))
          .delete();
    } catch (_) {
      // A stale token is harmless; the sender skips invalid registrations.
    }
  }
}
