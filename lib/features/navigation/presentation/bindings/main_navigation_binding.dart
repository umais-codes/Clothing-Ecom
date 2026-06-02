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
import '../../../../features/discovery/data/repositories/discovery_repository_impl.dart';
import '../../../../features/discovery/presentation/controllers/filter_controller.dart';
import '../../../../features/discovery/presentation/controllers/discovery_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<VendorDashboardController>(() => VendorDashboardController());
    Get.lazyPut<B2BPortalController>(() => B2BPortalController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<VendorOrderController>(() => VendorOrderController());

    Get.lazyPut<InventoryRepository>(() => InventoryRepositoryImpl()..init());
    Get.lazyPut<ProductCrudController>(() => ProductCrudController(Get.find()));

    // Discovery Dependencies
    Get.lazyPut<DiscoveryRepository>(() => DiscoveryRepositoryImpl());
    Get.lazyPut<FilterController>(
      () => FilterController(Get.find<DiscoveryRepository>()),
    );
    Get.lazyPut<DiscoveryController>(() => DiscoveryController());
  }
}
