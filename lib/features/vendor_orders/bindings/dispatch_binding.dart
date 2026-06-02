import 'package:get/get.dart';
import '../presentation/controllers/dispatch_controller.dart';

class DispatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DispatchController>(() => DispatchController());
  }
}
