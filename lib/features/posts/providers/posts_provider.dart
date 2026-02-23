import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/block_service.dart';
import '../../../core/services/cache_service.dart';

/// Provider for PostService singleton
final postServiceProvider = Provider<PostService>((ref) {
  return PostService.instance;
});

/// Provider for the list of posts (Home Feed)
/// Emits cached posts first, then fresh posts from network
final postsProvider = StreamProvider<List<Post>>((ref) async* {
  final postService = ref.watch(postServiceProvider);

  // 1. Yield cached posts immediately (filtered)
  final cached = postService.getCachedPosts();
  if (cached.isNotEmpty) {
    final blockedIds = ref.read(blockServiceProvider).getBlockedUserIds();
    yield cached.where((p) => 
      !blockedIds.contains(p.userId) && 
      p.reportCount < 5 && 
      !p.isHidden
    ).toList();
  }

  // 2. Fetch fresh posts from network
  try {
  final fresh = await postService.getPosts();
    // Filter fresh posts
    final blockedIds = ref.read(blockServiceProvider).getBlockedUserIds();
    final filteredFresh = fresh.where((p) => 
      !blockedIds.contains(p.userId) && 
      p.reportCount < 5 && 
      !p.isHidden
    ).toList();
    yield filteredFresh;
  } catch (e) {
    // If offline or error, we've already yielded cache
    // debugPrint removed
    if (cached.isEmpty) {
      // Only throw if we have nothing at all
      rethrow;
    }
  }
});

/// Provider for the 'Last Updated' timestamp of the feed
final lastUpdatedProvider = Provider<DateTime?>((ref) {
  // This can be watched to show "Last updated: 2m ago"
  ref.watch(postsProvider); // Re-run when posts update
  return CacheService.instance.getPostsLastUpdated();
});

/// Provider for a single post by ID
final postProvider = FutureProvider.family<Post?, String>((ref, id) async {
  final postService = ref.watch(postServiceProvider);
  return await postService.getPostById(id);
});

/// Provider for admin moderation view
final reportedPostsProvider = FutureProvider<List<Post>>((ref) async {
  final postService = ref.watch(postServiceProvider);
  return await postService.getReportedPosts();
});
