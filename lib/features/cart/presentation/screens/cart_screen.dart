import 'package:ecom_app/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:ecom_app/features/cart/presentation/widgets/order_summary_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();
    final double w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.charcoal,
            size: w * 0.055,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.outfit(fontSize: w * 0.05, fontWeight: .w600),
        ),
        actions: [
          IconButton(
            icon: controller.cartItems.isNotEmpty
                ? Icon(
                    Icons.delete_forever,
                    color: AppColors.charcoal,
                    size: w * 0.055,
                  )
                : Icon(
                    Icons.delete_forever,
                    color: AppColors.greyLight,
                    size: w * 0.055,
                  ),
            onPressed: controller.cartItems.isNotEmpty
                ? () {
                    controller.clearCart();
                  }
                : null,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: w * 0.16,
                  color: AppColors.greyLight,
                ),
                SizedBox(height: w * 0.02),
                Text(
                  'Your cart is empty',
                  style: GoogleFonts.outfit(
                    fontSize: w * 0.04,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final groupedItems = controller.groupedCartItems;
        final vendorNames = groupedItems.keys.toList();

        return ListView.builder(
          padding: .only(bottom: w * 0.3),
          itemCount: vendorNames.length,
          itemBuilder: (context, index) {
            final vendor = vendorNames[index];
            final items = groupedItems[vendor]!;

            return Padding(
              padding: .only(bottom: w * 0.02),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  //  Vendor Header
                  Padding(
                    padding: .symmetric(horizontal: w * 0.04),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(
                          vendor.toUpperCase(),
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: w * 0.04,
                            fontWeight: .w600,
                            letterSpacing: 1.2,
                            color: AppColors.charcoal,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.camel),
                      ],
                    ),
                  ),
                  // Vendor Items
                  ...items.map((item) => CartItemTile(item: item)),
                ],
              ),
            );
          },
        );
      }),
      bottomNavigationBar: const OrderSummaryBottomBar(),
    );
  }
}
