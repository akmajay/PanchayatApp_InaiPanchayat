import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background processes
  await Firebase.initializeApp();
  // debugPrint removed
}

/// Service to manage Firebase Cloud Messaging (FCM)
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Initialize notifications
  Future<void> init() async {
    // 1. Request permissions (iOS/Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // debugPrint removed
    } else {
      // debugPrint removed
    }

    // 2. Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // In production, use flutter_local_notifications to show a banner.
        // Foreground message received — no console logging in release.
      }
    });

    // 4. Get FCM Token (optional, for 1-to-1 but we use topics)
    if (kDebugMode) {
      // debugPrint removed
    }
  }

  /// Subscribe to a specific ward topic
  /// Format: ward_{ward_no}
  Future<void> subscribeToWard(int wardNo) async {
    final topic = 'ward_$wardNo';
    try {
      await _fcm.subscribeToTopic(topic);
    } catch (_) {
      // Subscription error — silently handled in production.
    }
  }

  /// Unsubscribe from a ward topic
  Future<void> unsubscribeFromWard(int wardNo) async {
    final topic = 'ward_$wardNo';
    try {
      await _fcm.unsubscribeFromTopic(topic);
      // debugPrint removed
    } catch (e) {
      // debugPrint removed
    }
  }
}
