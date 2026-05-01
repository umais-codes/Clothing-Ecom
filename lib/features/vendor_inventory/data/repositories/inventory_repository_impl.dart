import 'dart:async';
import 'package:ecom_app/features/vendor_inventory/data/models/product_variant_model.dart';
import 'package:ecom_app/features/vendor_inventory/data/models/vendor_product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/inventory_repository.dart';

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
    return _productsBox.values.toList();
  }

  @override
  Future<void> saveProduct(VendorProduct product) async {
    await _ensureInitialized();
    await _productsBox.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _ensureInitialized();
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
