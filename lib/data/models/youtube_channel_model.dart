import 'package:hive/hive.dart';

part 'youtube_channel_model.g.dart';

@HiveType(typeId: 5)
class YoutubeChannelModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String channelId;

  @HiveField(3)
  final String channelUrl;

  @HiveField(4)
  final String thumbnailUrl;

  @HiveField(5)
  final String? subscriberCount;

  @HiveField(6)
  final int videoCount;

  @HiveField(7)
  final bool isFeatured;

  @HiveField(8)
  final int displayOrder;

  @HiveField(9)
  final DateTime createdAt;

  const YoutubeChannelModel({
    required this.id,
    required this.title,
    required this.channelId,
    required this.channelUrl,
    required this.thumbnailUrl,
    this.subscriberCount,
    this.videoCount = 0,
    this.isFeatured = false,
    this.displayOrder = 0,
    required this.createdAt,
  });

  factory YoutubeChannelModel.fromJson(Map<String, dynamic> json) {
    return YoutubeChannelModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      channelId: json['channel_id'] as String? ?? '',
      channelUrl: json['channel_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      subscriberCount: json['subscriber_count'] as String?,
      videoCount: (json['video_count'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channel_id': channelId,
      'channel_url': channelUrl,
      'thumbnail_url': thumbnailUrl,
      'subscriber_count': subscriberCount,
      'video_count': videoCount,
      'is_featured': isFeatured,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
