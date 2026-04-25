import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_theme.dart';
import 'package:ecom_app/features/home/bindings/home_binding.dart';
import 'package:ecom_app/features/home/presentation/views/home_view.dart';
import 'package:ecom_app/features/onboarding/bindings/onboarding_binding.dart';
import 'package:ecom_app/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:ecom_app/features/product_details/bindings/pdp_binding.dart';
import 'package:ecom_app/features/product_details/presentation/views/pdp_view.dart';
import 'package:ecom_app/features/vendor_dashboard/bindings/dashboard_binding.dart';
import 'package:ecom_app/features/vendor_dashboard/presentation/views/dashboard_view.dart';

void main() {
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
          name: '/onboarding',
          page: () => const OnboardingView(),
          binding: OnboardingBinding(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          binding: HomeBinding(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/product-details',
          page: () => const PdpView(),
          binding: PdpBinding(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/vendor-dashboard',
          page: () => const DashboardView(),
          binding: DashboardBinding(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}

