import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/home_controller.dart';

class CategoryPills extends StatelessWidget {
  final double sw;
  final HomeController controller;

  const CategoryPills({super.key, required this.sw, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sw * 0.085,
      child: ListView.builder(
        scrollDirection: .horizontal,
        padding: .symmetric(horizontal: sw * 0.045),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: .only(right: sw * 0.025),
              child: GestureDetector(
                onTap: () => controller.setCategory(category),
                child: Container(
                  padding: .symmetric(horizontal: sw * 0.04),
                  alignment: .center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.camel : AppColors.greySubtle,
                    borderRadius: .circular(sw * 0.1),
                    border: isSelected
                        ? null
                        : .all(
                            color: AppColors.greyLight.withValues(alpha: 0.6),
                            width: 0.8,
                          ),
                  ),
                  child: Text(
                    category,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: isSelected ? AppColors.white : AppColors.charcoal,
                      fontWeight: isSelected ? .w600 : .w500,
                      fontSize: sw * 0.03,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
