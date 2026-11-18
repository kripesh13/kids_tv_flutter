class PlaylistModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final bool isFeatured;
  final bool isVisible;
  final int displayOrder;
  final DateTime createdAt;

  const PlaylistModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.isFeatured = false,
    this.isVisible = true,
    this.displayOrder = 0,
    required this.createdAt,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      isVisible: json['is_visible'] as bool? ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'is_featured': isFeatured,
      'is_visible': isVisible,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
