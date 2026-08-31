import '../../domain/repositories/discovery_repository.dart';
import '../../../vendor_inventory/data/models/product_variant_model.dart';
import '../../../wishlist/domain/models/product_model.dart';
import '../../../vendor_inventory/data/models/vendor_product_model.dart';
import '../../../super_admin/presentation/controllers/admin_crud_controller.dart';
import '../../../super_admin/domain/entities/admin_entities.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:flutter/material.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

  @override
  Future<List<Product>> getProducts({required bool isB2B}) async {
    final List<Product> publishedProducts = [];

    // 1. Fetch live products from Supabase
    try {
      final response = await _supabase.from('products').select();

      if (response.isNotEmpty) {
        for (var map in response) {
          final bool pIsB2B = map['is_b2b'] == true ||
              map['is_b2b'] == 1 ||
              map['is_b2b'] == 'true' ||
              map['isB2B'] == true;
          final String status = (map['status'] ?? 'approved').toString().toLowerCase();
          if (pIsB2B == isB2B && (status == 'approved' || status.isEmpty)) {
            publishedProducts.insert(0, Product.fromMap(map));
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching products from Supabase: $e');
    }

    // 2. Fetch admin created / approved products from active AdminCrudController state
    try {
      if (Get.isRegistered<AdminCrudController>()) {
        final adminCrud = Get.find<AdminCrudController>();
        for (var ap in adminCrud.allProducts) {
          if (ap.status == ProductStatus.approved &&
              !publishedProducts.any((p) => p.id == ap.id)) {
            publishedProducts.insert(
              0,
              Product(
                id: ap.id,
                name: ap.name,
                vendorName: ap.vendorName,
                price: ap.price,
                imageUrl: ap.imageUrl.isNotEmpty
                    ? ap.imageUrl
                    : 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
                inStock: true,
                description: ap.description,
                isB2B: false,
                category: ap.category,
                sizes: ap.sizes.isNotEmpty ? ap.sizes : const ['S', 'M', 'L'],
                colors: const ['Camel', 'Ink', 'White'],
                moq: 1,
                sourcingType: 'Ready to Ship',
                location: 'Pakistan',
                isNew: true,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error merging admin products: $e');
    }

    // 3. Fetch local vendor products from Hive box as fallback/merge
    try {
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ProductVariantAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(VendorProductAdapter());
      }

      Box<VendorProduct> box;
      try {
        if (!Hive.isBoxOpen('vendorProductsBox')) {
          box = await Hive.openBox<VendorProduct>('vendorProductsBox');
        } else {
          box = Hive.box<VendorProduct>('vendorProductsBox');
        }
      } catch (boxErr) {
        debugPrint('Recovering corrupted vendorProductsBox: $boxErr');
        await Hive.deleteBoxFromDisk('vendorProductsBox');
        box = await Hive.openBox<VendorProduct>('vendorProductsBox');
      }

      for (var vp in box.values) {
        if (vp.isB2B == isB2B && !vp.isDraft) {
          final alreadyAdded = publishedProducts.any((p) => p.id == vp.id);
          if (!alreadyAdded) {
            final String primaryImg = vp.imageUrls.isNotEmpty
                ? vp.imageUrls.first
                : 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop';
            publishedProducts.insert(
              0,
              Product(
                id: vp.id,
                name: vp.title,
                vendorName: 'Boutique Apparel',
                price: vp.basePrice,
                imageUrl: primaryImg,
                inStock: vp.variants.isEmpty
                    ? true
                    : vp.variants.any((v) => v.stockQuantity > 0),
                description: vp.description,
                isB2B: vp.isB2B,
                category: vp.category,
                sizes: vp.variants.map((v) => v.size).toSet().toList(),
                colors: vp.variants.map((v) => v.color).toSet().toList(),
                moq: vp.moq,
                sourcingType: vp.sourcingType,
                location: 'Pakistan',
                isNew: true,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading local vendor products: $e');
    }

    // 4. Combine published vendor products (at the top) with mock catalog items
    final mockList = isB2B ? _mockB2BProducts : _mockB2CProducts;
    final Set<String> existingIds = publishedProducts.map((p) => p.id).toSet();
    final remainingMocks = mockList.where((p) => !existingIds.contains(p.id)).toList();

    return [...publishedProducts, ...remainingMocks];
  }

  // --- Mock B2C Shopper Products ---
  final List<Product> _mockB2CProducts = [
    Product(
      id: 'b2c_1',
      name: 'Tailored Linen Blazer',
      vendorName: 'Couture House',
      price: 120.0,
      imageUrl: 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
      inStock: true,
      description: 'An elegant linen blazer cut for a relaxed yet refined silhouette. Ideal for upscale summer wear.',
      isB2B: false,
      category: "Women's",
      sizes: ['S', 'M', 'L'],
      colors: ['Camel', 'Beige', 'White'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: true,
    ),
    Product(
      id: 'b2c_2',
      name: 'Premium Silk Abaya',
      vendorName: 'Al-Karam Luxury',
      price: 180.0,
      imageUrl: 'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Crafted from pure silk, featuring detailed hand embroidery and a flowing, timeless design.',
      isB2B: false,
      category: 'Modest Wear',
      sizes: ['M', 'L', 'XL'],
      colors: ['Black', 'Navy'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: false,
    ),
    Product(
      id: 'b2c_3',
      name: 'Tailored Cotton Chinos',
      vendorName: 'Outfitters Premium',
      price: 85.0,
      imageUrl: 'https://images.unsplash.com/photo-1479064555552-3ef4979f8908?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Classic fit cotton chinos. Structured waist with a touch of stretch for day-to-long-night comfort.',
      isB2B: false,
      category: "Men's",
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Beige', 'Black', 'Navy'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: false,
    ),
    Product(
      id: 'b2c_4',
      name: 'Classic White Linen Shirt',
      vendorName: 'Royal Fabrics',
      price: 75.0,
      imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Breathable linen spun from top-grade flax. Styled with a sharp band collar.',
      isB2B: false,
      category: "Men's",
      sizes: ['M', 'L', 'XL'],
      colors: ['White', 'Beige'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'International',
      isNew: true,
    ),
    Product(
      id: 'b2c_5',
      name: 'Organic Cotton Kids Set',
      vendorName: 'Tiny Threads',
      price: 45.0,
      imageUrl: 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Hypoallergenic organic cotton knit set. Extremely gentle on skin, and durable enough for daily play.',
      isB2B: false,
      category: 'Kidswear',
      sizes: ['S', 'M'],
      colors: ['Camel', 'Beige', 'White'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'International',
      isNew: false,
    ),
    Product(
      id: 'b2c_6',
      name: 'Embroidered Modest Kurta',
      vendorName: 'Ethnic Wear',
      price: 95.0,
      imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Finely spun cotton blend kurta featuring intricate thread embroidery around the neckline.',
      isB2B: false,
      category: 'Modest Wear',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Navy', 'White', 'Black'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: true,
    ),
    Product(
      id: 'b2c_7',
      name: 'Heavyweight Oversized Hoodie',
      vendorName: 'Urban Apparel',
      price: 90.0,
      imageUrl: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600&h=600&fit=crop',
      inStock: true,
      description: '450GSM loopback cotton hoodie. Premium structure, brushed interior, and dropped shoulders.',
      isB2B: false,
      category: "Men's",
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Black', 'White', 'Camel'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: false,
    ),
    Product(
      id: 'b2c_8',
      name: 'Minimalist Ribbed Knit Dress',
      vendorName: 'Couture House',
      price: 110.0,
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&h=600&fit=crop',
      inStock: true,
      description: 'A sleek midi-dress made from organic ribbed knit wool. Flattering slim fit with stretch.',
      isB2B: false,
      category: "Women's",
      sizes: ['S', 'M', 'L'],
      colors: ['Beige', 'Camel', 'Black'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'International',
      isNew: false,
    ),
    Product(
      id: 'b2c_9',
      name: 'Premium Cashmere Scarf',
      vendorName: 'Kashmir Loom',
      price: 150.0,
      imageUrl: 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Extremely soft, hand-woven premium cashmere scarf. Warm and lightweight, the perfect luxury accessory.',
      isB2B: false,
      category: 'Accessories',
      sizes: ['M'],
      colors: ['Camel', 'Beige', 'Black'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'International',
      isNew: true,
    ),
    Product(
      id: 'b2c_10',
      name: 'Handcrafted Leather Belt',
      vendorName: 'Leather Works',
      price: 65.0,
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Full-grain vegetable-tanned leather belt with a solid brass buckle. Crafted to last a lifetime.',
      isB2B: false,
      category: 'Accessories',
      sizes: ['S', 'M', 'L'],
      colors: ['Black', 'Camel'],
      moq: 1,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: false,
    ),
  ];

  // --- Mock B2B Corporate Sourcing Products ---
  final List<Product> _mockB2BProducts = [
    Product(
      id: 'b2b_1',
      name: 'Bulk Cotton Uniform Polos',
      vendorName: 'National Apparel Group',
      price: 12.50,
      imageUrl: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Pique knit bulk polo shirts. Perfect for corporate branding, corporate wear, and employee apparel.',
      isB2B: true,
      category: 'Workwear',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Navy', 'White', 'Black'],
      moq: 100,
      sourcingType: 'Private Label',
      location: 'Pakistan',
      isNew: true,
    ),
    Product(
      id: 'b2b_2',
      name: 'Premium Canvas Tote Bags (Batch)',
      vendorName: 'Indus Bags & Packaging',
      price: 2.80,
      imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Heavy canvas tote bags. Custom design and screen printing available for corporate gifts and events.',
      isB2B: true,
      category: 'Workwear',
      sizes: ['M', 'L'],
      colors: ['Beige', 'White'],
      moq: 500,
      sourcingType: 'Private Label',
      location: 'Pakistan',
      isNew: false,
    ),
    Product(
      id: 'b2b_3',
      name: 'Bulk Medical Scrubs Set',
      vendorName: 'MediWeave Textiles',
      price: 18.00,
      imageUrl: 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Professional anti-microbial medical scrubs. Breathable, stretch-infused fabric for long shifts.',
      isB2B: true,
      category: 'Workwear',
      sizes: ['S', 'M', 'L'],
      colors: ['Navy', 'Black'],
      moq: 50,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: true,
    ),
    Product(
      id: 'b2b_4',
      name: 'Custom Embroidered Hoodies',
      vendorName: 'StitchCraft Faisalabad',
      price: 24.50,
      imageUrl: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Corporate hoodies featuring high-density custom embroidery. Warm fleece lining.',
      isB2B: true,
      category: "Men's",
      sizes: ['M', 'L', 'XL'],
      colors: ['Black', 'Navy', 'Camel'],
      moq: 30,
      sourcingType: 'Private Label',
      location: 'Pakistan',
      isNew: false,
    ),
    Product(
      id: 'b2b_5',
      name: 'Wholesale Linen Shirts (Batch)',
      vendorName: 'Karachi Textiles Ltd',
      price: 14.90,
      imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Premium linen shirts for private brands. Sold in mixed sizing packs.',
      isB2B: true,
      category: "Men's",
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['White', 'Beige', 'Camel'],
      moq: 100,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: false,
    ),
    Product(
      id: 'b2b_6',
      name: 'Organic Kidswear Sets (Wholesale)',
      vendorName: 'Istanbul Kidswear Factory',
      price: 9.80,
      imageUrl: 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Wholesale organic cotton baby clothing batches. Certified chemical-free materials.',
      isB2B: true,
      category: 'Kidswear',
      sizes: ['S', 'M'],
      colors: ['Beige', 'Camel', 'White'],
      moq: 200,
      sourcingType: 'Private Label',
      location: 'International',
      isNew: true,
    ),
    Product(
      id: 'b2b_7',
      name: 'Bulk Genuine Leather Jackets',
      vendorName: 'Sialkot Leather Craft',
      price: 65.00,
      imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Wholesale genuine cowhide leather jackets. Rugged and premium finish.',
      isB2B: true,
      category: "Men's",
      sizes: ['M', 'L', 'XL'],
      colors: ['Black', 'Camel'],
      moq: 20,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: false,
    ),
    Product(
      id: 'b2b_8',
      name: 'Modest Abayas Wholesale Pack',
      vendorName: 'Dubai Modest Manufacturing',
      price: 22.00,
      imageUrl: 'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Universal crepe abayas for boutique resellers. Crease-resistant material.',
      isB2B: true,
      category: 'Modest Wear',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Black', 'Navy'],
      moq: 40,
      sourcingType: 'Ready to Ship',
      location: 'International',
      isNew: false,
    ),
    Product(
      id: 'b2b_9',
      name: 'Corporate Leather Wallets (Bulk)',
      vendorName: 'Sialkot Leather Craft',
      price: 12.00,
      imageUrl: 'https://images.unsplash.com/photo-1627124118123-2654b5f9336e?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Premium top-grain leather wallets. Logo embossing available. Ideal for corporate gifts.',
      isB2B: true,
      category: 'Accessories',
      sizes: ['M'],
      colors: ['Black', 'Camel'],
      moq: 100,
      sourcingType: 'Private Label',
      location: 'Pakistan',
      isNew: true,
    ),
    Product(
      id: 'b2b_10',
      name: 'Silk Tie & Pocket Square Sets',
      vendorName: 'Karachi Textiles Ltd',
      price: 7.50,
      imageUrl: 'https://images.unsplash.com/photo-1589756823695-278bc923f962?w=600&h=600&fit=crop',
      inStock: true,
      description: 'Premium silk ties with matching pocket squares in presentation boxes. Perfect for uniforms or corporate branding.',
      isB2B: true,
      category: 'Accessories',
      sizes: ['M'],
      colors: ['Navy', 'Black'],
      moq: 50,
      sourcingType: 'Ready to Ship',
      location: 'Pakistan',
      isNew: false,
    ),
  ];
}
