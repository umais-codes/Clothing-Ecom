import 'package:ecom_app/app/utils/constants.dart';
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
                if (controller.filteredProducts.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: context.screenHeight * 0.5,
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
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Bulk Upload',
                  icon: Icons.upload_file,
                  variant: ButtonVariant.outlined,
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
          SizedBox(height: sw * 0.025),
          TextField(
            onChanged: (val) => controller.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: AppColors.offWhite,
              contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(sw * 0.02),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: sw * 0.02),
          SizedBox(
            height: sw * 0.08,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', ...AppConstants.categories].map((cat) {
                return Obx(() {
                  final isSelected = controller.selectedCategoryFilter.value == cat;
                  return Padding(
                    padding: EdgeInsets.only(right: sw * 0.02),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) controller.selectedCategoryFilter.value = cat;
                      },
                      selectedColor: AppColors.camel,
                      backgroundColor: AppColors.offWhite,
                      labelStyle: GoogleFonts.outfit(
                        color: isSelected ? AppColors.white : AppColors.charcoal,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: sw * 0.03,
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
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
        horizontal: sw * 0.03,
        vertical: sw * 0.02,
      ),
      itemCount: controller.filteredProducts.length,
      separatorBuilder: (context, index) => SizedBox(height: sw * 0.02),
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return Container(
          padding: EdgeInsets.all(sw * 0.025),
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
                width: sw * 0.14,
                height: sw * 0.14,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: sw * 0.038,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sw * 0.005),
                    Text(
                      '\$${product.basePrice.toStringAsFixed(2)} • ${product.category}',
                      style: GoogleFonts.outfit(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: sw * 0.032,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.camel, size: sw * 0.055),
                onPressed: () {
                  controller.editProduct(product);
                  Get.to(() => const ProductFormView());
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: sw * 0.055,
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
