import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../../data/repositories/discovery_repository_impl.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../controllers/discovery_controller.dart';
import '../controllers/filter_controller.dart';
import '../widgets/active_filter_chips.dart';
import '../widgets/filter_bottom_sheet.dart';

class DiscoveryScreen extends StatelessWidget {
  DiscoveryScreen({super.key}) {
    _ensureDependenciesRegistered();
  }

  void _ensureDependenciesRegistered() {
    // Ensure all controllers and repositories are registered
    if (!Get.isRegistered<DiscoveryRepository>()) {
      Get.lazyPut<DiscoveryRepository>(() => DiscoveryRepositoryImpl());
    }
    if (!Get.isRegistered<FilterController>()) {
      Get.put(FilterController(Get.find<DiscoveryRepository>()));
    }
    if (!Get.isRegistered<DiscoveryController>()) {
      Get.put(DiscoveryController());
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureDependenciesRegistered();
    final FilterController filterController = Get.find<FilterController>();
    final AuthController authController = Get.find<AuthController>();
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context, sw, authController),
      body: Column(
        children: [
          _buildSearchHeader(filterController, sw),

          const ActiveFilterChips(),

          Expanded(
            child: Obx(() {
              if (filterController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.camel),
                  ),
                );
              }

              final products = filterController.filteredProducts;

              if (products.isEmpty) {
                return _buildEmptyState(filterController, sw);
              }

              return RefreshIndicator(
                color: AppColors.camel,
                onRefresh: () => filterController.loadProducts(),
                child: MasonryGridView.count(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sw * 0.02,
                  ),
                  crossAxisCount: sw > 600 ? 3 : 2,
                  mainAxisSpacing: sw * 0.03,
                  crossAxisSpacing: sw * 0.03,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product.toMap(),
                      index: index,
                      sw: sw,
                    );
                  },
                ),
              );
            }),
          ),
          SizedBox(height: sw * 0.2),
        ],
      ),
    );
  }

  // --- App Bar ---
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    double sw,
    AuthController authController,
  ) {
    return CustomAppBar(
      title: 'Discover',
      showBackButton: false,
      actions: [
        // Role Switch Indicator for easy testing
        Obx(() {
          final role = authController.selectedRole.value;
          final isB2B = role == AuthRole.corporate;
          return Center(
            child: Container(
              margin: EdgeInsets.only(right: sw * 0.01),
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.025,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isB2B
                    ? AppColors.camel.withValues(alpha: 0.08)
                    : AppColors.charcoal.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isB2B
                      ? AppColors.camel.withValues(alpha: 0.2)
                      : AppColors.charcoal.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Text(
                isB2B ? 'B2B' : 'B2C',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isB2B ? AppColors.camel : AppColors.charcoal,
                ),
              ),
            ),
          );
        }),
        IconButton(
          icon: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.charcoal,
          ),
          onPressed: () => Get.toNamed('/cart'),
        ),
      ],
    );
  }

  // --- Search Header Block ---
  Widget _buildSearchHeader(FilterController filterController, double sw) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
      child: Row(
        children: [
          // Dynamic Search Box
          Expanded(
            child: CustomTextField(
              controller: filterController.searchController,
              hinttext: 'Search brands, items, materials...',
              fillColor: AppColors.offWhite,
              borderRadius: sw * 0.035,
              margin: EdgeInsets.zero,
              contentPadding: EdgeInsets.symmetric(
                vertical: sw * 0.015,
                horizontal: sw * 0.03,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.charcoal.withValues(alpha: 0.5),
                size: 20,
              ),
              suffixIcon: Obx(() {
                return filterController.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.charcoal,
                          size: 18,
                        ),
                        onPressed: () {
                          filterController.searchController.clear();
                        },
                      )
                    : const SizedBox.shrink();
              }),
            ),
          ),
          SizedBox(width: sw * 0.018),
          _buildFilterButton(sw),
        ],
      ),
    );
  }

  // --- Filter Bottom Sheet Button ---
  Widget _buildFilterButton(double sw) {
    return Container(
      height: sw * 0.115,
      width: sw * 0.115,
      decoration: BoxDecoration(
        color: AppColors.camel,
        borderRadius: BorderRadius.circular(sw * 0.035),
        boxShadow: [
          BoxShadow(
            color: AppColors.camel.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(sw * 0.035),
          onTap: () {
            Get.bottomSheet(
              const FilterBottomSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              enterBottomSheetDuration: const Duration(milliseconds: 250),
              exitBottomSheetDuration: const Duration(milliseconds: 200),
            );
          },
          child: Icon(Icons.tune_rounded, color: AppColors.white, size: 22),
        ),
      ),
    );
  }

  // --- Empty Filter State Screen ---
  Widget _buildEmptyState(FilterController filterController, double sw) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: .symmetric(horizontal: sw * 0.06, vertical: sw * 0.06),
                decoration: BoxDecoration(
                  color: AppColors.camelLight.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: sw * 0.1,
                  color: AppColors.camel,
                ),
              ),
              SizedBox(height: sw * 0.01),
              Text(
                'No Match Found',
                style: GoogleFonts.playfairDisplay(
                  fontSize: sw * 0.06,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: sw * 0.01),
              Text(
                'We couldn\'t find any items matching your selected criteria. Try resetting or adjusting your active filter chips.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.03,
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sw * 0.03),
              CustomButton(
                text: 'Reset Filters',
                buttonColor: AppColors.camel,
                textColor: AppColors.white,
                width: sw * 0.5,
                onPressed: () => filterController.clearAll(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
