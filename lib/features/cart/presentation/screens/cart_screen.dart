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
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.cormorantGaramond(
            fontSize: w * 0.05,
            fontWeight: .w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: AppColors.charcoal),
            onPressed: () {},
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
                  size: w * 0.18,
                  color: AppColors.greyLight,
                ),
                SizedBox(height: w * 0.04),
                Text(
                  'Your cart is empty',
                  style: GoogleFonts.outfit(
                    fontSize: w * 0.05,
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
              padding: .only(bottom: w * 0.04),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  //  Vendor Header
                  Padding(
                    padding: .symmetric(
                      horizontal: w * 0.04,
                      vertical: w * 0.02,
                    ),
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
                  Divider(
                    color: AppColors.greyLight,
                    height: 1,
                    indent: w * 0.03,
                    endIndent: w * 0.03,
                  ),
                  SizedBox(height: w * 0.01),

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
