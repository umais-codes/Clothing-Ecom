import 'package:get/get.dart';
import '../presentation/controllers/fulfillment_controller.dart';
import '../domain/entities/vendor_order.dart';

class FulfillmentBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final VendorOrder order = args is VendorOrder
        ? args
        : VendorOrder(
            id: args is Map ? (args['id']?.toString() ?? '#ORD-0000') : (args?.toString() ?? '#ORD-0000'),
            customerName: args is Map ? (args['customerName']?.toString() ?? 'Customer') : 'Customer',
            amount: args is Map ? ((args['amount'] as num?)?.toDouble() ?? 0.0) : 0.0,
            status: 'Processing',
            orderDate: DateTime.now(),
            isB2B: false,
            items: [],
            timeline: [],
          );
    Get.put<FulfillmentController>(FulfillmentController(order: order));
  }
}
