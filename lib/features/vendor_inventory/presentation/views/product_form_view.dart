import 'package:ecom_app/features/vendor_inventory/presentation/views/variant_matrix_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_button.dart';
import '../../../../app/widgets/custom_text_field.dart';
import '../controllers/product_crud_controller.dart';

class ProductFormView extends StatelessWidget {
  const ProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductCrudController>();
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Product Details',
          style: GoogleFonts.outfit(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        actions: [
          TextButton(
            onPressed: () {
              controller.saveDraft();
              Get.back();
              Get.snackbar('Draft Saved', 'Your progress has been saved.');
            },
            child: Text(
              'Save Draft',
              style: GoogleFonts.outfit(
                color: AppColors.camel,
                fontWeight: FontWeight.w500,
              ),
            ),
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
          padding: EdgeInsets.all(sw * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information', sw),
              _buildBasicInfoCard(controller, sw),
              SizedBox(height: sw * 0.06),

              _buildSectionTitle('Media Upload', sw),
              _buildMediaCard(controller, sw),
              SizedBox(height: sw * 0.06),

              _buildSectionTitle('Apparel Matrix Variants', sw),
              VariantMatrixCard(sw: sw),
              SizedBox(height: sw * 0.06),

              _buildSectionTitle('Pricing', sw),
              _buildPricingCard(controller, sw),
              SizedBox(height: sw * 0.1),

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
      padding: EdgeInsets.only(bottom: sw * 0.02),
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
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
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
            controller: TextEditingController(text: controller.title.value),
            hinttext: 'Product Title',
            onChanged: (val) {
              controller.title.value = val;
              controller.saveDraft();
            },
          ),
          SizedBox(height: sw * 0.04),
          CustomTextField(
            controller: TextEditingController(
              text: controller.description.value,
            ),
            hinttext: 'Product Description',
            maxLines: 4,
            onChanged: (val) {
              controller.description.value = val;
              controller.saveDraft();
            },
          ),
          SizedBox(height: sw * 0.04),
          CustomTextField(
            controller: TextEditingController(text: controller.category.value),
            hinttext: 'Category (e.g., Shirts, Pants)',
            onChanged: (val) {
              controller.category.value = val;
              controller.saveDraft();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(ProductCrudController controller, double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
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
              // Simulate adding an image
              controller.addImage(
                'https://picsum.photos/200/300?random=${DateTime.now().millisecondsSinceEpoch}',
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sw * 0.08),
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
            SizedBox(height: sw * 0.04),
            SizedBox(
              height: sw * 0.2,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.imageUrls.length,
                separatorBuilder: (_, __) => SizedBox(width: sw * 0.02),
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
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
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
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomTextField(
        controller: TextEditingController(text: controller.basePrice.value),
        hinttext: 'Base Price',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        prefixIcon: const Icon(Icons.attach_money, color: AppColors.charcoal),
        onChanged: (val) {
          controller.basePrice.value = val;
          controller.saveDraft();
        },
      ),
    );
  }
}
