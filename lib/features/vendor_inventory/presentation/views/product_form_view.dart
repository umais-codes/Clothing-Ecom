import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/vendor_inventory/presentation/views/variant_matrix_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../../../../app/widgets/custom_dropdown_field.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../../../../app/utils/constants.dart';
import '../controllers/product_crud_controller.dart';

class ProductFormView extends StatelessWidget {
  const ProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductCrudController>();
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: CustomAppBar(
        title: 'Product Details',
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          CustomButton(
            text: 'Save',
            onPressed: () {
              controller.saveDraft();
              Get.back();
              Get.snackbar('Draft Saved', 'Your progress has been saved.');
            },
            variant: ButtonVariant.ghost,
            textColor: AppColors.camel,
            height: 35,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.camel),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sw * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information', sw),
              _buildBasicInfoCard(controller, sw),
              SizedBox(height: sw * 0.012),

              _buildSectionTitle('Media Upload', sw),
              _buildMediaCard(controller, sw),
              SizedBox(height: sw * 0.012),

              _buildSectionTitle('Apparel Matrix Variants', sw),
              VariantMatrixCard(sw: sw),
              SizedBox(height: sw * 0.012),

              _buildSectionTitle('Pricing', sw),
              _buildPricingCard(controller, sw),
              SizedBox(height: sw * 0.012),

              _buildSectionTitle('Wholesale Options (B2B)', sw),
              _buildB2BConfigCard(controller, sw),
              SizedBox(height: sw * 0.012),

              CustomButton(
                text: 'Publish Product',
                onPressed: controller.saveProduct,
                height: sw * 0.12,
              ),
              SizedBox(height: sw * 0.1),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, double sw) {
    return Padding(
      padding: EdgeInsets.only(top: sw * 0.012),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: sw * 0.045,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ProductCrudController controller, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: sw * 0.01, horizontal: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.02),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: controller.titleController,
            hinttext: 'Product Title',
            onChanged: (_) => controller.saveDraft(),
          ),
          SizedBox(height: sw * 0.02),
          CustomTextField(
            controller: controller.descriptionController,
            hinttext: 'Product Description',
            maxLines: 4,
            onChanged: (_) => controller.saveDraft(),
          ),
          SizedBox(height: sw * 0.02),
          Obx(
            () => CustomDropdownField(
              value: controller.selectedCategory.value,
              items: AppConstants.categories,
              hinttext: 'Category',
              onChanged: (value) {
                if (value != null) {
                  controller.selectedCategory.value = value;
                  controller.saveDraft();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(ProductCrudController controller, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: sw * 0.01, horizontal: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.02),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              controller.addImage(
                'https://picsum.photos/200/300?random=${DateTime.now().millisecondsSinceEpoch}',
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sw * 0.06),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(sw * 0.02),
                border: Border.all(
                  color: AppColors.camel,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.camel,
                    size: sw * 0.08,
                  ),
                  SizedBox(height: sw * 0.02),
                  Text(
                    'Tap to upload image',
                    style: GoogleFonts.outfit(color: AppColors.camel),
                  ),
                ],
              ),
            ),
          ),
          if (controller.imageUrls.isNotEmpty) ...[
            SizedBox(height: sw * 0.02),
            SizedBox(
              height: sw * 0.2,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.imageUrls.length,
                separatorBuilder: (_, _) => SizedBox(width: sw * 0.02),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: sw * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(sw * 0.02),
                          image: DecorationImage(
                            image: NetworkImage(controller.imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(
                            controller.imageUrls[index],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: sw * 0.05,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingCard(ProductCrudController controller, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: sw * 0.01, horizontal: sw * 0.02),
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
      child: CustomTextField(
        controller: controller.basePriceController,
        hinttext: 'Base Price',
        textAlign: TextAlign.left,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: Icon(Icons.attach_money, color: AppColors.charcoal),
        onChanged: (_) => controller.saveDraft(),
      ),
    );
  }

  Widget _buildB2BConfigCard(ProductCrudController controller, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: sw * 0.02, horizontal: sw * 0.03),
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
        children: [
          Obx(
            () => SwitchListTile(
              title: Text(
                'List as B2B Product',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              subtitle: Text(
                'Show this product on the B2B Sourcing Portal instead of the B2C shop.',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),
              value: controller.isB2B.value,
              activeThumbColor: AppColors.camel,
              onChanged: (val) {
                controller.isB2B.value = val;
                controller.saveDraft();
              },
            ),
          ),
          Obx(() {
            if (!controller.isB2B.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: CustomTextField(
                controller: controller.moqController,
                hinttext: 'Minimum Order Quantity (MOQ)',
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                prefixIcon: Icon(Icons.production_quantity_limits_rounded, color: AppColors.charcoal),
                onChanged: (_) => controller.saveDraft(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
