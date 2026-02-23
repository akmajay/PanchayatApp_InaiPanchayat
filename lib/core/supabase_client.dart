// Supabase Client Configuration
// Provides singleton access to the Supabase client throughout the app.

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_constants.dart';

/// Global Supabase client instance
/// Use this getter to access Supabase services anywhere in the app
SupabaseClient get supabase => Supabase.instance.client;

/// Supabase initialization helper
/// Call this in main.dart before runApp()
class SupabaseConfig {
  /// Initialize Supabase with configured credentials
  ///
  /// Throws an exception if URL or anon key are empty/invalid
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConfig.supabaseUrl,
      anonKey: ApiConfig.supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  /// Check if Supabase is properly configured
  static bool get isConfigured =>
      ApiConfig.supabaseUrl.isNotEmpty && ApiConfig.supabaseAnonKey.isNotEmpty;

  /// Get current authenticated user (null if not logged in)
  static User? get currentUser => supabase.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get auth state stream for listening to auth changes
  static Stream<AuthState> get authStateChanges =>
      supabase.auth.onAuthStateChange;
}
