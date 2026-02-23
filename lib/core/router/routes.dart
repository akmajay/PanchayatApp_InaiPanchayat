/// Route path constants for the app
class AppRoutes {
  AppRoutes._();

  /// Splash/Auth check screen
  static const String splash = '/';

  /// Login screen
  static const String login = '/login';

  /// Profile completion screen
  static const String completeProfile = '/complete-profile';

  /// Home feed screen
  static const String home = '/home';

  /// Create new post screen
  static const String createPost = '/create-post';

  /// Post detail screen - requires :id parameter
  static const String postDetail = '/post/:id';

  /// Admin moderation screen
  static const String moderation = '/admin';

  /// User profile screen
  static const String profile = '/profile';

  /// Edit profile screen
  static const String editProfile = '/profile/edit';

  /// Privacy policy screen
  static const String privacyPolicy = '/profile/privacy';

  /// Terms of service screen
  static const String termsOfService = '/profile/terms';

  /// About app screen
  static const String about = '/profile/about';

  /// Helper to build post detail path with ID
  static String postDetailPath(String id) => '/post/$id';
}
