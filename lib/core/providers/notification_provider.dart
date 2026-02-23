import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../services/notification_service.dart';

/// Provider that watches the current profile and manages FCM topic subscriptions.
/// This ensures the user is always subscribed to the correct ward topic.
final fcmSubscriptionProvider = Provider<void>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);

  profileAsync.whenData((profile) {
    if (profile != null) {
      final wardNo = profile['ward_no'] as int?;
      if (wardNo != null) {
        NotificationService.instance.subscribeToWard(wardNo);
      }
    }
  });

  // Handle cleanup or ward changes if needed
  // For now, we assume one subscription per session.
  // FCM handle's duplicates, but we could store previous ward to unsubscribe.
});
