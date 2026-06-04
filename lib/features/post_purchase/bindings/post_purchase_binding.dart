import 'package:get/get.dart';
import '../presentation/controllers/rma_controller.dart';
import '../presentation/controllers/review_controller.dart';

class PostPurchaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RmaController>(() => RmaController());
    Get.lazyPut<ReviewController>(() => ReviewController());
  }
}
