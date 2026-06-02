import 'package:get/get.dart';
import '../presentation/controllers/vendor_order_controller.dart';

class VendorOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorOrderController>(() => VendorOrderController());
  }
}
