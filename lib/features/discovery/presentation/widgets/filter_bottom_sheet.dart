import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../app/utils/responsive.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_dropdown_field.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../controllers/filter_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final FilterController controller = Get.find<FilterController>();
    final double sw = context.screenWidth;
    final double sh = context.screenHeight;

    // Check if B2B mode is enabled
    final bool isB2BMode = Get.find<AuthController>().selectedRole.value == AuthRole.corporate;

    return Container(
      height: sh * 0.85,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // --- Bottom Sheet Handle ---
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // --- Header Section ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Refine Selection',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                      letterSpacing: -0.2,
                    ),
                  ),
                  CustomButton(
                    onPressed: () {
                      controller.clearAll();
                      Get.snackbar(
                        'Cleared',
                        'All filters reset successfully.',
                        backgroundColor: AppColors.offWhite,
                        colorText: AppColors.charcoal,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    text: 'Reset All',
                    variant: ButtonVariant.ghost,
                    textColor: AppColors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    width: null,
                    height: 36,
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.greyLight, height: 1),

            // --- Filter Form Content ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 20),
                children: [
                  // --- Sort By Section ---
                  _buildSectionTitle('Sort By', sw),
                  const SizedBox(height: 12),
                  _buildSortDropdown(controller, sw),
                  SizedBox(height: sw * 0.07),

                  // --- Category Chips Section ---
                  _buildSectionTitle('Departments', sw),
                  const SizedBox(height: 12),
                  _buildCategoryChips(controller, sw),
                  SizedBox(height: sw * 0.07),

                  // --- Price Range Slider Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Price Range', sw),
                      Obx(() {
                        final min = controller.sliderPriceRange.value.start.toStringAsFixed(0);
                        final max = controller.sliderPriceRange.value.end.toStringAsFixed(0);
                        return Text(
                          '\$$min - \$$max',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.camel,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPriceSlider(controller, sw),
                  SizedBox(height: sw * 0.07),

                  // --- Size Grid Section ---
                  _buildSectionTitle('Select Size', sw),
                  const SizedBox(height: 12),
                  _buildSizeGrid(controller, sw),
                  SizedBox(height: sw * 0.07),

                  // --- Colors Swatch Section ---
                  _buildSectionTitle('Select Color', sw),
                  const SizedBox(height: 12),
                  _buildColorSwatches(controller, sw),
                  SizedBox(height: sw * 0.07),

                  // --- B2B Specific Filters Section ---
                  if (isB2BMode) ...[
                    const Divider(color: AppColors.greyLight, height: 32),
                    Text(
                      'Corporate Sourcing',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.camel,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // MOQ Dropdown Filter
                    _buildSectionTitle('Minimum Order Quantity (MOQ)', sw),
                    const SizedBox(height: 12),
                    _buildMoqDropdown(controller, sw),
                    SizedBox(height: sw * 0.07),

                    // Sourcing Type Toggle
                    _buildSectionTitle('Sourcing Type', sw),
                    const SizedBox(height: 12),
                    _buildSourcingTypeToggles(controller, sw),
                    SizedBox(height: sw * 0.07),

                    // Factory Locations Checkboxes
                    _buildSectionTitle('Manufacturing Region', sw),
                    const SizedBox(height: 12),
                    _buildFactoryLocationCheckboxes(controller, sw),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),

            // --- Sticky CTA Action Button ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 16),
              child: CustomButton(
                text: 'Apply Filters',
                buttonColor: AppColors.camel,
                textColor: AppColors.white,
                width: double.infinity,
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Section Title Builder ---
  Widget _buildSectionTitle(String title, double sw) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
      ),
    );
  }

  // --- Sort Dropdown ---
  Widget _buildSortDropdown(FilterController controller, double sw) {
    final List<String> sortOptions = [
      'Popularity',
      'Price: Low to High',
      'Price: High to Low',
    ];

    return Obx(() => CustomDropdownField(
      value: controller.sortBy.value,
      items: sortOptions,
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.sortBy.value = newValue;
        }
      },
      borderRadius: sw * 0.03,
      fillColor: AppColors.offWhite,
      margin: EdgeInsets.zero,
    ));
  }

  // --- Category Chips ---
  Widget _buildCategoryChips(FilterController controller, double sw) {
    final List<String> categories = [
      "Men's",
      "Women's",
      "Kidswear",
      "Modest Wear",
      "Workwear",
      "Accessories",
    ];

    return SizedBox(
      height: sw * 0.1,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.selectCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.camel : AppColors.greySubtle,
                  borderRadius: BorderRadius.circular(sw * 0.05),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.ink,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // --- Price Slider ---
  Widget _buildPriceSlider(FilterController controller, double sw) {
    return Obx(() => SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppColors.camel,
        inactiveTrackColor: AppColors.greyLight,
        thumbColor: AppColors.camel,
        overlayColor: AppColors.camel.withValues(alpha: 0.15),
        trackHeight: 3.5,
        rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 9),
      ),
      child: RangeSlider(
        values: controller.sliderPriceRange.value,
        min: 0.0,
        max: 500.0,
        onChanged: (RangeValues values) {
          controller.sliderPriceRange.value = values;
        },
      ),
    ));
  }

  // --- Size Grid ---
  Widget _buildSizeGrid(FilterController controller, double sw) {
    final sizes = ['S', 'M', 'L', 'XL'];

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
              width: sw * 0.12,
              height: sw * 0.12,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.camelLight : AppColors.white,
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(
                  color: isSelected ? AppColors.camel : AppColors.greyLight,
                  width: isSelected ? 1.8 : 1.2,
                ),
              ),
              child: Text(
                size,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.camel : AppColors.charcoal,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  // --- Color Swatches ---
  Widget _buildColorSwatches(FilterController controller, double sw) {
    final colors = [
      {'name': 'Black', 'color': Colors.black},
      {'name': 'White', 'color': Colors.white},
      {'name': 'Navy', 'color': const Color(0xFF0A192F)},
      {'name': 'Beige', 'color': const Color(0xFFE1D3BE)},
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
          final bool isWhite = colorName == 'White';

          return GestureDetector(
            onTap: () => controller.toggleColor(colorName),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: sw * 0.09,
                  height: sw * 0.09,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorValue,
                    border: Border.all(
                      color: isWhite ? AppColors.greyLight : AppColors.greyLight.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.camel.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: sw * 0.045,
                          color: isWhite ? AppColors.charcoal : AppColors.white,
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  colorName,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.camel : AppColors.grey,
                  ),
                ),
              ],
            ),
          );
        });
      }).toList(),
    );
  }

  // --- B2B MOQ Dropdown ---
  Widget _buildMoqDropdown(FilterController controller, double sw) {
    final List<String> moqOptions = [
      'Any MOQ',
      '< 50 pieces',
      '50 - 200 pieces',
      '> 200 pieces',
    ];

    return Obx(() => CustomDropdownField(
      value: controller.selectedMoqOption.value,
      items: moqOptions,
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.setMoqOption(newValue);
        }
      },
      borderRadius: sw * 0.03,
      fillColor: AppColors.offWhite,
      margin: EdgeInsets.zero,
    ));
  }

  // --- B2B Sourcing Type Segmented Toggles ---
  Widget _buildSourcingTypeToggles(FilterController controller, double sw) {
    final types = ['Ready to Ship', 'Private Label'];

    return Row(
      children: types.map((type) {
        return Obx(() {
          final isSelected = controller.selectedSourcingTypes.contains(type);
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.toggleSourcingType(type),
              child: Container(
                margin: EdgeInsets.only(
                  right: type == 'Ready to Ship' ? 8 : 0,
                  left: type == 'Private Label' ? 8 : 0,
                ),
                height: sw * 0.11,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.camel : AppColors.white,
                  borderRadius: BorderRadius.circular(sw * 0.03),
                  border: Border.all(
                    color: isSelected ? AppColors.camel : AppColors.greyLight,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  type,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.white : AppColors.charcoal,
                  ),
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  // --- B2B Factory Locations Checkboxes ---
  Widget _buildFactoryLocationCheckboxes(FilterController controller, double sw) {
    final locations = ['Pakistan', 'International'];

    return Column(
      children: locations.map((loc) {
        return Obx(() {
          final isSelected = controller.selectedLocations.contains(loc);
          return GestureDetector(
            onTap: () => controller.toggleLocation(loc),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(
                  color: isSelected ? AppColors.camel : AppColors.greyLight,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.camel : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? AppColors.camel : AppColors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    loc == 'Pakistan' ? 'Local Manufacturers (Pakistan)' : 'International Suppliers',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      }).toList(),
    );
  }
}
