import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double sw;
  const HomeAppBar({super.key, required this.sw});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Umais',
        style: Get.textTheme.displayMedium?.copyWith(
          fontSize: sw * 0.048,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed('/vendor-dashboard'),
          icon: Icon(Icons.storefront_outlined, size: sw * 0.055),
          padding: .zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: sw * 0.03),
        IconButton(
          onPressed: () => Get.toNamed('/cart'),
          icon: Icon(Icons.shopping_bag_outlined, size: sw * 0.055),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: sw * 0.045),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
