import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../controllers/product_crud_controller.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import 'package:ecom_app/app/utils/responsive.dart';

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
      padding: EdgeInsets.all(sw * 0.04),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Sizes',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: context.sp(14),
                  color: AppColors.charcoal,
                ),
              ),
              Obx(
                () => Text(
                  '${controller.formSelectedSizes.length} selected',
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.w600,
                    color: AppColors.camel,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.02),
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
                      fontSize: context.sp(11),
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
                          fontSize: context.sp(11),
                        ),
                      );
                    }),
                ActionChip(
                  avatar: const Icon(
                    Icons.add,
                    size: 14,
                    color: AppColors.camel,
                  ),
                  label: Text(
                    'Custom Size',
                    style: GoogleFonts.outfit(
                      color: AppColors.camel,
                      fontWeight: FontWeight.w700,
                      fontSize: context.sp(11),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Colors',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: context.sp(14),
                  color: AppColors.charcoal,
                ),
              ),
              Obx(
                () => Text(
                  '${controller.formSelectedColors.length} selected',
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.w600,
                    color: AppColors.camel,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.02),
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
                      fontSize: context.sp(11),
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
                          fontSize: context.sp(11),
                        ),
                      );
                    }),
                ActionChip(
                  avatar: const Icon(
                    Icons.add,
                    size: 14,
                    color: AppColors.camel,
                  ),
                  label: Text(
                    'Custom Color',
                    style: GoogleFonts.outfit(
                      color: AppColors.camel,
                      fontWeight: FontWeight.w700,
                      fontSize: context.sp(11),
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

          // --- QUANTITY & STOCK MATRIX SECTION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Quantities per Variant',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: context.sp(14),
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    'Set individual units for each size & color',
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10.5),
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: controller.totalStockUnits > 0
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.errorBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Total: ${controller.totalStockUnits} Units',
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w800,
                      color: controller.totalStockUnits > 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.02),

          // Quick bulk setter bar
          Obx(() {
            if (controller.variants.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: Row(
                children: [
                  Text(
                    'Set all to:',
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10.5),
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickPill(
                    context,
                    '10',
                    () => controller.bulkSetAllStock(10),
                  ),
                  _buildQuickPill(
                    context,
                    '25',
                    () => controller.bulkSetAllStock(25),
                  ),
                  _buildQuickPill(
                    context,
                    '50',
                    () => controller.bulkSetAllStock(50),
                  ),
                  _buildQuickPill(
                    context,
                    '100',
                    () => controller.bulkSetAllStock(100),
                  ),
                  const Spacer(),
                  _buildQuickPill(
                    context,
                    'Clear (0)',
                    () => controller.bulkSetAllStock(0),
                    isDestructive: true,
                  ),
                ],
              ),
            );
          }),

          // Variants List with Steppers
          Obx(() {
            if (controller.variants.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 36,
                        color: AppColors.greyLight,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select sizes and colors above to generate variant matrix.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: AppColors.grey,
                          fontSize: context.sp(11.5),
                        ),
                      ),
                    ],
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
                  padding: EdgeInsets.symmetric(vertical: sw * 0.015),
                  child: Row(
                    children: [
                      // Variant Label & SKU
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.charcoal,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    variant.size,
                                    style: GoogleFonts.outfit(
                                      fontSize: context.sp(10),
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  variant.color,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: context.sp(13),
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SKU: ${variant.sku}',
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(10),
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price Override Pill
                      GestureDetector(
                        onTap: () => _showEditSinglePriceDialog(
                          context,
                          controller,
                          variant.id,
                          variant.price,
                          double.tryParse(
                                controller.basePriceController.text,
                              ) ??
                              0.0,
                          '${variant.color} - Size ${variant.size}',
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: variant.price != null
                                ? AppColors.camel.withValues(alpha: 0.12)
                                : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: variant.price != null
                                  ? AppColors.camel
                                  : AppColors.greyLight,
                            ),
                          ),
                          child: Text(
                            variant.price != null
                                ? '\$${variant.price!.toStringAsFixed(0)}'
                                : 'Base Price',
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(10.5),
                              fontWeight: FontWeight.w700,
                              color: variant.price != null
                                  ? AppColors.camel
                                  : AppColors.grey,
                            ),
                          ),
                        ),
                      ),

                      // Interactive Stock Quantity Stepper
                      Row(
                        children: [
                          _buildStepperButton(
                            icon: Icons.remove,
                            onTap: () => controller.updateVariantStock(
                              variant.id,
                              variant.stockQuantity - 1,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showEditSingleQtyDialog(
                              context,
                              controller,
                              variant.id,
                              variant.stockQuantity,
                              '${variant.color} - Size ${variant.size}',
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 38),
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.greyLight),
                              ),
                              child: Center(
                                child: Text(
                                  '${variant.stockQuantity}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: context.sp(11.5),
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _buildStepperButton(
                            icon: Icons.add,
                            onTap: () => controller.updateVariantStock(
                              variant.id,
                              variant.stockQuantity + 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.error,
                              size: 18,
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

  Widget _buildQuickPill(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.errorBg : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.3)
                : AppColors.greyLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: context.sp(9.5),
            fontWeight: FontWeight.w700,
            color: isDestructive ? AppColors.error : AppColors.charcoal,
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.greyLight),
        ),
        child: Icon(icon, size: 14, color: AppColors.charcoal),
      ),
    );
  }

  void _showEditSinglePriceDialog(
    BuildContext context,
    ProductCrudController controller,
    String variantId,
    double? currentPrice,
    double basePrice,
    String variantLabel,
  ) {
    final textController = TextEditingController(
      text: currentPrice != null
          ? '$currentPrice'
          : (basePrice > 0 ? '$basePrice' : ''),
    );
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.payments_outlined,
      title: 'Set Variant Price',
      description:
          'Custom price for $variantLabel (leave blank to use Base Price)',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomTextField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          hinttext: 'e.g. 145.00',
          autoFocus: true,
        ),
      ),
      grantText: 'Save Price',
      denyText: 'Cancel',
      onGrant: () {
        final parsed = double.tryParse(textController.text.trim());
        controller.updateVariantPrice(variantId, parsed);
      },
    );
  }

  void _showEditSingleQtyDialog(
    BuildContext context,
    ProductCrudController controller,
    String variantId,
    int currentQty,
    String variantLabel,
  ) {
    final textController = TextEditingController(text: '$currentQty');
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.inventory_2_outlined,
      title: 'Set Stock Quantity',
      description: variantLabel,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomTextField(
          controller: textController,
          keyboardType: TextInputType.number,
          hinttext: 'Enter stock units',
          autoFocus: true,
        ),
      ),
      grantText: 'Update Stock',
      denyText: 'Cancel',
      onGrant: () {
        final parsed = int.tryParse(textController.text.trim()) ?? currentQty;
        controller.updateVariantStock(variantId, parsed);
      },
    );
  }

  void _showAddCustomSizeDialog(
    BuildContext context,
    ProductCrudController controller,
  ) {
    final textController = TextEditingController();
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.straighten_rounded,
      title: 'Add Custom Size',
      description: 'Enter a custom garment size identifier',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomTextField(
          controller: textController,
          hinttext: 'e.g. 42 / Unisex / Free Size',
          autoFocus: true,
        ),
      ),
      grantText: 'Add Size',
      denyText: 'Cancel',
      onGrant: () {
        if (textController.text.trim().isNotEmpty) {
          controller.addCustomSize(textController.text.trim());
        }
      },
    );
  }

  void _showAddCustomColorDialog(
    BuildContext context,
    ProductCrudController controller,
  ) {
    final textController = TextEditingController();
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.palette_outlined,
      title: 'Add Custom Color',
      description: 'Enter a custom apparel color name',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CustomTextField(
          controller: textController,
          hinttext: 'e.g. Emerald Green / Rose Gold',
          autoFocus: true,
        ),
      ),
      grantText: 'Add Color',
      denyText: 'Cancel',
      onGrant: () {
        if (textController.text.trim().isNotEmpty) {
          controller.addCustomColor(textController.text.trim());
        }
      },
    );
  }

  void _showAddVariantDialog(
    BuildContext context,
    ProductCrudController controller,
    double sw,
  ) {
    final colorCtrl = TextEditingController();
    final sizeCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '50');
    final priceCtrl = TextEditingController();

    CustomPermissionDialog.show(
      context: context,
      icon: Icons.add_box_outlined,
      title: 'Add Custom Variant',
      description: 'Create a specific size and color SKU',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(hinttext: 'Color (e.g. Red)', controller: colorCtrl),
          const SizedBox(height: 10),
          CustomTextField(hinttext: 'Size (e.g. M)', controller: sizeCtrl),
          const SizedBox(height: 10),
          CustomTextField(
            hinttext: 'Stock Quantity',
            keyboardType: TextInputType.number,
            controller: qtyCtrl,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            hinttext: 'Custom Price (Optional, e.g. 150)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: priceCtrl,
          ),
        ],
      ),
      grantText: 'Add Variant',
      denyText: 'Cancel',
      onGrant: () {
        final c = colorCtrl.text.trim();
        final s = sizeCtrl.text.trim();
        final q = int.tryParse(qtyCtrl.text.trim()) ?? 0;
        final p = double.tryParse(priceCtrl.text.trim());
        if (c.isNotEmpty && s.isNotEmpty) {
          controller.addVariant(c, s, q, p);
        } else {
          Get.snackbar('Error', 'Please fill all required fields');
        }
      },
    );
  }
}
