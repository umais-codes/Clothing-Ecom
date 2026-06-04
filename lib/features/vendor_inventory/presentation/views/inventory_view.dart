import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/vendor_inventory/presentation/views/product_form_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_button.dart';
import '../controllers/product_crud_controller.dart';
import '../widgets/bulk_upload_sheet.dart';
import '../../../../app/widgets/custom_confirm_dialog.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductCrudController>();
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: const CustomAppBar(
        title: 'Inventory Overview',
        showBackButton: false,
      ),

      body: Column(
        children: [
          _buildActionHeader(context, sw, controller),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshProducts,
              color: AppColors.camel,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.camel),
                  );
                }
                if (controller.products.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: context.screenHeight * 0.6,
                      child: _buildEmptyState(sw, controller),
                    ),
                  );
                }
                return _buildProductList(controller, sw);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHeader(
    BuildContext context,
    double sw,
    ProductCrudController controller,
  ) {
    return Container(
      padding: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Bulk Upload',
                  icon: Icons.upload_file,
                  variant: .outlined,
                  height: sw * 0.11,
                  onPressed: () {
                    Get.bottomSheet(
                      BulkUploadSheet(sw: sw),
                      isScrollControlled: true,
                    );
                  },
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: CustomButton(
                  text: 'Add New',
                  icon: Icons.add,
                  variant: ButtonVariant.primary,
                  height: sw * 0.11,
                  onPressed: () {
                    controller.clearForm();
                    Get.to(() => const ProductFormView());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double sw, ProductCrudController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: sw * 0.2,
            color: AppColors.greyLight,
          ),
          SizedBox(height: sw * 0.04),
          Text(
            'No products found',
            style: GoogleFonts.outfit(
              fontSize: sw * 0.045,
              color: AppColors.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(ProductCrudController controller, double sw) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.015,
        vertical: sw * 0.0075,
      ),
      itemCount: controller.products.length,
      separatorBuilder: (context, index) => SizedBox(height: sw * 0.01),
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return Container(
          padding: EdgeInsets.all(sw * 0.015),
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
          child: Row(
            children: [
              Container(
                width: sw * 0.12,
                height: sw * 0.12,
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(sw * 0.02),
                  image: product.imageUrls.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrls.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imageUrls.isEmpty
                    ? Icon(Icons.image_not_supported, color: AppColors.grey)
                    : null,
              ),
              SizedBox(width: sw * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: sw * 0.035,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sw * 0.005),
                    Text(
                      '\$${product.basePrice.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w500,
                        fontSize: sw * 0.032,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.camel, size: sw * 0.05),
                onPressed: () {
                  controller.titleController.text = product.title;
                  controller.descriptionController.text = product.description;
                  controller.selectedCategory.value = product.category;
                  controller.basePriceController.text = product.basePrice
                      .toString();
                  controller.variants.assignAll(product.variants);
                  controller.imageUrls.assignAll(product.imageUrls);
                  Get.to(() => const ProductFormView());
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: sw * 0.05,
                ),
                onPressed: () {
                  Get.dialog(
                    CustomConfirmDialog(
                      title: 'Delete Product',
                      message:
                          'Are you sure you want to delete this product? This action cannot be undone.',
                      confirmText: 'Delete',
                      onConfirm: () {
                        controller.deleteProduct(product.id);
                        Get.back();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
