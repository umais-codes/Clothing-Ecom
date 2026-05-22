import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/screen_header.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_card.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_ping_badge.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_widgets.dart';
import 'package:ecom_app/features/super_admin/presentation/screens/product_moderation_detail_screen.dart';

class CatalogModerationScreen extends GetView<AdminController> {
  const CatalogModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gridPadding = context.wp(2.5).clamp(12.0, 20.0);
    final gridSpacing = context.wp(1.2).clamp(8.0, 14.0);

    int crossAxisCount = 2;
    if (context.isDesktopView) {
      crossAxisCount = 4;
    } else if (context.isTabletView) {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            title: 'Catalogue Moderation',
            subtitle: 'Verify products before institutional publication',
            trailing: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminPingBadge(
                    count: controller.pendingProducts.length,
                    label: 'Pending',
                  ),
                  if (!context.isMobileView &&
                      controller.pendingProducts.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    CustomButton(
                      onPressed: () => _confirmBulkApprove(context),
                      icon: Icons.done_all_rounded,
                      text: 'Approve All',
                      variant: ButtonVariant.primary,
                      buttonColor: AppColors.success,
                      textColor: AppColors.white,
                      height: 38,
                      borderRadius: 8,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => controller.pendingProducts.isEmpty
                  ? const AdminEmptyState(
                      message: 'No products awaiting moderation',
                      icon: Icons.inventory_2_outlined,
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(gridPadding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        childAspectRatio: context.isMobileView ? 0.95 : 1.05,
                      ),
                      itemCount: controller.pendingProducts.length,
                      itemBuilder: (_, i) {
                        final product = controller.pendingProducts[i];
                        return _ProductModerationCard(
                          product: product,
                          onApprove: () =>
                              controller.approveProduct(product.id),
                          onReject: () => controller.rejectProduct(product.id),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBulkApprove(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Bulk Approval',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        content: Text(
          'Publish all ${controller.pendingProducts.length} items to the live store?',
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.ink),
        ),
        actions: [
          CustomButton(
            text: 'Cancel',
            onPressed: () => Get.back(),
            height: 35,
            variant: ButtonVariant.ghost,
            textColor: AppColors.grey,
            width: Get.width * 0.3,
          ),
          const SizedBox(width: 8),
          CustomButton(
            text: 'Confirm',
            onPressed: () {
              Get.back();
              controller.approveAllProducts();
            },
            height: 35,
            variant: ButtonVariant.primary,
            buttonColor: AppColors.success,
            textColor: AppColors.white,
            width: Get.width * 0.3,
          ),
        ],
      ),
    );
  }
}

class _ProductModerationCard extends StatelessWidget {
  const _ProductModerationCard({
    required this.product,
    required this.onApprove,
    required this.onReject,
  });

  final PendingProductEntity product;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      onTap: () =>
          Get.to(() => ProductModerationDetailScreen(product: product)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: context.hp(12).clamp(80, 110),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.greySubtle),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const .symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.vendorName.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  'PKR ${product.price.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.camel,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: onReject,
                        text: 'Reject',
                        variant: ButtonVariant.outlined,
                        height: 30,
                        fontSize: 9,
                        borderRadius: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomButton(
                        onPressed: onApprove,
                        text: 'Approve',
                        variant: ButtonVariant.primary,
                        buttonColor: AppColors.success,
                        height: 30,
                        fontSize: 9,
                        borderRadius: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

