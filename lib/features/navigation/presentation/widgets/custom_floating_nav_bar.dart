import 'package:ecom_app/features/cart/presentation/controllers/b2c_cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../controllers/main_navigation_controller.dart';

class CustomFloatingNavBar extends StatelessWidget {
  final MainNavigationController controller;

  const CustomFloatingNavBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final double navHeight = sw * 0.18;
    final double horizontalPadding = sw * 0.04;

    return Container(
      margin: .fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.04),
      height: navHeight,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: .circular(sw * 0.09),
        border: .all(
          color: AppColors.camel.withValues(alpha: 0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: .circular(sw * 0.09),
        child: BackdropFilter(
          filter: .blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: .symmetric(horizontal: horizontalPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Obx(() {
                  final double itemWidth =
                      constraints.maxWidth / controller.navItems.length;

                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.elasticOut,
                        left: controller.selectedIndex.value * itemWidth,
                        top: constraints.maxHeight * 0.15,
                        child: Container(
                          width: itemWidth,
                          height: constraints.maxHeight * 0.7,
                          padding: .symmetric(horizontal: sw * 0.02),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.camel.withValues(alpha: 0.08),
                              borderRadius: .circular(sw * 0.07),
                            ),
                          ),
                        ),
                      ),
                      // Nav Items
                      Row(
                        children: List.generate(controller.navItems.length, (
                          index,
                        ) {
                          final item = controller.navItems[index];
                          final bool isActive =
                              controller.selectedIndex.value == index;

                          return Expanded(
                            child: _NavBarItem(
                              item: item,
                              isActive: isActive,
                              onTap: () {
                                if (!isActive) {
                                  HapticFeedback.lightImpact();
                                  controller.changeTab(index);
                                }
                              },
                              sw: sw,
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                });
              },
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
      behavior: .opaque,
      child: Column(
        mainAxisAlignment: .center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isActive ? 1.15 : 1.0,
            curve: Curves.easeOutBack,
            child: Stack(
              clipBehavior: .none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    key: ValueKey('${item.label}_$isActive'),
                    color: isActive
                        ? AppColors.camel
                        : AppColors.charcoal.withValues(alpha: 0.5),
                    size: sw * 0.065,
                  ),
                ),
                if (item.hasBadge) _buildBadge(sw),
              ],
            ),
          ),
          SizedBox(height: sw * 0.01),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: GoogleFonts.outfit(
              fontSize: sw * 0.022,
              fontWeight: isActive ? .w700 : .w600,
              color: isActive
                  ? AppColors.camel
                  : AppColors.charcoal.withValues(alpha: 0.5),
              letterSpacing: 0.8,
            ),
            child: Text(item.label.toUpperCase()),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(double sw) {
    final B2CCartController cartController = Get.find<B2CCartController>();
    return Positioned(
      top: -3,
      right: -6,
      child: Obx(() {
        if (cartController.cartItems.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const .all(2),
          decoration: BoxDecoration(
            color: AppColors.rose,
            shape: .circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.rose.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          constraints: BoxConstraints(
            minWidth: sw * 0.038,
            minHeight: sw * 0.038,
          ),
          child: Center(
            child: Text(
              '${cartController.cartItems.length}',
              style: GoogleFonts.outfit(
                color: AppColors.white,
                fontSize: sw * 0.02,
                fontWeight: .bold,
              ),
              textAlign: .center,
            ),
          ),
        );
      }),
    );
  }
}
