import 'dart:async';
import 'package:ecom_app/features/vendor_inventory/data/models/product_variant_model.dart';
import 'package:ecom_app/features/vendor_inventory/data/models/vendor_product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'package:get/get.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:flutter/foundation.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  static const String _productsBoxName = 'vendorProductsBox';
  static const String _draftBoxName = 'vendorDraftBox';

  final _initCompleter = Completer<void>();

  @override
  Future<void> init() async {
    if (_initCompleter.isCompleted) return;
    try {
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ProductVariantAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(VendorProductAdapter());
      }
      await Hive.openBox<VendorProduct>(_productsBoxName);
      await Hive.openBox<VendorProduct>(_draftBoxName);
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
    }
  }

  Future<void> _ensureInitialized() async {
    await _initCompleter.future;
  }

  Box<VendorProduct> get _productsBox =>
      Hive.box<VendorProduct>(_productsBoxName);
  Box<VendorProduct> get _draftBox => Hive.box<VendorProduct>(_draftBoxName);

  @override
  Future<List<VendorProduct>> getProducts() async {
    await _ensureInitialized();
    try {
      final supabase = Get.find<SupabaseService>().client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Look up vendor_id
        final profileRes = await supabase.from('profiles').select('vendor_id').eq('id', user.id).maybeSingle();
        String? vendorId;
        if (profileRes != null && profileRes['vendor_id'] != null) {
          vendorId = profileRes['vendor_id'].toString();
        }

        if (vendorId == null) {
          // Check vendors table directly
          final vendorRes = await supabase.from('vendors').select().eq('owner_id', user.id).maybeSingle();
          if (vendorRes != null) {
            vendorId = vendorRes['id'].toString();
          }
        }

        if (vendorId != null) {
          final dbProducts = await supabase.from('products').select().eq('vendor_id', vendorId);
          return (dbProducts as List).map<VendorProduct>((map) {
            final List<String> sizes = List<String>.from(map['sizes'] ?? []);
            final List<String> colors = List<String>.from(map['colors'] ?? []);
            final List<ProductVariant> variantsList = [];
            int varIndex = 0;
            for (var c in colors) {
              for (var s in sizes) {
                variantsList.add(
                  ProductVariant(
                    id: '${map['id']}_v_${varIndex++}',
                    color: c,
                    size: s,
                    stockQuantity: (map['in_stock'] == true) ? 50 : 0,
                    sku: '${map['name'].toString().replaceAll(' ', '').toUpperCase()}-$c-$s',
                  ),
                );
              }
            }

            return VendorProduct(
              id: map['id'].toString(),
              title: map['name'].toString(),
              description: map['description']?.toString() ?? '',
              category: map['category']?.toString() ?? '',
              basePrice: (map['price'] as num?)?.toDouble() ?? 0.0,
              imageUrls: [map['image_url']?.toString() ?? ''],
              variants: variantsList,
              isDraft: false,
              isB2B: map['is_b2b'] ?? false,
              moq: (map['moq'] as num?)?.toInt() ?? 1,
              sourcingType: map['sourcing_type']?.toString() ?? 'Ready to Ship',
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error getting products from Supabase: $e');
    }

    return _productsBox.values.toList();
  }

  @override
  Future<void> saveProduct(VendorProduct product) async {
    await _ensureInitialized();
    try {
      final supabase = Get.find<SupabaseService>().client;
      final user = supabase.auth.currentUser;
      String? vendorId;
      String vendorName = 'Boutique Apparel';

      if (user != null) {
        final profileRes = await supabase.from('profiles').select('vendor_id').eq('id', user.id).maybeSingle();
        if (profileRes != null && profileRes['vendor_id'] != null) {
          vendorId = profileRes['vendor_id'].toString();
        }

        if (vendorId == null) {
          final vendorRes = await supabase.from('vendors').select().eq('owner_id', user.id).maybeSingle();
          if (vendorRes != null) {
            vendorId = vendorRes['id'].toString();
            vendorName = vendorRes['brand_name'] ?? 'Boutique Apparel';
          }
        } else {
          final vendorRes = await supabase.from('vendors').select('brand_name').eq('id', vendorId).maybeSingle();
          if (vendorRes != null && vendorRes['brand_name'] != null) {
            vendorName = vendorRes['brand_name'].toString();
          }
        }
      }

      if (vendorId == null && user != null) {
        // Upsert fallback vendor
        vendorId = user.id;
        try {
          await supabase.from('vendors').upsert({
            'id': vendorId,
            'brand_name': 'Boutique Apparel',
            'owner_id': user.id,
            'kyc_status': 'approved',
          });
        } catch (_) {}
      }

      if (vendorId != null) {
        final totalStock = product.variants.fold<int>(0, (sum, v) => sum + v.stockQuantity);
        await supabase.from('products').upsert({
          'id': product.id,
          'vendor_id': vendorId,
          'name': product.title,
          'vendor_name': vendorName,
          'price': product.basePrice,
          'image_url': product.imageUrls.isNotEmpty 
              ? product.imageUrls.first 
              : 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
          'in_stock': totalStock > 0,
          'description': product.description,
          'is_b2b': product.isB2B,
          'category': product.category,
          'sizes': product.variants.map((v) => v.size).toSet().toList(),
          'colors': product.variants.map((v) => v.color).toSet().toList(),
          'moq': product.moq,
          'sourcing_type': product.sourcingType,
          'location': 'Pakistan',
          'is_new': true,
        });
      }
    } catch (e) {
      debugPrint('Error saving product in Supabase: $e');
    }
    // Also store in Hive for local caching
    await _productsBox.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _ensureInitialized();
    try {
      final supabase = Get.find<SupabaseService>().client;
      await supabase.from('products').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting product in Supabase: $e');
    }
    await _productsBox.delete(id);
  }

  @override
  Future<VendorProduct?> getDraft() async {
    await _ensureInitialized();
    if (_draftBox.isNotEmpty) {
      return _draftBox.values.first;
    }
    return null;
  }

  @override
  Future<void> saveDraft(VendorProduct product) async {
    await _ensureInitialized();
    await _draftBox.put('draft', product);
  }

  @override
  Future<void> clearDraft() async {
    await _ensureInitialized();
    await _draftBox.clear();
  }
}
