import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

/// Provider for AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

/// Provider for auth state stream
/// Emits whenever auth state changes (login/logout)
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for current user
/// Returns null if not authenticated
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((state) => state.session?.user).value;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Provider for user profile data (legacy - use profile feature providers)
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return null;

  return await authService.getUserProfile();
});

/// Auth state enum for UI
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Provider for auth UI state
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) {
      if (state.session != null) {
        return AuthStatus.authenticated;
      }
      return AuthStatus.unauthenticated;
    },
    loading: () => AuthStatus.loading,
    error: (_, __) => AuthStatus.error,
  );
});
