import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import 'router_notifier.dart';
import '../../features/posts/screens/create_post_screen.dart';
import '../../features/posts/screens/post_detail_screen.dart';
import '../../features/auth/auth.dart';
import '../../features/auth/screens/profile_completion_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/admin/screens/moderation_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/terms_of_service_screen.dart';
import '../../features/posts/screens/edit_post_screen.dart';
import '../../features/settings/screens/about_screen.dart';
import '../../features/posts/models/post_model.dart';

/// GoRouter configuration using RouterNotifier
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    // Listens to the notifier for changes
    refreshListenable: notifier,
    // Uses the notifier's redirect logic
    redirect: notifier.redirect,
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login screen
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Profile completion
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const ProfileCompletionScreen(),
      ),

      // Home feed
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Create post
      GoRoute(
        path: AppRoutes.createPost,
        builder: (context, state) => const CreatePostScreen(),
      ),

      // Post detail
      GoRoute(
        path: AppRoutes.postDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PostDetailScreen(postId: id);
        },
      ),

      // Edit Post
      GoRoute(
        path: '/post/:id/edit',
        builder: (context, state) {
          final post = state.extra as Post;
          return EditPostScreen(post: post);
        },
      ),

      // Admin Moderation
      GoRoute(
        path: AppRoutes.moderation,
        builder: (context, state) => const ModerationScreen(),
      ),

      // User Profile
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: 'terms',
            builder: (context, state) => const TermsOfServiceScreen(),
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
});

/// Splash screen for initial auth check
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
