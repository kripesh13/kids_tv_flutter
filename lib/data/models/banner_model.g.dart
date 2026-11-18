// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BannerModelAdapter extends TypeAdapter<BannerModel> {
  @override
  final int typeId = 3;

  @override
  BannerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BannerModel(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String?,
      imageUrl: fields[3] as String? ?? '',
      actionType: fields[4] as BannerAction? ?? BannerAction.content,
      actionTarget: fields[5] as String? ?? '',
      displayOrder: (fields[6] as num?)?.toInt() ?? 0,
      isActive: fields[7] as bool? ?? true,
      createdAt: fields[8] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, BannerModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.actionType)
      ..writeByte(5)
      ..write(obj.actionTarget)
      ..writeByte(6)
      ..write(obj.displayOrder)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
