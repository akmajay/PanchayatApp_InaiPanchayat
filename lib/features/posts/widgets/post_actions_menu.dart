import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/post_model.dart';
import '../providers/posts_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../utils/report_utils.dart';
import '../services/block_service.dart';

class PostActionsMenu extends ConsumerWidget {
  final Post post;

  const PostActionsMenu({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.id == post.userId;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleAction(context, ref, value),
      itemBuilder: (context) => [
        if (isOwner) ...[
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 20),
                SizedBox(width: 12),
                Text('Edit Post (संपादन करें)'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'Delete Post (हटाएं)',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ] else ...[
          const PopupMenuItem(
            value: 'report',
            child: Row(
              children: [
                Icon(Icons.report_outlined, size: 20),
                SizedBox(width: 12),
                Text('Report Post (रिपोर्ट करें)'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'block',
            child: Row(
              children: [
                Icon(Icons.block_outlined, size: 20, color: Colors.orange),
                SizedBox(width: 12),
                Text('Block User (ब्लॉक करें)'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        context.push('/post/${post.id}/edit', extra: post);
        break;
      case 'delete':
        _confirmDelete(context, ref);
        break;
      case 'report':
        _handleReport(context, ref);
        break;
      case 'block':
        _confirmBlock(context, ref);
        break;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('पोस्ट हटाएं? (Delete Post?)'),
        content: const Text(
          'Are you sure you want to delete this post? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              try {
                await ref.read(postServiceProvider).deletePost(post.id);
                ref.invalidate(postsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('पोस्ट हटा दी गई (Post deleted)'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmBlock(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ब्लॉक करें? (Block User?)'),
        content: const Text(
          'Are you sure you want to block this user? You will no longer see their posts.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              try {
                await ref.read(blockServiceProvider).blockUser(post.userId);
                // Invalidate feed to refresh
                ref.invalidate(postsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User blocked (यूजर ब्लॉक कर दिया गया)'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('BLOCK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleReport(BuildContext context, WidgetRef ref) {
    ReportHelper.showReportSheet(context, ref, post.id);
  }
}
