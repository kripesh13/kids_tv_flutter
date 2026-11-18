// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_permission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeaturePermissionModelAdapter extends TypeAdapter<FeaturePermissionModel> {
  @override
  final int typeId = 7;

  @override
  FeaturePermissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeaturePermissionModel(
      featureKey: fields[0] as String,
      requiresLogin: fields[1] as bool? ?? false,
      description: fields[2] as String?,
      updatedAt: fields[3] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, FeaturePermissionModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.featureKey)
      ..writeByte(1)
      ..write(obj.requiresLogin)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeaturePermissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
