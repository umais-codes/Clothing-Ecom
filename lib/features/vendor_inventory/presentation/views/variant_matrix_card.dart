import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../controllers/product_crud_controller.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class VariantMatrixCard extends StatelessWidget {
  final double sw;
  const VariantMatrixCard({super.key, required this.sw});

  static const List<String> _presetSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    '2XL',
    '3XL',
  ];
  static const List<String> _presetColors = [
    'Camel',
    'Beige',
    'White',
    'Black',
    'Navy',
    'Grey',
    'Red',
    'Olive',
    'Blue',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductCrudController>();

    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SIZES SECTION ---
          Text(
            'Select Available Sizes',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: sw * 0.035,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(height: sw * 0.015),
          Obx(() {
            return Wrap(
              spacing: sw * 0.015,
              runSpacing: sw * 0.015,
              children: [
                ..._presetSizes.map((s) {
                  final isSelected = controller.formSelectedSizes.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleFormSize(s),
                    selectedColor: AppColors.camel,
                    backgroundColor: AppColors.offWhite,
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? AppColors.white : AppColors.charcoal,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: sw * 0.03,
                    ),
                  );
                }),
                ...controller.formSelectedSizes
                    .where((s) => !_presetSizes.contains(s))
                    .map((s) {
                      return FilterChip(
                        label: Text(s),
                        selected: true,
                        onSelected: (_) => controller.toggleFormSize(s),
                        selectedColor: AppColors.camel,
                        labelStyle: GoogleFonts.outfit(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: sw * 0.03,
                        ),
                      );
                    }),
                ActionChip(
                  avatar: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.camel,
                  ),
                  label: Text(
                    'Custom Size',
                    style: GoogleFonts.outfit(
                      color: AppColors.camel,
                      fontWeight: FontWeight.w600,
                      fontSize: sw * 0.03,
                    ),
                  ),
                  backgroundColor: AppColors.camel.withValues(alpha: 0.1),
                  onPressed: () =>
                      _showAddCustomSizeDialog(context, controller),
                ),
              ],
            );
          }),

          SizedBox(height: sw * 0.03),
          const Divider(color: AppColors.greySubtle),
          SizedBox(height: sw * 0.015),

          // --- COLORS SECTION ---
          Text(
            'Select Available Colors',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: sw * 0.035,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(height: sw * 0.015),
          Obx(() {
            return Wrap(
              spacing: sw * 0.015,
              runSpacing: sw * 0.015,
              children: [
                ..._presetColors.map((c) {
                  final isSelected = controller.formSelectedColors.contains(c);
                  return FilterChip(
                    label: Text(c),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleFormColor(c),
                    selectedColor: AppColors.camel,
                    backgroundColor: AppColors.offWhite,
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? AppColors.white : AppColors.charcoal,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: sw * 0.03,
                    ),
                  );
                }),
                ...controller.formSelectedColors
                    .where((c) => !_presetColors.contains(c))
                    .map((c) {
                      return FilterChip(
                        label: Text(c),
                        selected: true,
                        onSelected: (_) => controller.toggleFormColor(c),
                        selectedColor: AppColors.camel,
                        labelStyle: GoogleFonts.outfit(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: sw * 0.03,
                        ),
                      );
                    }),
                ActionChip(
                  avatar: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.camel,
                  ),
                  label: Text(
                    'Custom Color',
                    style: GoogleFonts.outfit(
                      color: AppColors.camel,
                      fontWeight: FontWeight.w600,
                      fontSize: sw * 0.03,
                    ),
                  ),
                  backgroundColor: AppColors.camel.withValues(alpha: 0.1),
                  onPressed: () =>
                      _showAddCustomColorDialog(context, controller),
                ),
              ],
            );
          }),

          SizedBox(height: sw * 0.03),
          const Divider(color: AppColors.greySubtle),
          SizedBox(height: sw * 0.015),

          // --- GENERATED VARIANTS LIST ---
          Text(
            'Generated Apparel Matrix Variants',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: sw * 0.035,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(height: sw * 0.02),
          Obx(() {
            if (controller.variants.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: sw * 0.03),
                child: Center(
                  child: Text(
                    'Select sizes and colors above to generate variants automatically.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppColors.grey,
                      fontSize: sw * 0.03,
                    ),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.variants.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: AppColors.greyLight, height: 1),
              itemBuilder: (context, index) {
                final variant = controller.variants[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: sw * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${variant.color} / ${variant.size}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: sw * 0.034,
                            ),
                          ),
                          Text(
                            'SKU: ${variant.sku}',
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.026,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Qty: ${variant.stockQuantity}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: sw * 0.032,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            onPressed: () =>
                                controller.removeVariant(variant.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          SizedBox(height: sw * 0.02),
          CustomButton(
            text: 'Add Single Custom Variant',
            onPressed: () => _showAddVariantDialog(context, controller, sw),
            icon: Icons.add,
            variant: ButtonVariant.outlined,
            textColor: AppColors.camel,
            height: sw * 0.09,
            borderRadius: sw * 0.02,
          ),
        ],
      ),
    );
  }

  void _showAddCustomSizeDialog(
    BuildContext context,
    ProductCrudController controller,
  ) {
    final textController = TextEditingController();
    Get.defaultDialog(
      title: 'Add Custom Size',
      content: CustomTextField(
        controller: textController,
        hinttext: 'e.g. 42 / Unisex / Free Size',
      ),
      textConfirm: 'Add',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.camel,
      onConfirm: () {
        controller.addCustomSize(textController.text);
        Get.back();
      },
    );
  }

  void _showAddCustomColorDialog(
    BuildContext context,
    ProductCrudController controller,
  ) {
    final textController = TextEditingController();
    Get.defaultDialog(
      title: 'Add Custom Color',
      content: CustomTextField(
        controller: textController,
        hinttext: 'e.g. Emerald Green / Rose Gold',
      ),
      textConfirm: 'Add',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.camel,
      onConfirm: () {
        controller.addCustomColor(textController.text);
        Get.back();
      },
    );
  }

  void _showAddVariantDialog(
    BuildContext context,
    ProductCrudController controller,
    double sw,
  ) {
    String color = '';
    String size = '';
    String qty = '';

    Get.defaultDialog(
      title: 'Add Custom Variant',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            hinttext: 'Color (e.g. Red)',
            onChanged: (v) => color = v,
            controller: TextEditingController(),
          ),
          SizedBox(height: sw * 0.02),
          CustomTextField(
            hinttext: 'Size (e.g. M)',
            onChanged: (v) => size = v,
            controller: TextEditingController(),
          ),
          SizedBox(height: sw * 0.02),
          CustomTextField(
            hinttext: 'Stock Quantity',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            onChanged: (v) => qty = v,
            controller: TextEditingController(),
          ),
        ],
      ),
      textConfirm: 'Add',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.camel,
      onConfirm: () {
        if (color.isNotEmpty && size.isNotEmpty && qty.isNotEmpty) {
          final q = int.tryParse(qty) ?? 0;
          controller.addVariant(color, size, q);
          Get.back();
        } else {
          Get.snackbar('Error', 'Please fill all fields');
        }
      },
    );
  }
}
