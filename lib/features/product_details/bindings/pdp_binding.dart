import 'package:get/get.dart';
import '../presentation/controllers/pdp_controller.dart';

class PdpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdpController>(() => PdpController());
  }
}
