import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/category_pills.dart';
import '../widgets/product_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: HomeAppBar(sw: sw),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSearchBar(sw: sw),
            CategoryPills(sw: sw, controller: controller),
            SizedBox(height: sw * 0.02),
            _buildMasonryGrid(sw),
            SizedBox(height: sw * 0.06),
          ],
        ),
      ),
    );
  }

  Widget _buildMasonryGrid(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: sw * 0.15),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.camel),
            ),
          );
        }

        final products = controller.filteredProducts;

        if (products.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: sw * 0.15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: sw * 0.12,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                SizedBox(height: sw * 0.03),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                SizedBox(height: sw * 0.01),
                Text(
                  'Try searching for something else or changing categories.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: sw * 0.03, color: AppColors.grey),
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: sw * 0.03,
          crossAxisSpacing: sw * 0.03,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product, index: index, sw: sw);
          },
        );
      }),
    );
  }
}
