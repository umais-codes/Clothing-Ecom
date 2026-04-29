import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_theme.dart';
import 'package:ecom_app/features/home/bindings/home_binding.dart';
import 'package:ecom_app/features/home/presentation/views/home_view.dart';
import 'package:ecom_app/features/onboarding/bindings/onboarding_binding.dart';
import 'package:ecom_app/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:ecom_app/features/product_details/bindings/pdp_binding.dart';
import 'package:ecom_app/features/product_details/presentation/views/pdp_view.dart';
import 'package:ecom_app/features/vendor_dashboard/bindings/vendor_dashboard_binding.dart';
import 'package:ecom_app/features/vendor_dashboard/presentation/views/vendor_dashboard_view.dart';
import 'package:ecom_app/features/b2b_portal/bindings/b2b_portal_binding.dart';
import 'package:ecom_app/features/b2b_portal/presentation/views/b2b_portal_view.dart';
import 'package:ecom_app/features/cart/data/repositories/cart_repository.dart';
import 'package:ecom_app/features/cart/presentation/controllers/cart_controller.dart';
import 'package:ecom_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:ecom_app/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:ecom_app/features/navigation/presentation/bindings/main_navigation_binding.dart';
import 'package:ecom_app/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:ecom_app/features/profile/bindings/profile_binding.dart';
import 'package:ecom_app/features/profile/presentation/views/profile_view.dart';
import 'package:ecom_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ecom_app/features/wishlist/presentation/screens/wishlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cartRepo = CartRepository();
  await cartRepo.init();

  Get.put(CartController(cartRepo), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const EcomApp());
}

class EcomApp extends StatelessWidget {
  const EcomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Premium Apparel E-commerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/onboarding',
      getPages: [
        GetPage(
          name: '/main-navigation',
          page: () => const MainNavigationScreen(),
          binding: MainNavigationBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingView(),
          binding: OnboardingBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          binding: HomeBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/product-details',
          page: () => const PdpView(),
          binding: PdpBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/vendor-dashboard',
          page: () => const VendorDashboardView(),
          binding: VendorDashboardBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/b2b-portal',
          page: () => const B2BPortalView(),
          binding: B2BPortalBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/discovery',
          page: () => DiscoveryScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/cart',
          page: () => const CartScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileView(),
          binding: ProfileBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/wishlist',
          page: () => const WishlistScreen(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
