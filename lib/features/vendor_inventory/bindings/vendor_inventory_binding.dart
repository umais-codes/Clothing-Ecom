import 'package:get/get.dart';
import '../domain/repositories/inventory_repository.dart';
import '../data/repositories/inventory_repository_impl.dart';
import '../presentation/controllers/product_crud_controller.dart';

class VendorInventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryRepository>(() => InventoryRepositoryImpl()..init());
    Get.lazyPut<ProductCrudController>(() => ProductCrudController(Get.find()));
  }
}
