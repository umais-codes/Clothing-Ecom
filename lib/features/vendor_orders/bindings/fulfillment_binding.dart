import 'package:get/get.dart';
import '../presentation/controllers/fulfillment_controller.dart';
import '../domain/entities/vendor_order.dart';

class FulfillmentBinding extends Bindings {
  @override
  void dependencies() {
    final VendorOrder order = Get.arguments as VendorOrder;
    Get.lazyPut<FulfillmentController>(() => FulfillmentController(order: order));
  }
}
