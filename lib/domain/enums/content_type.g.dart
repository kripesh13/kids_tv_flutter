// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentTypeAdapter extends TypeAdapter<ContentType> {
  @override
  final int typeId = 9;

  @override
  ContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ContentType.video;
      case 1:
        return ContentType.externalUrl;
      case 2:
        return ContentType.youtubeVideo;
      case 3:
        return ContentType.youtubeChannel;
      case 4:
        return ContentType.liveStream;
      case 5:
        return ContentType.websiteLink;
      case 6:
        return ContentType.playlist;
      case 7:
        return ContentType.custom;
      default:
        return ContentType.video;
    }
  }

  @override
  void write(BinaryWriter writer, ContentType obj) {
    switch (obj) {
      case ContentType.video:
        writer.writeByte(0);
        break;
      case ContentType.externalUrl:
        writer.writeByte(1);
        break;
      case ContentType.youtubeVideo:
        writer.writeByte(2);
        break;
      case ContentType.youtubeChannel:
        writer.writeByte(3);
        break;
      case ContentType.liveStream:
        writer.writeByte(4);
        break;
      case ContentType.websiteLink:
        writer.writeByte(5);
        break;
      case ContentType.playlist:
        writer.writeByte(6);
        break;
      case ContentType.custom:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
