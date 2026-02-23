import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../services/profile_service.dart';

/// Provider for ProfileService singleton
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService.instance;
});

/// Provider for current user's profile data
/// Refetches when auth state changes
final currentProfileProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final profileService = ref.watch(profileServiceProvider);
  return await profileService.getProfile(user.id);
});

/// Provider to check if profile is complete
/// Returns true only if phone AND ward_no are set
final profileCompletedProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  final profileService = ref.watch(profileServiceProvider);
  return await profileService.hasCompletedProfile(user.id);
});

/// Profile update state
class ProfileUpdateState {
  final bool isLoading;
  final String? error;

  const ProfileUpdateState({this.isLoading = false, this.error});

  ProfileUpdateState copyWith({bool? isLoading, String? error}) {
    return ProfileUpdateState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Profile update notifier using Notifier API (Riverpod 3.x)
class ProfileUpdateNotifier extends Notifier<ProfileUpdateState> {
  @override
  ProfileUpdateState build() => const ProfileUpdateState();

  Future<bool> updateProfile({
    required String phone,
    required int wardNo,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profileService = ref.read(profileServiceProvider);
      await profileService.updateProfile(phone: phone, wardNo: wardNo);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final profileUpdateProvider =
    NotifierProvider<ProfileUpdateNotifier, ProfileUpdateState>(
      ProfileUpdateNotifier.new,
    );
