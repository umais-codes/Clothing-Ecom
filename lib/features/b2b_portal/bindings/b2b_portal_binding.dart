import 'package:get/get.dart';
import '../presentation/controllers/b2b_portal_controller.dart';

class B2BPortalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<B2BPortalController>(() => B2BPortalController());
  }
}
