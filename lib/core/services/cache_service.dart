import 'package:hive_flutter/hive_flutter.dart';

/// Service to handle local caching using Hive
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  static const String _postsBoxName = 'posts_cache';
  static const String _profileBoxName = 'user_profile_cache';
  static const String _metadataBoxName = 'app_metadata';

  /// Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_postsBoxName);
    await Hive.openBox(_profileBoxName);
    await Hive.openBox(_metadataBoxName);
    // debugPrint removed
  }

  // --- Posts Cache ---

  /// Save list of posts to cache
  Future<void> savePosts(List<Map<String, dynamic>> posts) async {
    final box = Hive.box(_postsBoxName);
    await box.clear();
    await box.put('feed', posts);

    // Update last updated timestamp
    final metadata = Hive.box(_metadataBoxName);
    await metadata.put('last_updated_posts', DateTime.now().toIso8601String());
  }

  /// Get cached posts
  List<Map<String, dynamic>> getCachedPosts() {
    final box = Hive.box(_postsBoxName);
    final data = box.get('feed');
    if (data == null || data is! List) return [];

    // Safely convert each item to Map<String, dynamic>
    return data.map((item) {
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }
      return <String, dynamic>{};
    }).toList();
  }

  /// Get last updated timestamp for posts
  DateTime? getPostsLastUpdated() {
    final metadata = Hive.box(_metadataBoxName);
    final timestamp = metadata.get('last_updated_posts');
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  // --- Profile Cache ---

  /// Save user profile to cache
  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final box = Hive.box(_profileBoxName);
    await box.put('current_user', profile);
  }

  /// Get cached user profile
  Map<String, dynamic>? getCachedProfile() {
    final box = Hive.box(_profileBoxName);
    final data = box.get('current_user');
    if (data == null || data is! Map) return null;
    return Map<String, dynamic>.from(data);
  }

  // --- General ---

  /// Clear all cache (useful for logout)
  Future<void> clearCache() async {
    await Hive.box(_postsBoxName).clear();
    await Hive.box(_profileBoxName).clear();
    await Hive.box(_metadataBoxName).clear();
  }
}
