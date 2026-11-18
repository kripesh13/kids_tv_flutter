// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchHistoryModelAdapter extends TypeAdapter<WatchHistoryModel> {
  @override
  final int typeId = 8;

  @override
  WatchHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchHistoryModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      contentId: fields[2] as String,
      lastPositionSeconds: (fields[3] as num?)?.toInt() ?? 0,
      totalDurationSeconds: (fields[4] as num?)?.toInt() ?? 0,
      completed: fields[5] as bool? ?? false,
      updatedAt: fields[6] as DateTime? ?? DateTime.now(),
      contentItem: fields[7] as ContentItemModel?,
    );
  }

  @override
  void write(BinaryWriter writer, WatchHistoryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.contentId)
      ..writeByte(3)
      ..write(obj.lastPositionSeconds)
      ..writeByte(4)
      ..write(obj.totalDurationSeconds)
      ..writeByte(5)
      ..write(obj.completed)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.contentItem);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
