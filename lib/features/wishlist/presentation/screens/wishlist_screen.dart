import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_button.dart';
import '../controllers/wishlist_controller.dart';
import '../widgets/wishlist_item_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistController controller = Get.put(WishlistController());
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Soft Ivory
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Wishlist',
          style: GoogleFonts.outfit(
            fontSize: sw * 0.05,
            fontWeight: .w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.wishlistItems.isEmpty) {
          return _buildEmptyState(sw);
        }
        return _buildWishlistGrid(controller, sw);
      }),
    );
  }

  Widget _buildEmptyState(double sw) {
    return Center(
      child: Padding(
        padding: .symmetric(horizontal: sw * 0.1),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            /// WIREFRAME HEART ICON
            Container(
              padding: .symmetric(vertical: sw * 0.01, horizontal: sw * 0.01),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: .circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: 0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: sw * 0.2,
                color: AppColors.greyLight,
              ),
            ),
            SizedBox(height: sw * 0.02),
            Text(
              'Your wishlist is empty',
              style: GoogleFonts.outfit(
                fontSize: sw * 0.05,
                fontWeight: .w600,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: sw * 0.01),
            Text(
              'Curate your dream wardrobe by saving items you love.',
              textAlign: .center,
              style: GoogleFonts.outfit(
                fontSize: sw * 0.035,
                color: AppColors.grey,
                height: 1.5,
              ),
            ),
            SizedBox(height: sw * 0.1),
            CustomButton(
              text: 'Discover New Arrivals',
              onPressed: () => Get.toNamed('/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistGrid(WishlistController controller, double sw) {
    return GridView.builder(
      padding: .symmetric(horizontal: sw * 0.02, vertical: sw * 0.01),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: sw * 0.01,
        crossAxisSpacing: sw * 0.01,
        childAspectRatio: 0.8,
      ),
      itemCount: controller.wishlistItems.length,
      itemBuilder: (context, index) {
        final product = controller.wishlistItems[index];
        return WishlistItemCard(product: product, sw: sw);
      },
    );
  }
}
