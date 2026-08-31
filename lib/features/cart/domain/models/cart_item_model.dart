import 'package:hive/hive.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 0)
class CartItem {
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
  int quantity;

  @HiveField(6)
  final bool isB2B;

  @HiveField(7)
  final String? size;

  @HiveField(8)
  final String? color;

  @HiveField(9)
  final bool isAiSizeMatched;

  CartItem({
    required this.id,
    required this.name,
    required this.vendorName,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.isB2B = false,
    this.size,
    this.color,
    this.isAiSizeMatched = false,
  });

  CartItem copyWith({
    String? id,
    String? name,
    String? vendorName,
    double? price,
    String? imageUrl,
    int? quantity,
    bool? isB2B,
    String? size,
    String? color,
    bool? isAiSizeMatched,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      vendorName: vendorName ?? this.vendorName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      isB2B: isB2B ?? this.isB2B,
      size: size ?? this.size,
      color: color ?? this.color,
      isAiSizeMatched: isAiSizeMatched ?? this.isAiSizeMatched,
    );
  }

  String get baseProductId {
    final parts = id.split('_');
    if (parts.length >= 3) {
      // If formatted as {productId}_{size}_{color}
      return parts.sublist(0, parts.length - 2).join('_');
    } else if (parts.length == 2 && (parts[1] == 'S' || parts[1] == 'M' || parts[1] == 'L' || parts[1] == 'XL' || parts[1] == 'XXL')) {
      return parts[0];
    }
    return id;
  }

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': baseProductId,
      'name': name,
      'vendor_name': vendorName,
      'price': price,
      'image_url': imageUrl,
      'quantity': quantity,
      'is_b2b': isB2B,
      'size': size,
      'color': color,
      'is_ai_size_matched': isAiSizeMatched,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? map['product_name'] ?? 'Product',
      vendorName: map['vendor_name'] ?? map['vendor'] ?? 'Brand Vendor',
      price: (map['price'] ?? map['unit_price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] ?? map['image'] ?? 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      isB2B: map['is_b2b'] == true || map['is_b2b'] == 1 || map['isB2B'] == true,
      size: map['size']?.toString(),
      color: map['color']?.toString(),
      isAiSizeMatched: map['is_ai_size_matched'] == true || map['isAiSizeMatched'] == true,
    );
  }
}
