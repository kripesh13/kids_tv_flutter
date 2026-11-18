// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentItemModelAdapter extends TypeAdapter<ContentItemModel> {
  @override
  final int typeId = 2;

  @override
  ContentItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContentItemModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      thumbnailUrl: fields[3] as String? ?? '',
      categoryId: fields[4] as String?,
      contentType: fields[5] as ContentType? ?? ContentType.video,
      sourceUrl: fields[6] as String? ?? '',
      durationSeconds: (fields[7] as num?)?.toInt() ?? 0,
      isFeatured: fields[8] as bool? ?? false,
      isVisible: fields[9] as bool? ?? true,
      displayOrder: (fields[10] as num?)?.toInt() ?? 0,
      viewsCount: (fields[11] as num?)?.toInt() ?? 0,
      tags: (fields[12] as List?)?.cast<String>() ?? const [],
      extraMetadata: (fields[13] as Map?)?.cast<String, dynamic>() ?? const {},
      createdAt: fields[14] as DateTime? ?? DateTime.now(),
      updatedAt: fields[15] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, ContentItemModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.contentType)
      ..writeByte(6)
      ..write(obj.sourceUrl)
      ..writeByte(7)
      ..write(obj.durationSeconds)
      ..writeByte(8)
      ..write(obj.isFeatured)
      ..writeByte(9)
      ..write(obj.isVisible)
      ..writeByte(10)
      ..write(obj.displayOrder)
      ..writeByte(11)
      ..write(obj.viewsCount)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.extraMetadata)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
