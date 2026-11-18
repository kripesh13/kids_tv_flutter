// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_channel_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YoutubeChannelModelAdapter extends TypeAdapter<YoutubeChannelModel> {
  @override
  final int typeId = 5;

  @override
  YoutubeChannelModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YoutubeChannelModel(
      id: fields[0] as String,
      title: fields[1] as String,
      channelId: fields[2] as String,
      channelUrl: fields[3] as String? ?? '',
      thumbnailUrl: fields[4] as String? ?? '',
      subscriberCount: fields[5] as String?,
      videoCount: (fields[6] as num?)?.toInt() ?? 0,
      isFeatured: fields[8] as bool? ?? false,
      displayOrder: (fields[9] as num?)?.toInt() ?? 0,
      createdAt: fields[10] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, YoutubeChannelModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.channelId)
      ..writeByte(3)
      ..write(obj.channelUrl)
      ..writeByte(4)
      ..write(obj.thumbnailUrl)
      ..writeByte(5)
      ..write(obj.subscriberCount)
      ..writeByte(6)
      ..write(obj.videoCount)
      ..writeByte(8)
      ..write(obj.isFeatured)
      ..writeByte(9)
      ..write(obj.displayOrder)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YoutubeChannelModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
