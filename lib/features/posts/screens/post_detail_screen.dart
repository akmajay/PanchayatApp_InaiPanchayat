import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/posts_provider.dart';
import '../widgets/location_card.dart';
import '../../../shared/widgets/category_tag.dart';
import '../../../shared/widgets/report_button.dart';
import '../../../shared/widgets/author_avatar.dart';
import '../../../shared/widgets/loading_skeletons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen showing full details of a grievance post
class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postProvider(postId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: [ReportButton(postId: postId)],
      ),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return const Center(
              child: Text('Post not found or has been hidden.'),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Information
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CategoryTag(category: post.category, fontSize: 12),
                          const Spacer(),
                          Text(
                            DateFormat.yMMMd().add_jm().format(post.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          AuthorAvatar(
                            authorName: post.displayAuthor,
                            isAnonymous: post.isAnonymous,
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.displayAuthor,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                'Ward No: ${post.wardNo ?? "-"}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Post Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Linkify(
                    text: post.content,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                    linkStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    onOpen: (link) async {
                      final url = Uri.parse(link.url);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Media Section
                if (post.mediaUrl != null) ...[
                  if (post.mediaType == 'image')
                    GestureDetector(
                      onTap: () {
                        // Future: Implement full screen viewer
                      },
                      child: CachedNetworkImage(
                        imageUrl: post.mediaUrl!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Loading Full Media...',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    )
                  else if (post.mediaType == 'video_10s')
                    Container(
                      height: 300,
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 64,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Video Player Coming Soon...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (post.mediaType == 'youtube')
                    // YouTube preview card
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: ListTile(
                        leading: const Icon(Icons.link, color: Colors.red),
                        title: const Text('External Media Link'),
                        subtitle: Text(post.mediaUrl!),
                      ),
                    ),
                ],

                // Location Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LocationCard(post: post),
                ),

                const SizedBox(height: 80), // Space at bottom
              ],
            ),
          );
        },
        loading: () => const SkeletonPostDetail(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
