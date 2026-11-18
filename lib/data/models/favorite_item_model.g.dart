// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteItemModelAdapter extends TypeAdapter<FavoriteItemModel> {
  @override
  final int typeId = 12;

  @override
  FavoriteItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteItemModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      contentId: fields[2] as String,
      createdAt: fields[3] as DateTime? ?? DateTime.now(),
      contentItem: fields[4] as ContentItemModel?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteItemModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.contentId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.contentItem);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
