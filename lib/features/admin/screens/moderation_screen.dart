import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/providers/posts_provider.dart';
import '../widgets/reported_post_card.dart';

/// Admin dashboard to moderate reported content
class ModerationScreen extends ConsumerStatefulWidget {
  const ModerationScreen({super.key});

  @override
  ConsumerState<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends ConsumerState<ModerationScreen> {
  // Filter state: true = Hidden, false = Pending Reports
  bool _showHiddenOnly = false;

  @override
  Widget build(BuildContext context) {
    final reportedPostsAsync = ref.watch(reportedPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(reportedPostsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Pending Reports'),
                  icon: Icon(Icons.report_gmailerrorred),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Hidden Content'),
                  icon: Icon(Icons.visibility_off),
                ),
              ],
              selected: {_showHiddenOnly},
              onSelectionChanged: (value) {
                setState(() => _showHiddenOnly = value.first);
              },
            ),
          ),

          Expanded(
            child: reportedPostsAsync.when(
              data: (posts) {
                final filteredPosts = posts.where((p) {
                  return _showHiddenOnly ? p.isHidden : !p.isHidden;
                }).toList();

                if (filteredPosts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.done_all,
                          size: 64,
                          color: Colors.green.shade200,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'All clear! No pending content.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return ReportedPostCard(
                      post: post,
                      onDismiss: () =>
                          _handleResolve(post.id, shouldDelete: false),
                      onDelete: () =>
                          _handleResolve(post.id, shouldDelete: true),
                      onBan: () => _handleBan(post.userId, post.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResolve(
    String postId, {
    required bool shouldDelete,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(shouldDelete ? 'Delete Content?' : 'Dismiss Reports?'),
        content: Text(
          shouldDelete
              ? 'This will permanently remove the post and its media.'
              : 'This will reset report count and make the post visible again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              shouldDelete ? 'Delete' : 'Confirm',
              style: TextStyle(color: shouldDelete ? Colors.red : Colors.green),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(postServiceProvider)
            .resolveReport(postId, shouldDelete: shouldDelete);
        final _ = ref.refresh(reportedPostsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                shouldDelete ? 'Post deleted' : 'Reports dismissed',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _handleBan(String userId, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban Citizen?'),
        content: const Text(
          'This user will be marked as banned. They can still view but not post.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ban User',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(postServiceProvider).banUser(userId);
        // Also hide this specific post as part of the ban action if desired
        await ref
            .read(postServiceProvider)
            .resolveReport(
              postId,
              shouldDelete: false,
            ); // Reset and hide logic variant

        final _ = ref.refresh(reportedPostsProvider);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User banned')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
