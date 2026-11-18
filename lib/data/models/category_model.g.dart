// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      slug: fields[2] as String,
      description: fields[3] as String?,
      iconName: fields[4] as String? ?? 'category',
      thumbnailUrl: fields[5] as String?,
      colorHex: fields[6] as String? ?? '#6657E8',
      displayOrder: (fields[7] as num?)?.toInt() ?? 0,
      isFeatured: fields[8] as bool? ?? false,
      isVisible: fields[9] as bool? ?? true,
      requiresLogin: fields[10] as bool? ?? false,
      allowFavorites: fields[11] as bool? ?? true,
      allowSharing: fields[12] as bool? ?? true,
      createdAt: fields[13] as DateTime? ?? DateTime.now(),
      updatedAt: fields[14] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.iconName)
      ..writeByte(5)
      ..write(obj.thumbnailUrl)
      ..writeByte(6)
      ..write(obj.colorHex)
      ..writeByte(7)
      ..write(obj.displayOrder)
      ..writeByte(8)
      ..write(obj.isFeatured)
      ..writeByte(9)
      ..write(obj.isVisible)
      ..writeByte(10)
      ..write(obj.requiresLogin)
      ..writeByte(11)
      ..write(obj.allowFavorites)
      ..writeByte(12)
      ..write(obj.allowSharing)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
