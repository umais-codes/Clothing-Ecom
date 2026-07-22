import 'package:hive/hive.dart';

part 'product_model.g.dart';

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
  final bool? inStock;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final bool? isB2B;

  // Fields for search & advanced filtering (not stored in Hive to maintain adapter compatibility)
  final String category;
  final List<String> sizes;
  final List<String> colors;
  final int moq;
  final String sourcingType; // e.g. "Ready to Ship" or "Private Label"
  final String location;     // e.g. "Pakistan" or "International"
  final bool isNew;

  Product({
    required this.id,
    required this.name,
    required this.vendorName,
    required this.price,
    required this.imageUrl,
    bool? inStock,
    String? description,
    bool? isB2B,
    this.category = '',
    this.sizes = const [],
    this.colors = const [],
    this.moq = 1,
    this.sourcingType = 'Ready to Ship',
    this.location = 'Pakistan',
    this.isNew = false,
  })  : inStock = inStock ?? true,
        description = description ?? '',
        isB2B = isB2B ?? false;

  factory Product.fromMap(Map<String, dynamic> map) {
    String imgUrl = '';
    if (map['image_url'] != null && map['image_url'].toString().isNotEmpty) {
      imgUrl = map['image_url'].toString();
    } else if (map['images'] is List && (map['images'] as List).isNotEmpty) {
      imgUrl = (map['images'] as List).first.toString();
    } else if (map['image'] != null && map['image'].toString().isNotEmpty) {
      imgUrl = map['image'].toString();
    } else if (map['imageUrl'] != null && map['imageUrl'].toString().isNotEmpty) {
      imgUrl = map['imageUrl'].toString();
    } else {
      imgUrl = 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop';
    }

    final bool isB2bFlag = map['is_b2b'] == true ||
        map['is_b2b'] == 1 ||
        map['is_b2b'] == 'true' ||
        map['isB2B'] == true;

    List<String> sizeList = List<String>.from(map['sizes'] ?? []);
    List<String> colorList = List<String>.from(map['colors'] ?? []);

    if (sizeList.isEmpty && map['variants_json'] is List) {
      sizeList = List<Map<String, dynamic>>.from(map['variants_json'])
          .map((v) => v['size']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
    }

    if (colorList.isEmpty && map['variants_json'] is List) {
      colorList = List<Map<String, dynamic>>.from(map['variants_json'])
          .map((v) => v['color']?.toString() ?? '')
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
    }

    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? map['title'] ?? 'Apparel Product',
      vendorName: map['vendor_name'] ?? map['vendor'] ?? map['vendorName'] ?? 'Boutique Apparel',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: imgUrl,
      inStock: map['in_stock'] ?? map['inStock'] ?? true,
      description: map['description'] ?? '',
      isB2B: isB2bFlag,
      category: map['category'] ?? "Men's",
      sizes: sizeList,
      colors: colorList,
      moq: (map['moq'] as num?)?.toInt() ?? 1,
      sourcingType: map['sourcing_type'] ?? map['sourcingType'] ?? 'Ready to Ship',
      location: map['location'] ?? 'Pakistan',
      isNew: map['is_new'] ?? map['isNew'] ?? false,
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
      'category': category,
      'sizes': sizes,
      'colors': colors,
      'moq': moq,
      'sourcingType': sourcingType,
      'location': location,
      'isNew': isNew,
    };
  }
}
