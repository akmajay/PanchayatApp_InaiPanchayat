/// Post model representing a grievance/complaint
class Post {
  final String id;
  final String userId;
  final String content;
  final String? mediaUrl;
  final String mediaType;
  final String category;
  final bool isAnonymous;
  final int? wardNo;
  final double? latitude;
  final double? longitude;
  final int reportCount;
  final bool isHidden;
  final DateTime createdAt;

  /// Joined from profiles table
  final String? authorName;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.mediaUrl,
    required this.mediaType,
    required this.category,
    required this.isAnonymous,
    this.wardNo,
    this.latitude,
    this.longitude,
    required this.reportCount,
    required this.isHidden,
    required this.createdAt,
    this.authorName,
  });

  /// Factory to local current display name
  String get displayAuthor =>
      isAnonymous ? 'गुप्त नागरिक' : (authorName ?? 'Unknown User');

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String? ?? 'text',
      category: json['category'] as String? ?? 'other',
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      wardNo: json['ward_no'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      reportCount: json['report_count'] as int? ?? 0,
      isHidden: json['is_hidden'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      // Check for nested profile if joined
      authorName: (json['profiles'] is Map)
          ? (Map<String, dynamic>.from(json['profiles'] as Map))['full_name']
                as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'category': category,
      'is_anonymous': isAnonymous,
      'ward_no': wardNo,
      'latitude': latitude,
      'longitude': longitude,
      'report_count': reportCount,
      'is_hidden': isHidden,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
