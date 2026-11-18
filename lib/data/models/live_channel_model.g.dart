// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_channel_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiveChannelModelAdapter extends TypeAdapter<LiveChannelModel> {
  @override
  final int typeId = 4;

  @override
  LiveChannelModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveChannelModel(
      id: fields[0] as String,
      name: fields[1] as String,
      streamUrl: fields[2] as String? ?? '',
      webStreamUrl: fields[3] as String?,
      logoUrl: fields[4] as String? ?? '',
      channelNumber: fields[5] as String?,
      categoryId: fields[6] as String?,
      isActive: fields[7] as bool? ?? true,
      displayOrder: (fields[8] as num?)?.toInt() ?? 0,
      currentProgram: fields[9] as String?,
      createdAt: fields[10] as DateTime? ?? DateTime.now(),
      updatedAt: fields[11] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, LiveChannelModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.streamUrl)
      ..writeByte(3)
      ..write(obj.webStreamUrl)
      ..writeByte(4)
      ..write(obj.logoUrl)
      ..writeByte(5)
      ..write(obj.channelNumber)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.displayOrder)
      ..writeByte(9)
      ..write(obj.currentProgram)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveChannelModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
