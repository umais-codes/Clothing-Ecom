import 'package:get/get.dart';
import '../controllers/main_navigation_controller.dart';
import '../../../../features/home/presentation/controllers/home_controller.dart';
import '../../../../features/vendor_dashboard/presentation/controllers/vendor_dashboard_controller.dart';
import '../../../../features/b2b_portal/presentation/controllers/b2b_portal_controller.dart';
import '../../../../features/profile/presentation/controllers/profile_controller.dart';
import '../../../../features/vendor_orders/presentation/controllers/vendor_order_controller.dart';
import '../../../../features/vendor_inventory/domain/repositories/inventory_repository.dart';
import '../../../../features/vendor_inventory/data/repositories/inventory_repository_impl.dart';
import '../../../../features/vendor_inventory/presentation/controllers/product_crud_controller.dart';
import '../../../../features/discovery/domain/repositories/discovery_repository.dart';
import '../../../../features/discovery/presentation/controllers/filter_controller.dart';
import '../../../../features/discovery/presentation/controllers/discovery_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<VendorDashboardController>(() => VendorDashboardController(), fenix: true);
    Get.lazyPut<B2BPortalController>(() => B2BPortalController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<VendorOrderController>(() => VendorOrderController(), fenix: true);

    Get.lazyPut<InventoryRepository>(() => InventoryRepositoryImpl()..init(), fenix: true);
    Get.lazyPut<ProductCrudController>(() => ProductCrudController(Get.find()), fenix: true);

    // Discovery Dependencies
    Get.lazyPut<FilterController>(
      () => FilterController(Get.find<DiscoveryRepository>()),
      fenix: true,
    );
    Get.lazyPut<DiscoveryController>(() => DiscoveryController(), fenix: true);
  }
}
