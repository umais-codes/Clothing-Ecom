import 'package:ecom_app/features/discovery/presentation/widgets/filter_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_network_image.dart';
import '../controllers/discovery_controller.dart';

class DiscoveryScreen extends StatelessWidget {
  DiscoveryScreen({super.key}) {
    Get.put(DiscoveryController());
  }

  @override
  Widget build(BuildContext context) {
    final DiscoveryController controller = Get.find<DiscoveryController>();
    final Size size = MediaQuery.sizeOf(context);
    final double sw = size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(sw),
      endDrawer: const FilterDrawer(),
      body: Column(
        children: [
          _buildDepartmentTabs(controller, sw),
          Expanded(child: _buildBentoGrid(sw)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(double sw) {
    return AppBar(
      title: Text(
        'Discover',
        style: GoogleFonts.cormorantGaramond(
          fontSize: sw * 0.08, // Responsive title size
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.charcoal),
          onPressed: () {},
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.charcoal,
              ),
              onPressed: () => Get.toNamed('/cart'),
            ),
            // Cart badge could be added here
          ],
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.tune, color: AppColors.charcoal),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentTabs(DiscoveryController controller, double sw) {
    return SizedBox(
      height: sw * 0.12,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        itemCount: controller.departments.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected =
                controller.selectedDepartmentIndex.value == index;
            return GestureDetector(
              onTap: () => controller.selectDepartment(index),
              child: Padding(
                padding: EdgeInsets.only(right: sw * 0.06),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.departments[index],
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.032,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? AppColors.charcoal : AppColors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.camel,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildBentoGrid(double sw) {
    // Dummy images for illustration
    final items = [
      {
        'title': 'New Arrivals',
        'crossAxis': 2,
        'mainAxis': 2,
        'img':
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&h=600&fit=crop',
      },
      {
        'title': 'Linen Blazers',
        'crossAxis': 2,
        'mainAxis': 1,
        'img':
            'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=300&fit=crop',
      },
      {
        'title': 'Accessories',
        'crossAxis': 1,
        'mainAxis': 1,
        'img':
            'https://images.unsplash.com/photo-1509319117193-57bab727e09d?w=300&h=300&fit=crop',
      },
      {
        'title': 'Abaya Collection',
        'crossAxis': 1,
        'mainAxis': 2,
        'img':
            'https://images.unsplash.com/photo-1589156229687-496a31ad1d1f?w=300&h=600&fit=crop',
      },
      {
        'title': 'Footwear',
        'crossAxis': 2,
        'mainAxis': 1,
        'img':
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&h=300&fit=crop',
      },
    ];

    return MasonryGridView.count(
      padding: EdgeInsets.all(sw * 0.04),
      crossAxisCount: sw > 600 ? 3 : 2, // Responsive grid columns
      mainAxisSpacing: sw * 0.04,
      crossAxisSpacing: sw * 0.04,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final crossAxis = item['crossAxis'] as int;
        final ratio = crossAxis / (item['mainAxis'] as int);

        return GestureDetector(
          onTap: () {
            // Navigate to PDP with dummy data
            Get.toNamed(
              '/product-details',
              arguments: {
                'id': 'prod_$index',
                'name': item['title'],
                'price': 120.0,
                'image': item['img'],
                'vendor': 'Boutique Apparel',
                'isB2B': index == 3, // Simulate B2B for Abaya Collection
              },
            );
          },
          child: AspectRatio(
            aspectRatio: ratio,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(sw * 0.04),
                image: DecorationImage(
                  image: CustomNetworkImage.provider(item['img'] as String),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: sw * 0.03,
                    left: sw * 0.03,
                    right: sw * 0.03,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.03,
                        vertical: sw * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(sw * 0.02),
                      ),
                      child: Text(
                        item['title'] as String,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
