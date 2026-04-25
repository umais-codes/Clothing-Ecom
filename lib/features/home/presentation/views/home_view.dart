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
    final double sw = MediaQuery.of(context).size.width;

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
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: sw * 0.03,
        crossAxisSpacing: sw * 0.03,
        itemCount: controller.trendingProducts.length,
        itemBuilder: (context, index) {
          final product = controller.trendingProducts[index];
          return ProductCard(product: product, index: index, sw: sw);
        },
      ),
    );
  }
}
