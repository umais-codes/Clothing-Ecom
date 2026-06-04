import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double sw;
  const HomeAppBar({super.key, required this.sw});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'AURA',
      showBackButton: false,
      actions: [
        IconButton(
          onPressed: () => Get.toNamed('/vendor-dashboard'),
          icon: const Icon(Icons.storefront_outlined),
        ),
        IconButton(
          onPressed: () => Get.toNamed('/cart'),
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
        SizedBox(width: sw * 0.02),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
