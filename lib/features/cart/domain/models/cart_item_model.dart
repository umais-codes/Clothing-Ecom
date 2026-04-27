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
}
