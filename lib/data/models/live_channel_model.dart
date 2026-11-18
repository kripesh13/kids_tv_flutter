import 'package:hive/hive.dart';

part 'live_channel_model.g.dart';

@HiveType(typeId: 4)
class LiveChannelModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String streamUrl;

  @HiveField(3)
  final String? webStreamUrl;

  @HiveField(4)
  final String logoUrl;

  @HiveField(5)
  final String? channelNumber;

  @HiveField(6)
  final String? categoryId;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final int displayOrder;

  @HiveField(9)
  final String? currentProgram;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  const LiveChannelModel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.webStreamUrl,
    required this.logoUrl,
    this.channelNumber,
    this.categoryId,
    this.isActive = true,
    this.displayOrder = 0,
    this.currentProgram,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveChannelModel.fromJson(Map<String, dynamic> json) {
    return LiveChannelModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      streamUrl: json['stream_url'] as String? ?? '',
      webStreamUrl: json['web_stream_url'] as String?,
      logoUrl: json['logo_url'] as String? ?? '',
      channelNumber: json['channel_number']?.toString(),
      categoryId: json['category_id']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      currentProgram: json['current_program'] as String?,
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
      'stream_url': streamUrl,
      'web_stream_url': webStreamUrl,
      'logo_url': logoUrl,
      'channel_number': channelNumber,
      'category_id': categoryId,
      'is_active': isActive,
      'display_order': displayOrder,
      'current_program': currentProgram,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LiveChannelModel copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? webStreamUrl,
    String? logoUrl,
    String? channelNumber,
    String? categoryId,
    bool? isActive,
    int? displayOrder,
    String? currentProgram,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LiveChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      webStreamUrl: webStreamUrl ?? this.webStreamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      channelNumber: channelNumber ?? this.channelNumber,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      currentProgram: currentProgram ?? this.currentProgram,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
