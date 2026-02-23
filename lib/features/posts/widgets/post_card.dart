import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import 'post_actions_menu.dart';
import '../../../shared/widgets/category_tag.dart';
import '../../../shared/widgets/author_avatar.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable card to display a single post
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relativeTime = _formatRelativeTime(post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Author + Ward
              Row(
                children: [
                  AuthorAvatar(
                    authorName: post.displayAuthor,
                    isAnonymous: post.isAnonymous,
                    radius: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.displayAuthor,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.isAnonymous) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.visibility_off_outlined,
                                size: 14,
                                color: theme.colorScheme.outline,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          'Ward ${post.wardNo ?? "-"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category Chip
                  CategoryTag(category: post.category),
                  PostActionsMenu(post: post),
                ],
              ),
              const SizedBox(height: 12),

              // Content
              Linkify(
                text: post.content,
                style: theme.textTheme.bodyLarge,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
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

              // Media Preview Placeholder
              if (post.mediaUrl != null) ...[
                const SizedBox(height: 12),
                _MediaPreview(
                  mediaType: post.mediaType,
                  mediaUrl: post.mediaUrl!,
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Time + Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    relativeTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.reportCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return DateFormat.yMMMd().format(dateTime);
  }
}

class _MediaPreview extends StatelessWidget {
  final String mediaType;
  final String mediaUrl;

  const _MediaPreview({required this.mediaType, required this.mediaUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    String label;

    switch (mediaType) {
      case 'image':
        icon = Icons.image_outlined;
        label = '📸 फ़ोटो संलग्न है (Photo Attached)';
        break;
      case 'video_10s':
        icon = Icons.play_circle_outline;
        label = '🎥 वीडियो संलग्न है (Video Attached)';
        break;
      case 'youtube':
        icon = Icons.play_circle_fill;
        label = '📺 YouTube वीडियो (YouTube Video)';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
