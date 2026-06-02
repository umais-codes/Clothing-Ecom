import 'package:get/get.dart';
import '../presentation/controllers/vendor_tracking_controller.dart';

class VendorTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorTrackingController>(() => VendorTrackingController());
  }
}
