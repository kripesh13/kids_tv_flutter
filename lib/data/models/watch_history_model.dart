import 'package:hive/hive.dart';
import 'content_item_model.dart';

part 'watch_history_model.g.dart';

@HiveType(typeId: 8)
class WatchHistoryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String contentId;

  @HiveField(3)
  final int lastPositionSeconds;

  @HiveField(4)
  final int totalDurationSeconds;

  @HiveField(5)
  final bool completed;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final ContentItemModel? contentItem;

  const WatchHistoryModel({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.lastPositionSeconds,
    required this.totalDurationSeconds,
    this.completed = false,
    required this.updatedAt,
    this.contentItem,
  });

  double get progressPercentage {
    if (totalDurationSeconds <= 0) return 0.0;
    final p = lastPositionSeconds / totalDurationSeconds;
    return p.clamp(0.0, 1.0);
  }

  WatchHistoryModel copyWith({
    String? id,
    String? userId,
    String? contentId,
    int? lastPositionSeconds,
    int? totalDurationSeconds,
    bool? completed,
    DateTime? updatedAt,
    ContentItemModel? contentItem,
  }) {
    return WatchHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      lastPositionSeconds: lastPositionSeconds ?? this.lastPositionSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      contentItem: contentItem ?? this.contentItem,
    );
  }

  factory WatchHistoryModel.fromJson(Map<String, dynamic> json, {ContentItemModel? content}) {
    final nestedContent = json['content_item'] != null && json['content_item'] is Map<String, dynamic>
        ? ContentItemModel.fromJson(json['content_item'] as Map<String, dynamic>)
        : (json['content_items'] != null && json['content_items'] is Map<String, dynamic>
            ? ContentItemModel.fromJson(json['content_items'] as Map<String, dynamic>)
            : content);

    return WatchHistoryModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      contentId: json['content_id']?.toString() ?? '',
      lastPositionSeconds: (json['last_position_seconds'] as num?)?.toInt() ?? 0,
      totalDurationSeconds: (json['total_duration_seconds'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      contentItem: nestedContent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content_id': contentId,
      'last_position_seconds': lastPositionSeconds,
      'total_duration_seconds': totalDurationSeconds,
      'completed': completed,
      'updated_at': updatedAt.toIso8601String(),
      if (contentItem != null) 'content_item': contentItem!.toJson(),
    };
  }
}
