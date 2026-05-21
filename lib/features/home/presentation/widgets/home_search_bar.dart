import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../../../navigation/presentation/controllers/main_navigation_controller.dart';

class HomeSearchBar extends StatelessWidget {
  final double sw;
  const HomeSearchBar({super.key, required this.sw});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.05,
        vertical: sw * 0.02,
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final query = controller.searchQuery.value;
              return CustomTextField(
                controller: controller.searchController,
                hinttext: 'Search collections, styles...',
                fillColor: AppColors.offWhite,
                borderRadius: sw * 0.04,
                margin: EdgeInsets.zero,
                contentPadding: EdgeInsets.symmetric(
                  vertical: sw * 0.03,
                  horizontal: sw * 0.04,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.charcoal.withValues(alpha: 0.4),
                  size: sw * 0.055,
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, size: sw * 0.04),
                        onPressed: () {
                          controller.searchController.clear();
                        },
                      )
                    : null,
                textInputAction: TextInputAction.search,
              );
            }),
          ),
          SizedBox(width: sw * 0.02),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      height: sw * 0.11,
      width: sw * 0.11,
      decoration: BoxDecoration(
        color: AppColors.camel,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(
            color: AppColors.camel.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(sw * 0.03),
          onTap: () {
            if (Get.isRegistered<MainNavigationController>()) {
              Get.find<MainNavigationController>().changeTab(1);
            }
          },
          child: Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: sw * 0.05,
          ),
        ),
      ),
    );
  }
}
