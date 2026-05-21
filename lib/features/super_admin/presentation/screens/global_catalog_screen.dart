import 'dart:io';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
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
                    padding: .all(context.wp(1.5).clamp(12.0, 16.0)),
                    borderRadius: 12,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: controller.searchController,
                          hinttext: 'Search products...',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.grey,
                            size: context.sp(18).clamp(16.0, 20.0),
                          ),
                          fillColor: AppColors.offWhite,
                          borderRadius: 10,
                          margin: EdgeInsets.zero,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: context.wp(2).clamp(8, 12),
                            vertical: 10,
                          ),
                          onChanged: (value) =>
                              controller.globalSearchQuery.value = value,
                        ),
                        SizedBox(height: context.hp(1.5).clamp(12.0, 16.0)),
                        // --- Filters Row ---
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownFilter('Category', [
                                'All Categories',
                                'Luxury Wear',
                                'Formal',
                              ]),
                            ),
                            SizedBox(width: context.wp(1.5).clamp(8.0, 12.0)),
                            Expanded(
                              child: _buildDropdownFilter('Status', [
                                'All Status',
                                'Approved',
                                'Pending',
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.hp(2).clamp(12.0, 24.0)),

                  Expanded(
                    child: Obx(
                      () => AdminDataTable<dynamic>(
                        title: 'Product Inventory',
                        columnFlex: const [3, 2, 2, 2, 2, 2],
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
                                        borderRadius: .circular(4),
                                        image: DecorationImage(
                                          image:
                                              item.imageUrl.startsWith('http')
                                              ? NetworkImage(item.imageUrl)
                                                    as ImageProvider
                                              : FileImage(File(item.imageUrl)),
                                          fit: .cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: context.wp(2).clamp(8.0, 16.0),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: .start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: textStyle.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: .ellipsis,
                                          ),
                                          Text(
                                            item.id,
                                            style: textStyle.copyWith(
                                              fontSize: context
                                                  .sp(10.5)
                                                  .clamp(9.0, 12.0),
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(item.vendorName, style: textStyle),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'PKR ${item.price.toStringAsFixed(0)}',
                                  style: textStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(item.category, style: textStyle),
                              ),
                              Expanded(
                                flex: 2,
                                child: AdminStatusBadge(
                                  status: item.status
                                      .toString()
                                      .split('.')
                                      .last,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _showProductDrawer(
                                        context,
                                        product: item,
                                      ),
                                      icon: const Icon(
                                        Icons.edit_note_rounded,
                                        size: 20,
                                      ),
                                      color: AppColors.camel,
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () =>
                                          _confirmDelete(context, item.id),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                      ),
                                      color: AppColors.error,
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
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
        border: .all(
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
                  fontSize: 12,
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
      transition: .rightToLeft,
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
