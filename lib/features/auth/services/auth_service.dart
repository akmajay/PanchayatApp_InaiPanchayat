import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_client.dart';

/// Authentication Service
/// Handles Google OAuth sign-in with Supabase
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Get current authenticated user
  User? get currentUser => supabase.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// Sign in with Google using Supabase OAuth
  ///
  /// Uses Supabase's built-in OAuth flow which handles:
  /// - Web: Opens OAuth popup/redirect
  /// - Mobile: Opens OAuth in browser/webview
  Future<({bool success, String? error})> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // For web, use current origin. For mobile, use custom scheme.
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/'
            : 'com.inaipanchayat.app://login-callback/',
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      // OAuth flow is async - user will be redirected
      // Auth state will update via authStateChanges stream
      return (success: true, error: null);
    } catch (e) {
      // Google Sign-In error — pass to caller for UI display.
      return (success: false, error: e.toString());
    }
  }

  /// Sign out from Supabase
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Check if user has completed their profile
  Future<bool> hasCompletedProfile() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final profile = await supabase
          .from('profiles')
          .select('phone, ward_no')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) return false;

      // Profile is complete if phone is set
      final phone = profile['phone'] as String?;
      return phone != null && phone.isNotEmpty;
    } catch (e) {
      // debugPrint removed
      return false;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      return await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
    } catch (e) {
      // debugPrint removed
      return null;
    }
  }
}
