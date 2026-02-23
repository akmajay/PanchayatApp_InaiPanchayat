import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../posts/models/post_model.dart';

/// A card for administrators to review reported or hidden content
class ReportedPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onDismiss;
  final VoidCallback onDelete;
  final VoidCallback onBan;

  const ReportedPostCard({
    super.key,
    required this.post,
    required this.onDismiss,
    required this.onDelete,
    required this.onBan,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM, hh:mm a').format(post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Report Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: post.isHidden
                  ? Colors.red.shade100
                  : Colors.orange.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      post.isHidden
                          ? Icons.visibility_off
                          : Icons.report_problem,
                      size: 16,
                      color: post.isHidden
                          ? Colors.red.shade800
                          : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.isHidden
                          ? 'आभासी रूप से छिपा हुआ (Auto-Hidden)'
                          : '${post.reportCount} रिपोर्ट (Reports)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: post.isHidden
                            ? Colors.red.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author & Category
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        (post.authorName ?? 'G')[0],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.authorName ?? 'गुप्त नागरिक',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Content
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Admin Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Dismiss Action
                TextButton.icon(
                  onPressed: onDismiss,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Colors.green,
                  ),
                  label: const Text(
                    'Dismiss',
                    style: TextStyle(color: Colors.green),
                  ),
                ),

                // Ban Action
                TextButton.icon(
                  onPressed: onBan,
                  icon: const Icon(
                    Icons.person_off_outlined,
                    size: 20,
                    color: Colors.orange,
                  ),
                  label: const Text(
                    'Ban User',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),

                // Delete Action
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_forever_outlined,
                    size: 20,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
