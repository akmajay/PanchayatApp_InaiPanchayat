import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_constants.dart';
import '../../core/router/routes.dart';
import '../../features/auth/auth.dart';
import '../../features/profile/profile.dart';

/// Main app shell layout with AppBar and FAB
/// Used as wrapper for main screens like Home
class AppShell extends ConsumerWidget {
  final Widget child;
  final String? title;
  final bool showFab;
  final List<Widget>? actions;

  const AppShell({
    super.key,
    required this.child,
    this.title,
    this.showFab = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? AppInfo.appName),
        centerTitle: true,
        actions: [
          // User profile actions
          ...?actions,

          // User avatar/menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: profileAsync.when(
                data: (profile) => Text(
                  (profile?['full_name'] as String? ?? user?.email ?? 'U')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                loading: () => const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Icon(Icons.person, size: 16),
              ),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  context.push(AppRoutes.profile);
                  break;
                case 'admin':
                  context.push(AppRoutes.moderation);
                  break;
                case 'logout':
                  await authService.signOut();
                  break;
              }
            },
            itemBuilder: (context) {
              final isAdmin = AppInfo.isAdmin(user?.email);
              return [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.email ?? 'User',
                              overflow: TextOverflow.ellipsis,
                            ),
                            profileAsync.when(
                              data: (p) => Text(
                                'Ward ${p?['ward_no'] ?? '-'}',
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Moderation Panel',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.createPost),
              icon: const Icon(Icons.add),
              label: const Text('Post'),
            )
          : null,
    );
  }
}
