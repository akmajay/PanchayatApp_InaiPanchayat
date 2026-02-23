import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/app_constants.dart';
import '../../auth/widgets/government_disclaimer.dart';
import '../../posts/models/post_model.dart';
import '../../posts/providers/posts_provider.dart';
import '../../posts/widgets/post_card.dart';
import '../widgets/profile_header.dart';
import '../services/profile_service.dart';
import '../../../shared/widgets/loading_skeletons.dart';
import '../../../core/router/routes.dart';
import 'package:go_router/go_router.dart';

/// Provider to fetch only the current user's posts
final userPostsProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return <Post>[];
  return ref.read(postServiceProvider).getUserPosts(user.id);
});

/// Profile screen with user info, history, and settings
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPostsAsync = ref.watch(userPostsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile (मेरी प्रोफ़ाइल)'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(userPostsProvider.future),
        child: CustomScrollView(
          slivers: [
            // 1. Header with details
            const SliverToBoxAdapter(child: ProfileHeader()),

            // 2. Settings Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings & Support (सेटिंग्स और सहायता)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile (प्रोफ़ाइल बदलें)',
                      onTap: () => context.push(AppRoutes.editProfile),
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline,
                      label: 'About ${AppInfo.appName} (ऐप के बारे में)',
                      onTap: () => context.push(AppRoutes.about),
                    ),
                    _SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      label: 'Delete Account (खाता हटाएँ)',
                      color: Colors.red,
                      onTap: () => _handleDeleteAccount(context, ref),
                    ),
                    const Divider(),
                    _SettingsTile(
                      icon: Icons.logout,
                      label: 'Logout (लॉगआउट)',
                      color: Colors.red,
                      onTap: () => ref.read(authServiceProvider).signOut(),
                    ),
                    const SizedBox(height: 24),
                    const GovernmentDisclaimer(compact: true),
                  ],
                ),
              ),
            ),

            // 3. My Grievances History
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'My Grievances (मेरी शिकायतें)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            userPostsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'You haven\'t posted any grievances yet.\n(आपने अभी तक कोई शिकायत नहीं की है।)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = posts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PostCard(post: post),
                    );
                  }, childCount: posts.length),
                );
              },
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: SkeletonFeedCard(),
                  ),
                  childCount: 3,
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error loading history: $err')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('खाता हटाना चाहते हैं? (Delete Account?)'),
        content: const Text(
          'Are you sure you want to delete your account? All your posts, photos, and data will be permanently erased. This cannot be undone.\n\n(क्या आप वाकई अपना खाता हटाना चाहते हैं? आपकी सभी पोस्ट, फोटो और डेटा स्थायी रूप से मिटा दिए जाएंगे। इसे वापस नहीं लाया जा सकता।)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL (रद्द करें)'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading overlay
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                await ProfileService.instance.requestAccountDeletion();
                if (context.mounted) {
                  // The router redirected them anyway because auth state changed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account successfully deleted.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Remove loading
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text(
              'DELETE PERMANENTLY (स्थायी रूप से हटाएं)',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
