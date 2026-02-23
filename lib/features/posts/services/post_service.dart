import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/supabase_client.dart';
import '../../../core/services/cache_service.dart';
import '../models/post_model.dart';
import 'storage_service.dart';

/// Service for post-related operations
class PostService {
  PostService._();
  static final PostService instance = PostService._();

  final _storage = StorageService.instance;
  final _cache = CacheService.instance;

  /// Fetch posts with pagination and author name join
  Future<List<Post>> getPosts({int limit = 15, int offset = 0}) async {
    try {
      final response = await supabase
          .from('posts')
          .select(
            'id, user_id, content, media_url, media_type, category, is_anonymous, '
            'ward_no, latitude, longitude, report_count, is_hidden, created_at, '
            'profiles(full_name)',
          )
          .eq('is_hidden', false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> data = response as List<dynamic>;
      final posts = data.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        return Post.fromJson(map);
      }).toList();

      // Update cache on success (first page only for simplicity)
      if (offset == 0) {
        final cacheData = data
            .map((json) => Map<String, dynamic>.from(json as Map))
            .toList();
        await _cache.savePosts(cacheData);
      }

      return posts;
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Get locally cached posts
  List<Post> getCachedPosts() {
    final cachedData = _cache.getCachedPosts();
    return cachedData.map((json) => Post.fromJson(json)).toList();
  }

  /// Get single post by ID
  Future<Post?> getPostById(String id) async {
    try {
      final json = await supabase
          .from('posts')
          .select(
            'id, user_id, content, media_url, media_type, category, is_anonymous, '
            'ward_no, latitude, longitude, report_count, is_hidden, created_at, '
            'profiles(full_name)',
          )
          .eq('id', id)
          .maybeSingle();

      if (json == null) return null;
      return Post.fromJson(json);
    } catch (e) {
      // debugPrint removed
      return null;
    }
  }

  /// Create a new post with optional media upload
  Future<bool> createPost(Post post, {XFile? mediaFile}) async {
    try {
      String? uploadedUrl;

      // 1. If media exists, upload to Storage
      if (mediaFile != null) {
        final userId = post.userId;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = mediaFile.path.split('.').last;
        final filename =
            '${timestamp}_${const Uuid().v4().substring(0, 8)}.$extension';
        final path = '$userId/$filename';

        // Choose bucket based on media type
        final bucket = post.mediaType == 'image'
            ? 'permanent_images'
            : 'temp_videos';

        // debugPrint removed
        uploadedUrl = await _storage.uploadFile(
          bucket: bucket,
          path: path,
          file: mediaFile,
        );
      }

      // 2. Insert into database with the correct URL
      final postWithUrl = Post(
        id: post.id,
        userId: post.userId,
        content: post.content,
        mediaUrl: uploadedUrl ?? post.mediaUrl,
        mediaType: post.mediaType,
        category: post.category,
        isAnonymous: post.isAnonymous,
        wardNo: post.wardNo,
        latitude: post.latitude,
        longitude: post.longitude,
        reportCount: post.reportCount,
        isHidden: post.isHidden,
        createdAt: post.createdAt,
      );

      await supabase.from('posts').insert(postWithUrl.toJson());

      return true;
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Report a post (increments count and auto-hides if >= 5)
  Future<void> reportPost(String postId) async {
    try {
      // Call the RPC function defined in migration 004
      await supabase.rpc('report_post', params: {'p_id': postId});
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Admin: Fetch posts that have reports or are hidden
  Future<List<Post>> getReportedPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select(
            'id, user_id, content, media_url, media_type, category, is_anonymous, '
            'ward_no, latitude, longitude, report_count, is_hidden, created_at, '
            'profiles(full_name)',
          )
          .or('report_count.gt.0,is_hidden.eq.true')
          .order('report_count', ascending: false);

      return (response as List).map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Admin: Resolve a report (Dismiss or Delete)
  Future<void> resolveReport(
    String postId, {
    required bool shouldDelete,
  }) async {
    try {
      if (shouldDelete) {
        // First get the post to find media path
        final post = await getPostById(postId);
        if (post != null && post.mediaUrl != null) {
          // Parse bucket and path from URL
          // Format: .../storage/v1/object/public/[bucket]/[path]
          final uri = Uri.parse(post.mediaUrl!);
          final segments = uri.pathSegments;
          final bucketIndex = segments.indexOf('public') + 1;

          if (bucketIndex > 0 && bucketIndex < segments.length) {
            final bucket = segments[bucketIndex];
            final path = segments.sublist(bucketIndex + 1).join('/');
            await _storage.deleteFile(bucket: bucket, path: path);
          }
        }
        // Then delete from DB
        await supabase.from('posts').delete().eq('id', postId);
      } else {
        // Dismiss: Reset reports and unhide
        await supabase
            .from('posts')
            .update({'report_count': 0, 'is_hidden': false})
            .eq('id', postId);
      }
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Admin: Ban a user (mark is_banned in profile)
  Future<void> banUser(String userId) async {
    try {
      await supabase
          .from('profiles')
          .update({'is_banned': true})
          .eq('id', userId);
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// User: Fetch own posts (including hidden/reported ones)
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final response = await supabase
          .from('posts')
          .select(
            'id, user_id, content, media_url, media_type, category, is_anonymous, '
            'ward_no, latitude, longitude, report_count, is_hidden, created_at, '
            'profiles(full_name)',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// User-facing delete: Delete own post and its media
  Future<void> deletePost(String postId) async {
    try {
      final post = await getPostById(postId);
      if (post != null) {
        // Enforce ownership check via RLS, but also delete media first
        if (post.mediaUrl != null) {
          final uri = Uri.parse(post.mediaUrl!);
          final segments = uri.pathSegments;
          final bucketIndex = segments.indexOf('public') + 1;

          if (bucketIndex > 0 && bucketIndex < segments.length) {
            final bucket = segments[bucketIndex];
            final path = segments.sublist(bucketIndex + 1).join('/');
            await _storage.deleteFile(bucket: bucket, path: path);
          }
        }
        // Then delete from DB
        await supabase.from('posts').delete().eq('id', postId);
      }
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }

  /// Update post content and category
  Future<void> updatePost(
    String postId, {
    required String content,
    required String category,
  }) async {
    try {
      await supabase
          .from('posts')
          .update({
            'content': content.trim(),
            'category': category.toLowerCase().trim(),
          })
          .eq('id', postId);
    } catch (e) {
      // debugPrint removed
      rethrow;
    }
  }
}
