import 'package:ecom_app/features/vendor_inventory/data/models/product_variant_model.dart';
import 'package:ecom_app/features/vendor_inventory/data/models/vendor_product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  static const String _productsBoxName = 'vendorProductsBox';
  static const String _draftBoxName = 'vendorDraftBox';

  @override
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(ProductVariantAdapter().typeId)) {
      Hive.registerAdapter(ProductVariantAdapter());
    }
    if (!Hive.isAdapterRegistered(VendorProductAdapter().typeId)) {
      Hive.registerAdapter(VendorProductAdapter());
    }
    await Hive.openBox<VendorProduct>(_productsBoxName);
    await Hive.openBox<VendorProduct>(_draftBoxName);
  }

  Box<VendorProduct> get _productsBox =>
      Hive.box<VendorProduct>(_productsBoxName);
  Box<VendorProduct> get _draftBox => Hive.box<VendorProduct>(_draftBoxName);

  @override
  Future<List<VendorProduct>> getProducts() async {
    return _productsBox.values.toList();
  }

  @override
  Future<void> saveProduct(VendorProduct product) async {
    await _productsBox.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _productsBox.delete(id);
  }

  @override
  Future<VendorProduct?> getDraft() async {
    if (_draftBox.isNotEmpty) {
      return _draftBox.values.first;
    }
    return null;
  }

  @override
  Future<void> saveDraft(VendorProduct product) async {
    await _draftBox.put('draft', product);
  }

  @override
  Future<void> clearDraft() async {
    await _draftBox.clear();
  }
}
