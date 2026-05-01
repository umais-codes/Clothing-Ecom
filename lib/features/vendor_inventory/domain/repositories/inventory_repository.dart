import 'package:ecom_app/features/vendor_inventory/data/models/vendor_product_model.dart';

abstract class InventoryRepository {
  Future<void> init();
  Future<List<VendorProduct>> getProducts();
  Future<void> saveProduct(VendorProduct product);
  Future<void> deleteProduct(String id);
  Future<VendorProduct?> getDraft();
  Future<void> saveDraft(VendorProduct product);
  Future<void> clearDraft();
}
