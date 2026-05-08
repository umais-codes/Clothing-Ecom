import 'package:get/get.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController(), fenix: true);
  }
}
