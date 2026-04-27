import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/cart/presentation/controllers/cart_controller.dart';
import '../controllers/main_navigation_controller.dart';

class CustomFloatingNavBar extends StatelessWidget {
  final MainNavigationController controller;

  const CustomFloatingNavBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return Container(
      margin: EdgeInsets.fromLTRB(sw * 0.06, 0, sw * 0.06, sw * 0.08),
      height: sw * 0.18,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(sw * 0.09),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(sw * 0.09),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(controller.navItems.length, (index) {
                return Obx(() {
                  final item = controller.navItems[index];
                  final bool isActive = controller.selectedIndex.value == index;
                  return _NavBarItem(
                    item: item,
                    isActive: isActive,
                    onTap: () => controller.changeTab(index),
                    sw: sw,
                  );
                });
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final NavigationItemData item;
  final bool isActive;
  final VoidCallback onTap;
  final double sw;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: sw * 0.18,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    key: ValueKey('${item.label}_$isActive'),
                    color: isActive ? AppColors.camel : AppColors.charcoal.withValues(alpha: 0.6),
                    size: sw * 0.065,
                  ),
                ),
                if (item.hasBadge) _buildBadge(sw),
              ],
            ),
            SizedBox(height: sw * 0.01),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: sw * 0.024,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.camel : AppColors.charcoal.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
              child: Text(item.label.toUpperCase()),
            ),
            if (isActive)
              Container(
                margin: EdgeInsets.only(top: sw * 0.01),
                height: 2,
                width: sw * 0.03,
                decoration: BoxDecoration(
                  color: AppColors.camel,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(double sw) {
    final CartController cartController = Get.find<CartController>();
    return Positioned(
      top: -2,
      right: -4,
      child: Obx(() {
        if (cartController.cartItems.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.camel,
            shape: BoxShape.circle,
          ),
          constraints: BoxConstraints(
            minWidth: sw * 0.035,
            minHeight: sw * 0.035,
          ),
          child: Text(
            '${cartController.cartItems.length}',
            style: TextStyle(
              color: Colors.white,
              fontSize: sw * 0.02,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }
}
