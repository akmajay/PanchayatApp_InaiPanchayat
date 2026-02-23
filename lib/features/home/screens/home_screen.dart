import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/router/routes.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/loading_skeletons.dart';
import '../../../shared/widgets/error_view.dart';
import '../../posts/providers/posts_provider.dart';
import '../../posts/widgets/post_card.dart';

/// Home screen showing the live feed of grievances
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize FCM subscription logic
    ref.watch(fcmSubscriptionProvider);

    final postsAsync = ref.watch(postsProvider);
    final lastUpdated = ref.watch(lastUpdatedProvider);

    return AppShell(
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(postsProvider.future),
        child: Column(
          children: [
            // Status Banner (Offline/Last Updated)
            _StatusBanner(
              lastUpdated: lastUpdated,
              isError: postsAsync.hasError,
            ),

            Expanded(
              child: postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return _EmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(
                          milliseconds: 100 * (index % 5),
                        ), // Staggered delay for first few
                        child: PostCard(
                          post: post,
                          onTap: () => context.push(
                            AppRoutes.postDetail.replaceFirst(':id', post.id),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: 5,
                  itemBuilder: (context, index) => const SkeletonFeedCard(),
                ),
                error: (err, stack) => ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.refresh(postsProvider.future),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final DateTime? lastUpdated;
  final bool isError;

  const _StatusBanner({required this.lastUpdated, required this.isError});

  @override
  Widget build(BuildContext context) {
    if (lastUpdated == null && !isError) return const SizedBox.shrink();

    final timeStr = lastUpdated != null
        ? DateFormat('hh:mm a').format(lastUpdated!)
        : 'कभी नहीं';

    return Container(
      width: double.infinity,
      color: isError ? Colors.orange.shade100 : Colors.green.shade50,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.cloud_off : Icons.check_circle_outline,
                size: 14,
                color: isError ? Colors.orange.shade800 : Colors.green.shade800,
              ),
              const SizedBox(width: 8),
              Text(
                isError ? 'ऑफलाइन मोड (Offline)' : 'अपडेटेड (Updated)',
                style: TextStyle(
                  fontSize: 12,
                  color: isError
                      ? Colors.orange.shade800
                      : Colors.green.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            'पिछला अपडेट: $timeStr',
            style: TextStyle(
              fontSize: 11,
              color: isError ? Colors.orange.shade900 : Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_edu, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'कोई शिकायत नहीं है',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'अपने पंचायत की समस्याओं को यहाँ साझा करें।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Private widgets moved to shared directory as SkeletonCard and ErrorView
