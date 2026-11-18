import 'package:hive/hive.dart';
import '../../domain/enums/content_type.dart';

part 'content_item_model.g.dart';

@HiveType(typeId: 2)
class ContentItemModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String thumbnailUrl;

  @HiveField(4)
  final String? categoryId;

  @HiveField(5)
  final ContentType contentType;

  @HiveField(6)
  final String sourceUrl;

  @HiveField(7)
  final int durationSeconds;

  @HiveField(8)
  final bool isFeatured;

  @HiveField(9)
  final bool isVisible;

  @HiveField(10)
  final int displayOrder;

  @HiveField(11)
  final int viewsCount;

  @HiveField(12)
  final List<String> tags;

  @HiveField(13)
  final Map<String, dynamic> extraMetadata;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  const ContentItemModel({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    this.categoryId,
    this.contentType = ContentType.video,
    required this.sourceUrl,
    this.durationSeconds = 0,
    this.isFeatured = false,
    this.isVisible = true,
    this.displayOrder = 0,
    this.viewsCount = 0,
    this.tags = const [],
    this.extraMetadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isYouTube =>
      contentType == ContentType.youtubeVideo ||
      contentType == ContentType.youtubeChannel ||
      sourceUrl.contains('youtube.com') ||
      sourceUrl.contains('youtu.be');

  bool get isLive =>
      contentType == ContentType.liveStream || sourceUrl.endsWith('.m3u8');

  String get formattedDuration {
    if (durationSeconds <= 0) return isLive ? 'LIVE' : '';
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remMinutes = minutes % 60;
      return '$hours:${remMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    return ContentItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      categoryId: json['category_id']?.toString(),
      contentType: ContentType.fromString(json['content_type'] as String?),
      sourceUrl: json['source_url'] as String? ?? '',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isVisible: json['is_visible'] as bool? ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      extraMetadata: json['extra_metadata'] is Map<String, dynamic>
          ? json['extra_metadata'] as Map<String, dynamic>
          : const {},
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'category_id': categoryId,
      'content_type': contentType.value,
      'source_url': sourceUrl,
      'duration_seconds': durationSeconds,
      'is_featured': isFeatured,
      'is_visible': isVisible,
      'display_order': displayOrder,
      'views_count': viewsCount,
      'tags': tags,
      'extra_metadata': extraMetadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ContentItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? categoryId,
    ContentType? contentType,
    String? sourceUrl,
    int? durationSeconds,
    bool? isFeatured,
    bool? isVisible,
    int? displayOrder,
    int? viewsCount,
    List<String>? tags,
    Map<String, dynamic>? extraMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categoryId: categoryId ?? this.categoryId,
      contentType: contentType ?? this.contentType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isFeatured: isFeatured ?? this.isFeatured,
      isVisible: isVisible ?? this.isVisible,
      displayOrder: displayOrder ?? this.displayOrder,
      viewsCount: viewsCount ?? this.viewsCount,
      tags: tags ?? this.tags,
      extraMetadata: extraMetadata ?? this.extraMetadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
