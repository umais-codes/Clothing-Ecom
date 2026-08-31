import 'package:get/get.dart';
import 'package:ecom_app/app/routes/app_routes.dart';

// Feature Views & Screen Imports
import 'package:ecom_app/features/splash/bindings/splash_binding.dart';
import 'package:ecom_app/features/splash/presentation/views/splash_view.dart';
import 'package:ecom_app/features/navigation/presentation/bindings/main_navigation_binding.dart';
import 'package:ecom_app/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:ecom_app/features/onboarding/bindings/onboarding_binding.dart';
import 'package:ecom_app/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:ecom_app/features/home/bindings/home_binding.dart';
import 'package:ecom_app/features/home/presentation/views/home_view.dart';
import 'package:ecom_app/features/product_details/bindings/pdp_binding.dart';
import 'package:ecom_app/features/product_details/presentation/views/pdp_view.dart';
import 'package:ecom_app/features/vendor_dashboard/bindings/vendor_dashboard_binding.dart';
import 'package:ecom_app/features/vendor_dashboard/presentation/views/vendor_dashboard_view.dart';
import 'package:ecom_app/features/b2b_portal/bindings/b2b_portal_binding.dart';
import 'package:ecom_app/features/b2b_portal/presentation/views/b2b_portal_view.dart';
import 'package:ecom_app/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:ecom_app/features/cart/presentation/screens/b2c_cart_screen.dart';
import 'package:ecom_app/features/cart/presentation/screens/b2b_cart_screen.dart';
import 'package:ecom_app/features/checkout/bindings/checkout_binding.dart';
import 'package:ecom_app/features/checkout/presentation/views/checkout_view.dart';
import 'package:ecom_app/features/profile/bindings/profile_binding.dart';
import 'package:ecom_app/features/profile/presentation/views/profile_view.dart';
import 'package:ecom_app/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:ecom_app/features/vendor_inventory/bindings/vendor_inventory_binding.dart'
    as ecom_inventory_binding;
import 'package:ecom_app/features/vendor_inventory/presentation/views/inventory_view.dart'
    as ecom_inventory;
import 'package:ecom_app/features/super_admin/presentation/screens/admin_login_screen.dart';
import 'package:ecom_app/features/vendor_dashboard/presentation/views/subscription_plans_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/vendor_orders_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/vendor_orders_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/fulfillment_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/packing_checklist_view.dart';
import 'package:ecom_app/features/super_admin/presentation/screens/subscription_plan_builder_screen.dart';
import 'package:ecom_app/features/super_admin/bindings/admin_binding.dart';
import 'package:ecom_app/features/super_admin/presentation/screens/admin_main_layout.dart';
import 'package:ecom_app/app/middleware/admin_guard.dart';
import 'package:ecom_app/features/vendor_orders/bindings/tracking_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/customer_tracking_view.dart';
import 'package:ecom_app/features/post_purchase/bindings/post_purchase_binding.dart';
import 'package:ecom_app/features/post_purchase/presentation/views/rma_request_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/vendor_tracking_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/vendor_tracking_view.dart';
import 'package:ecom_app/features/vendor_orders/bindings/dispatch_binding.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/admin_dispatch_view.dart';

import 'package:ecom_app/app/middleware/auth_guard.dart';
import 'package:ecom_app/app/middleware/vendor_guard.dart';
import 'package:ecom_app/app/middleware/corporate_guard.dart';

abstract class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.mainNavigation,
      page: () => const MainNavigationScreen(),
      binding: MainNavigationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const PdpView(),
      binding: PdpBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorDashboard,
      page: () => const VendorDashboardView(),
      binding: VendorDashboardBinding(),
      middlewares: [AuthGuard(), VendorGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.b2bPortal,
      page: () => const B2BPortalView(),
      binding: B2BPortalBinding(),
      middlewares: [AuthGuard(), CorporateGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.discovery,
      page: () => DiscoveryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const B2CCartScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.b2bCart,
      page: () => const B2BCartScreen(),
      middlewares: [AuthGuard(), CorporateGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorInventory,
      page: () => const ecom_inventory.InventoryView(),
      binding: ecom_inventory_binding.VendorInventoryBinding(),
      middlewares: [AuthGuard(), VendorGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminLogin,
      page: () => const AdminLoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.vendorPlans,
      page: () => const SubscriptionPlansView(),
      middlewares: [AuthGuard(), VendorGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorOrders,
      page: () => const VendorOrdersView(),
      binding: VendorOrdersBinding(),
      middlewares: [AuthGuard(), VendorGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.fulfillmentChecklist,
      page: () => const PackingChecklistView(),
      binding: FulfillmentBinding(),
      middlewares: [AuthGuard(), VendorGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminSubscriptionBuilder,
      page: () => const SubscriptionPlanBuilderScreen(),
      middlewares: [AuthGuard(), AdminGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminPanel,
      page: () => const AdminMainLayout(),
      binding: AdminBinding(),
      middlewares: [AuthGuard(), AdminGuard()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.customerTracking,
      page: () => const CustomerTrackingView(),
      binding: TrackingBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.rmaRequest,
      page: () => const RmaRequestView(),
      binding: PostPurchaseBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorTracking,
      page: () => const VendorTrackingView(),
      binding: VendorTrackingBinding(),
      middlewares: [AuthGuard(), VendorGuard()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminDispatch,
      page: () => const AdminDispatchView(),
      binding: DispatchBinding(),
      middlewares: [AuthGuard(), AdminGuard()],
      transition: Transition.rightToLeft,
    ),
  ];
}
