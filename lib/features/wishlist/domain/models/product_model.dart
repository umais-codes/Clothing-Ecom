import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String vendorName;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final bool inStock;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final bool isB2B;

  Product({
    required this.id,
    required this.name,
    required this.vendorName,
    required this.price,
    required this.imageUrl,
    this.inStock = true,
    this.description = '',
    this.isB2B = false,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      vendorName: map['vendor'] ?? (map['vendorName'] ?? 'Boutique Apparel'),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image'] ?? (map['imageUrl'] ?? ''),
      inStock: map['inStock'] ?? true,
      description: map['description'] ?? '',
      isB2B: map['isB2B'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vendor': vendorName,
      'price': price,
      'image': imageUrl,
      'inStock': inStock,
      'description': description,
      'isB2B': isB2B,
    };
  }
}
