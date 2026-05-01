// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VendorProductAdapter extends TypeAdapter<VendorProduct> {
  @override
  final int typeId = 3;

  @override
  VendorProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VendorProduct(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      basePrice: fields[4] as double,
      discountPrice: fields[5] as double?,
      variants: (fields[6] as List).cast<ProductVariant>(),
      imageUrls: (fields[7] as List).cast<String>(),
      isDraft: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VendorProduct obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.basePrice)
      ..writeByte(5)
      ..write(obj.discountPrice)
      ..writeByte(6)
      ..write(obj.variants)
      ..writeByte(7)
      ..write(obj.imageUrls)
      ..writeByte(8)
      ..write(obj.isDraft);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
