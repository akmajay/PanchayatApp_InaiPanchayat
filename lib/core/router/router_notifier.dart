import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth.dart';
import '../../features/profile/profile.dart';
import 'routes.dart';

/// Notifier to handle router redirections and state changes
/// Prevents GoRouter from rebuilding on every state change
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStatusProvider, (_, __) => notifyListeners());
    _ref.listen(currentUserProvider, (_, __) => notifyListeners());
    _ref.listen(profileCompletedProvider, (_, __) => notifyListeners());
  }

  /// Redirect logic used by GoRouter
  String? redirect(BuildContext context, GoRouterState state) {
    final authStatus = _ref.read(authStatusProvider);
    final profileCompletedAsync = _ref.read(profileCompletedProvider);

    final isLoggedIn = authStatus == AuthStatus.authenticated;
    final isAuthLoading =
        authStatus == AuthStatus.loading || authStatus == AuthStatus.initial;

    final currentPath = state.matchedLocation;

    // 1. Show splash while auth is loading
    if (isAuthLoading) {
      if (currentPath != AppRoutes.splash) {
        return AppRoutes.splash;
      }
      return null;
    }

    // 2. Not logged in - redirect to login
    if (!isLoggedIn) {
      if (currentPath == AppRoutes.login) return null;
      // Allow deep link to other public pages if needed in future
      return AppRoutes.login;
    }

    // 3. Logged in - check profile completion
    // We only redirect if we have determined the profile status
    final hasProfile = profileCompletedAsync.when(
      data: (val) => val,
      loading: () =>
          false, // Treat as incomplete while loading to prevent premature access?
      // actually, better to stay on splash or show loading
      error: (_, __) => false,
    );

    final isProfileLoading = profileCompletedAsync.isLoading;

    // If fully authenticated but profile is loading, we might want to wait
    // simple approach: show splash
    if (isProfileLoading) {
      if (currentPath != AppRoutes.splash) return AppRoutes.splash;
      return null;
    }

    // 4. Profile incomplete - redirect to completion
    if (!hasProfile) {
      if (currentPath == AppRoutes.completeProfile) return null;
      return AppRoutes.completeProfile;
    }

    // 5. Profile complete - prevent access to auth/splash screens
    if (currentPath == AppRoutes.splash ||
        currentPath == AppRoutes.login ||
        currentPath == AppRoutes.completeProfile) {
      return AppRoutes.home;
    }

    // 6. Admin Guard
    if (currentPath.startsWith(AppRoutes.moderation)) {
      final user = _ref.read(currentUserProvider);
      // We import from app_constants here
      final isAdmin = _isAdmin(user?.email);
      if (!isAdmin) {
        return AppRoutes.home;
      }
    }

    return null;
  }

  bool _isAdmin(String? email) {
    // Hardcoded for MVP as per requirements
    const adminEmails = [
      'life.jay.com@gmail.com',
      'jay.panchayat@gmail.com',
      'mukhiya@bihar.gov.in',
      'test@test.com',
    ];
    if (email == null) return false;
    return adminEmails.contains(email.toLowerCase());
  }
}

/// Provider for the router notifier
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
