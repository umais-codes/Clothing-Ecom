import 'package:get/get.dart';
import '../presentation/controllers/vendor_dashboard_controller.dart';

class VendorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorDashboardController>(() => VendorDashboardController());
  }
}
