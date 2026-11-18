// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_action.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BannerActionAdapter extends TypeAdapter<BannerAction> {
  @override
  final int typeId = 10;

  @override
  BannerAction read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BannerAction.content;
      case 1:
        return BannerAction.category;
      case 2:
        return BannerAction.external;
      case 3:
        return BannerAction.live;
      default:
        return BannerAction.content;
    }
  }

  @override
  void write(BinaryWriter writer, BannerAction obj) {
    switch (obj) {
      case BannerAction.content:
        writer.writeByte(0);
        break;
      case BannerAction.category:
        writer.writeByte(1);
        break;
      case BannerAction.external:
        writer.writeByte(2);
        break;
      case BannerAction.live:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
