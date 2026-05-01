import 'package:ecom_app/features/vendor_inventory/presentation/views/product_form_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/product_crud_controller.dart';
import '../widgets/bulk_upload_sheet.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

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
          'Inventory Overview',
          style: GoogleFonts.outfit(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
      ),
      body: Column(
        children: [
          _buildActionHeader(context, sw, controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.camel),
                );
              }
              if (controller.products.isEmpty) {
                return _buildEmptyState(sw, controller);
              }
              return _buildProductList(controller, sw);
            }),
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
      padding: EdgeInsets.all(sw * 0.04),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.bottomSheet(
                      BulkUploadSheet(sw: sw),
                      isScrollControlled: true,
                    );
                  },
                  icon: const Icon(Icons.upload_file, color: AppColors.camel),
                  label: const Text(
                    'Bulk Upload',
                    style: TextStyle(color: AppColors.camel),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.camel),
                    padding: EdgeInsets.symmetric(vertical: sw * 0.03),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.clearForm();
                    Get.to(() => const ProductFormView());
                  },
                  icon: const Icon(Icons.add, color: AppColors.white),
                  label: const Text(
                    'Add New',
                    style: TextStyle(color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.camel,
                    padding: EdgeInsets.symmetric(vertical: sw * 0.03),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                  ),
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
      padding: EdgeInsets.all(sw * 0.04),
      itemCount: controller.products.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return Container(
          padding: EdgeInsets.all(sw * 0.03),
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
              // Thumbnail
              Container(
                width: sw * 0.15,
                height: sw * 0.15,
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
              SizedBox(width: sw * 0.03),
              // Details
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
                    SizedBox(height: sw * 0.01),
                    Text(
                      '\$${product.basePrice.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.camel),
                onPressed: () {
                  // Pre-fill form
                  controller.title.value = product.title;
                  controller.description.value = product.description;
                  controller.category.value = product.category;
                  controller.basePrice.value = product.basePrice.toString();
                  controller.variants.assignAll(product.variants);
                  controller.imageUrls.assignAll(product.imageUrls);
                  Get.to(() => const ProductFormView());
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Delete Product',
                    middleText: 'Are you sure you want to delete this product?',
                    textConfirm: 'Delete',
                    textCancel: 'Cancel',
                    confirmTextColor: AppColors.white,
                    buttonColor: AppColors.error,
                    onConfirm: () {
                      controller.deleteProduct(product.id);
                      Get.back();
                    },
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
