import 'package:hive/hive.dart';
part 'product_variant_model.g.dart';

@HiveType(typeId: 2)
class ProductVariant {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String color;

  @HiveField(2)
  final String size;

  @HiveField(3)
  final int stockQuantity;

  @HiveField(4)
  final String sku;

  ProductVariant({
    required this.id,
    required this.color,
    required this.size,
    required this.stockQuantity,
    required this.sku,
  });

  ProductVariant copyWith({
    String? id,
    String? color,
    String? size,
    int? stockQuantity,
    String? sku,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      color: color ?? this.color,
      size: size ?? this.size,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      sku: sku ?? this.sku,
    );
  }
}
