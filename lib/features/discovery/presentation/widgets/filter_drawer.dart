import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_button.dart';
import '../controllers/discovery_controller.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final DiscoveryController controller = Get.find<DiscoveryController>();

    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.charcoal),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.greyLight, height: 1),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  _buildSectionTitle('Size'),
                  const SizedBox(height: 16),
                  _buildSizeOptions(controller),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Color'),
                  const SizedBox(height: 16),
                  _buildColorOptions(controller),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 16),
                  _buildPriceSlider(controller),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text: 'Apply Filters',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
      ),
    );
  }

  Widget _buildSizeOptions(DiscoveryController controller) {
    final sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: sizes.map((size) {
        return Obx(() {
          final isSelected = controller.selectedSizes.contains(size);
          return GestureDetector(
            onTap: () => controller.toggleSize(size),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.charcoal : AppColors.white,
                border: Border.all(
                  color: isSelected ? AppColors.charcoal : AppColors.greyLight,
                  width: 1.5,
                ),
              ),
              child: Text(
                size,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.charcoal,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildColorOptions(DiscoveryController controller) {
    final colors = [
      {'name': 'Black', 'color': Colors.black},
      {'name': 'White', 'color': Colors.white},
      {'name': 'Navy', 'color': const Color(0xFF000080)},
      {'name': 'Beige', 'color': const Color(0xFFF5F5DC)},
      {'name': 'Camel', 'color': AppColors.camel},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: colors.map((c) {
        final colorName = c['name'] as String;
        final colorValue = c['color'] as Color;
        
        return Obx(() {
          final isSelected = controller.selectedColors.contains(colorName);
          return GestureDetector(
            onTap: () => controller.toggleColor(colorName),
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorValue,
                    border: Border.all(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorValue.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: colorValue == Colors.white ? Colors.black : Colors.white,
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  colorName,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildPriceSlider(DiscoveryController controller) {
    return Obx(() => Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${controller.priceMin.value.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: AppColors.charcoal, fontWeight: FontWeight.w500)),
            Text('\$${controller.priceMax.value.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: AppColors.charcoal, fontWeight: FontWeight.w500)),
          ],
        ),
        RangeSlider(
          values: RangeValues(controller.priceMin.value, controller.priceMax.value),
          min: 0,
          max: 1000,
          activeColor: AppColors.camel,
          inactiveColor: AppColors.greyLight,
          onChanged: (values) {
            controller.updatePriceRange(values.start, values.end);
          },
        ),
      ],
    ));
  }
}
