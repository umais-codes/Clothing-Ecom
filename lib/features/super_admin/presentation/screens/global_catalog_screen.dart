import 'dart:io';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/admin_crud_controller.dart';
import '../widgets/admin_card.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/screen_header.dart';
import 'global_catalog_edit_screen.dart';

class GlobalCatalogScreen extends GetView<AdminCrudController> {
  const GlobalCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(
            title: 'Global Catalog Management',
            subtitle: 'Audit and manage products across all platform vendors.',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(context.wp(2.5).clamp(16.0, 32.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Search & Filter Bar ────────────────────────────────────────────
                  AdminCard(
                    padding: EdgeInsets.all(context.wp(1.2).clamp(6.0, 12.0)),
                    borderRadius: 12,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.greyLight.withValues(alpha: 0.8),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: AppColors.grey,
                                  size: context.sp(18).clamp(16.0, 20.0),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppColors.charcoal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search products...',
                                      hintStyle: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: AppColors.grey.withValues(alpha: 0.6),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                    ),
                                    cursorColor: AppColors.camel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: context.wp(1).clamp(4.0, 8.0)),
                        Expanded(
                          flex: 1,
                          child: _buildDropdownFilter('Category', [
                            'All Categories',
                            'Luxury Wear',
                            'Formal',
                          ]),
                        ),
                        SizedBox(width: context.wp(1).clamp(4.0, 8.0)),
                        Expanded(
                          flex: 1,
                          child: _buildDropdownFilter('Status', [
                            'All Status',
                            'Approved',
                            'Pending',
                          ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.hp(2).clamp(12.0, 24.0)),

                  Expanded(
                    child: Obx(
                      () => AdminDataTable<dynamic>(
                        title: 'Product Inventory',
                        columnFlex: const [3, 2, 2, 2, 2, 1],
                        columns: const [
                          'Product',
                          'Vendor',
                          'Price',
                          'Category',
                          'Status',
                          'Actions',
                        ],
                        items: controller.allProducts.toList(),
                        onAddPressed: () => _showProductDrawer(context),
                        rowBuilder: (item) {
                          final textStyle = GoogleFonts.outfit(
                            fontSize: context.sp(12.5).clamp(11.0, 14.0),
                            color: AppColors.charcoal,
                          );

                          return Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                      Container(
                                        width: context.wp(3.5).clamp(28, 32),
                                        height: context.wp(3.5).clamp(28, 32),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          image: DecorationImage(
                                            image: item.imageUrl.startsWith('http')
                                                ? NetworkImage(item.imageUrl) as ImageProvider
                                                : FileImage(File(item.imageUrl)),
                                            fit: .cover,
                                          ),
                                        ),
                                      ),
                                    SizedBox(
                                      width: context.wp(2).clamp(8.0, 16.0),
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: GoogleFonts.outfit(
                                          fontWeight: .w600,
                                          fontSize: context
                                              .sp(12)
                                              .clamp(11.0, 14.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item.vendorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyle.copyWith(
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'PKR ${item.price.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: context
                                        .sp(12.5)
                                        .clamp(11.0, 14.0),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.charcoal,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item.category,
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: context.sp(12).clamp(11.0, 14.0),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: AdminStatusBadge(
                                    status: item.status
                                        .toString()
                                        .split('.')
                                        .last,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: .end,
                                  mainAxisSize: .min,
                                  children: [
                                    InkWell(
                                      onTap: () => _showProductDrawer(
                                        context,
                                        product: item,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: AppColors.camel,
                                      ),
                                    ),
                                    SizedBox(width: context.wp(1.5)),
                                    InkWell(
                                      onTap: () =>
                                          _confirmDelete(context, item.id),
                                      child: Icon(
                                        Icons.delete_forever,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    SizedBox(width: context.wp(4.5)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label, List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.8),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.first,
          isExpanded: true,
          icon: const Icon(
            Icons.unfold_more_rounded,
            size: 16,
            color: AppColors.grey,
          ),
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AppColors.charcoal,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  void _showProductDrawer(BuildContext context, {dynamic product}) {
    Get.to(
      () => const GlobalCatalogEditScreen(),
      arguments: product,
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Product?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        content: Text(
          'This will permanently remove this item from the platform catalog. This action cannot be undone.',
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.grey),
        ),
        actions: [
          CustomButton(
            text: 'Cancel',
            onPressed: () => Get.back(),
            height: 35,
            variant: ButtonVariant.outlined,
            textColor: AppColors.grey,
            width: Get.width * 0.3,
          ),
          const Spacer(),
          CustomButton(
            text: 'Delete',
            onPressed: () {
              controller.deleteProduct(id);
              Get.back();
            },
            height: 35,
            variant: ButtonVariant.primary,
            buttonColor: AppColors.error,
            textColor: AppColors.white,
            width: Get.width * 0.3,
          ),
        ],
      ),
    );
  }
}
