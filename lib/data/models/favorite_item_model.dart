import 'package:hive/hive.dart';
import 'content_item_model.dart';

part 'favorite_item_model.g.dart';

@HiveType(typeId: 12)
class FavoriteItemModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String contentId;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final ContentItemModel? contentItem;

  const FavoriteItemModel({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.createdAt,
    this.contentItem,
  });

  factory FavoriteItemModel.fromJson(Map<String, dynamic> json, {ContentItemModel? content}) {
    return FavoriteItemModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      contentId: json['content_id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      contentItem: content ??
          (json['content_items'] != null
              ? ContentItemModel.fromJson(json['content_items'] as Map<String, dynamic>)
              : (json['content_item'] != null
                  ? ContentItemModel.fromJson(json['content_item'] as Map<String, dynamic>)
                  : null)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content_id': contentId,
      'created_at': createdAt.toIso8601String(),
      if (contentItem != null) 'content_item': contentItem!.toJson(),
    };
  }
}
