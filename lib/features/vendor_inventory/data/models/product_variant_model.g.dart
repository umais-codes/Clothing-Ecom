// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductVariantAdapter extends TypeAdapter<ProductVariant> {
  @override
  final int typeId = 2;

  @override
  ProductVariant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductVariant(
      id: fields[0] as String,
      color: fields[1] as String,
      size: fields[2] as String,
      stockQuantity: fields[3] as int,
      sku: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductVariant obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.stockQuantity)
      ..writeByte(4)
      ..write(obj.sku);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
