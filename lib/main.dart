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
import 'package:ecom_app/features/cart/presentation/controllers/b2c_cart_controller.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2b_cart_controller.dart';
import 'package:ecom_app/features/cart/presentation/screens/b2c_cart_screen.dart';
import 'package:ecom_app/features/cart/presentation/screens/b2b_cart_screen.dart';
import 'package:ecom_app/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:ecom_app/features/navigation/presentation/bindings/main_navigation_binding.dart';
import 'package:ecom_app/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:ecom_app/features/profile/bindings/profile_binding.dart';
import 'package:ecom_app/features/profile/presentation/views/profile_view.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:ecom_app/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:ecom_app/features/vendor_inventory/bindings/vendor_inventory_binding.dart'
    as ecom_inventory_binding;
import 'package:ecom_app/features/vendor_inventory/presentation/views/inventory_view.dart'
    as ecom_inventory;
import 'package:ecom_app/features/super_admin/bindings/admin_binding.dart';
import 'package:ecom_app/features/super_admin/presentation/screens/admin_main_layout.dart';
import 'package:ecom_app/features/super_admin/presentation/screens/admin_login_screen.dart';
import 'package:ecom_app/app/middleware/admin_guard.dart';
import 'package:ecom_app/features/vendor_dashboard/presentation/views/subscription_plans_view.dart';
import 'package:ecom_app/features/super_admin/presentation/screens/subscription_plan_builder_screen.dart';
import 'package:ecom_app/features/splash/bindings/splash_binding.dart';
import 'package:ecom_app/features/splash/presentation/views/splash_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/vendor_orders_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/vendor_orders_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/fulfillment_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/packing_checklist_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/tracking_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/customer_tracking_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/vendor_tracking_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/vendor_tracking_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/dispatch_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/admin_dispatch_view.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/post_purchase/bindings/post_purchase_binding.dart';
import 'package:ecom_app/features/post_purchase/presentation/views/rma_request_view.dart';
import 'package:ecom_app/features/checkout/bindings/checkout_binding.dart';
import 'package:ecom_app/features/checkout/presentation/views/checkout_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => SupabaseService().init());

  final cartRepo = CartRepository();
  await cartRepo.init();

  Get.put(B2CCartController(cartRepo), permanent: true);
  Get.put(B2BCartController(cartRepo), permanent: true);
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
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
          binding: SplashBinding(),
          transition: Transition.fadeIn,
        ),
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
          page: () => const B2CCartScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/b2b-cart',
          page: () => const B2BCartScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/checkout',
          page: () => const CheckoutView(),
          binding: CheckoutBinding(),
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
        GetPage(
          name: '/vendor-inventory',
          page: () => const ecom_inventory.InventoryView(),
          binding: ecom_inventory_binding.VendorInventoryBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/admin-login',
          page: () => const AdminLoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/vendor-plans',
          page: () => const SubscriptionPlansView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/vendor-orders',
          page: () => const VendorOrdersView(),
          binding: VendorOrdersBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/fulfillment-checklist',
          page: () => const PackingChecklistView(),
          binding: FulfillmentBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/admin-subscription-builder',
          page: () => const SubscriptionPlanBuilderScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/admin-panel',
          page: () => const AdminMainLayout(),
          binding: AdminBinding(),
          middlewares: [AdminGuard()],
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/customer-tracking',
          page: () => const CustomerTrackingView(),
          binding: TrackingBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/rma-request',
          page: () => const RmaRequestView(),
          binding: PostPurchaseBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/vendor-tracking',
          page: () => const VendorTrackingView(),
          binding: VendorTrackingBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/admin-dispatch',
          page: () => const AdminDispatchView(),
          binding: DispatchBinding(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
