import 'package:hive/hive.dart';
import 'product_variant_model.dart';

part 'vendor_product_model.g.dart';

@HiveType(typeId: 3)
class VendorProduct {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final double basePrice;

  @HiveField(5)
  final double? discountPrice;

  @HiveField(6)
  final List<ProductVariant> variants;

  @HiveField(7)
  final List<String> imageUrls;

  @HiveField(8)
  final bool isDraft;

  // Non-Hive fields for Supabase mapping
  final bool isB2B;
  final int moq;
  final String sourcingType;

  VendorProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.basePrice,
    this.discountPrice,
    required this.variants,
    required this.imageUrls,
    required this.isDraft,
    this.isB2B = false,
    this.moq = 1,
    this.sourcingType = 'Ready to Ship',
  });

  VendorProduct copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? basePrice,
    double? discountPrice,
    List<ProductVariant>? variants,
    List<String>? imageUrls,
    bool? isDraft,
    bool? isB2B,
    int? moq,
    String? sourcingType,
  }) {
    return VendorProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      discountPrice: discountPrice ?? this.discountPrice,
      variants: variants ?? this.variants,
      imageUrls: imageUrls ?? this.imageUrls,
      isDraft: isDraft ?? this.isDraft,
      isB2B: isB2B ?? this.isB2B,
      moq: moq ?? this.moq,
      sourcingType: sourcingType ?? this.sourcingType,
    );
  }
}
