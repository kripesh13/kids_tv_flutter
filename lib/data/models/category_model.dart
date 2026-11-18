import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String slug;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String iconName;

  @HiveField(5)
  final String? thumbnailUrl;

  @HiveField(6)
  final String colorHex;

  @HiveField(7)
  final int displayOrder;

  @HiveField(8)
  final bool isFeatured;

  @HiveField(9)
  final bool isVisible;

  @HiveField(10)
  final bool requiresLogin;

  @HiveField(11)
  final bool allowFavorites;

  @HiveField(12)
  final bool allowSharing;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconName = 'category',
    this.thumbnailUrl,
    this.colorHex = '#6657E8',
    this.displayOrder = 0,
    this.isFeatured = false,
    this.isVisible = true,
    this.requiresLogin = false,
    this.allowFavorites = true,
    this.allowSharing = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      }
    } catch (_) {}
    return const Color(0xFF6657E8);
  }

  IconData get icon {
    switch (iconName.toLowerCase()) {
      case 'music_note':
        return Icons.music_note_rounded;
      case 'queue_music':
        return Icons.queue_music_rounded;
      case 'cruelty_free':
      case 'pets':
        return Icons.cruelty_free_rounded;
      case 'sports_soccer':
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'school':
      case 'education':
        return Icons.school_rounded;
      case 'auto_stories':
      case 'book':
        return Icons.auto_stories_rounded;
      case 'live_tv':
      case 'tv':
        return Icons.live_tv_rounded;
      case 'smart_display':
      case 'youtube':
        return Icons.smart_display_rounded;
      case 'movie':
      case 'film':
        return Icons.movie_filter_rounded;
      case 'theater_comedy':
      case 'entertainment':
        return Icons.theater_comedy_rounded;
      case 'explore':
      case 'more':
        return Icons.explore_rounded;
      case 'star':
        return Icons.star_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? (json['name'] as String? ?? '').toLowerCase().replaceAll(' ', '-'),
      description: json['description'] as String?,
      iconName: json['icon_name'] as String? ?? 'category',
      thumbnailUrl: json['thumbnail_url'] as String?,
      colorHex: json['color_hex'] as String? ?? '#6657E8',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isVisible: json['is_visible'] as bool? ?? true,
      requiresLogin: json['requires_login'] as bool? ?? false,
      allowFavorites: json['allow_favorites'] as bool? ?? true,
      allowSharing: json['allow_sharing'] as bool? ?? true,
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
      'name': name,
      'slug': slug,
      'description': description,
      'icon_name': iconName,
      'thumbnail_url': thumbnailUrl,
      'color_hex': colorHex,
      'display_order': displayOrder,
      'is_featured': isFeatured,
      'is_visible': isVisible,
      'requires_login': requiresLogin,
      'allow_favorites': allowFavorites,
      'allow_sharing': allowSharing,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? iconName,
    String? thumbnailUrl,
    String? colorHex,
    int? displayOrder,
    bool? isFeatured,
    bool? isVisible,
    bool? requiresLogin,
    bool? allowFavorites,
    bool? allowSharing,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      colorHex: colorHex ?? this.colorHex,
      displayOrder: displayOrder ?? this.displayOrder,
      isFeatured: isFeatured ?? this.isFeatured,
      isVisible: isVisible ?? this.isVisible,
      requiresLogin: requiresLogin ?? this.requiresLogin,
      allowFavorites: allowFavorites ?? this.allowFavorites,
      allowSharing: allowSharing ?? this.allowSharing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
