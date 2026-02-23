/// App Constants
/// Contains global constants for the PanchayatApp application.

library;

/// App metadata
class AppInfo {
  static const String appName = 'PanchayatApp';
  static const String packageName = 'com.inaipanchayat.app';
  static const String version = '1.0.0+1';
  static const int buildNumber = 1;

  /// Hardcoded list of admin emails for MVP
  static const List<String> adminEmails = [
    'life.jay.com@gmail.com',
    'jay.panchayat@gmail.com',
  ];

  static bool isAdmin(String? email) {
    if (email == null) return false;
    return adminEmails.contains(email.toLowerCase());
  }
}

/// API Configuration
/// Supabase credentials for inaipanchayat project
class ApiConfig {
  // Supabase project URL - Default for local dev if not provided in build
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://skbbbmpirxuptuuonfyh.supabase.co',
  );

  // Supabase anon/public key - Default for local dev if not provided in build
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrYmJibXBpcnh1cHR1dW9uZnloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzMDUwMzIsImV4cCI6MjA4NTg4MTAzMn0.kf7WpoAS80W1BnmBXsb-sICIkILqUu8VDYHFegqGXXo',
  );
}

/// Storage Keys for Hive
class StorageKeys {
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
}

/// Route Names
class RouteNames {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String posts = '/posts';
  static const String createPost = '/posts/create';
}

/// Asset Paths
class AssetPaths {
  static const String images = 'assets/images';
  static const String icons = 'assets/icons';
  static const String animations = 'assets/animations';
}

/// Duration Constants
class AppDurations {
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 24);
}
