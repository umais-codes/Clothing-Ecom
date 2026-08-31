import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2c_cart_controller.dart';


class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double sw;
  const HomeAppBar({super.key, required this.sw});

  @override
  Widget build(BuildContext context) {
    final b2cCart = Get.find<B2CCartController>();

    return CustomAppBar(
      title: 'Velvet Maison',
      showBackButton: false,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Shopping Bag',
              onPressed: () => Get.toNamed('/cart'),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
            Obx(() {
              if (b2cCart.cartItems.isEmpty) return const SizedBox.shrink();
              return Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.camel,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${b2cCart.cartItems.length}',
                    style: GoogleFonts.outfit(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ],
        ),
        SizedBox(width: sw * 0.02),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
