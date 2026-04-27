import 'package:get/get.dart';
import '../controllers/main_navigation_controller.dart';
import '../../../../features/home/presentation/controllers/home_controller.dart';
import '../../../../features/vendor_dashboard/presentation/controllers/dashboard_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
