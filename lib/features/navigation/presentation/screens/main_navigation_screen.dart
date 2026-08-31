import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/main_navigation_controller.dart';
import '../widgets/custom_floating_nav_bar.dart';

class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      extendBody: true,
      body: Obx(() {
        final currentPages = controller.pages;
        final int index = controller.selectedIndex.value;
        final int safeIndex = (index >= 0 && index < currentPages.length)
            ? index
            : 0;

        return PopScope(
          canPop: safeIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (controller.selectedIndex.value != 0) {
              controller.changeTab(0);
            }
          },
          child: IndexedStack(
            key: ValueKey('main_nav_${controller.currentRole.name}'),
            index: safeIndex,
            children: currentPages,
          ),
        );
      }),
      bottomNavigationBar: CustomFloatingNavBar(controller: controller),
    );
  }
}
