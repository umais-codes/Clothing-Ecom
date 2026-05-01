import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../controllers/product_crud_controller.dart';

class VariantMatrixCard extends StatelessWidget {
  final double sw;
  const VariantMatrixCard({super.key, required this.sw});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductCrudController>();

    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(color: AppColors.charcoal.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.variants.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                child: Center(
                  child: Text('No variants added yet.', style: GoogleFonts.outfit(color: AppColors.grey)),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.variants.length,
              separatorBuilder: (_, _) => const Divider(color: AppColors.greyLight),
              itemBuilder: (context, index) {
                final variant = controller.variants[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${variant.color} / ${variant.size}', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                        Text('SKU: ${variant.sku}', style: GoogleFonts.outfit(fontSize: sw * 0.025, color: AppColors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Qty: ${variant.stockQuantity}', style: GoogleFonts.outfit()),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => controller.removeVariant(variant.id),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }),
          SizedBox(height: sw * 0.04),
          OutlinedButton.icon(
            onPressed: () => _showAddVariantDialog(context, controller, sw),
            icon: const Icon(Icons.add, color: AppColors.camel),
            label: const Text('Add Variant', style: TextStyle(color: AppColors.camel)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.camel),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.02)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVariantDialog(BuildContext context, ProductCrudController controller, double sw) {
    String color = '';
    String size = '';
    String qty = '';

    Get.defaultDialog(
      title: 'Add Variant',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(hinttext: 'Color (e.g. Red)', onChanged: (v) => color = v, controller: TextEditingController()),
          SizedBox(height: sw * 0.02),
          CustomTextField(hinttext: 'Size (e.g. M)', onChanged: (v) => size = v, controller: TextEditingController()),
          SizedBox(height: sw * 0.02),
          CustomTextField(
            hinttext: 'Stock Quantity',
            keyboardType: TextInputType.number,
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
