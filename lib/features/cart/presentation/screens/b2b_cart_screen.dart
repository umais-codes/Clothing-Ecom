import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_stepper.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import 'package:ecom_app/features/navigation/presentation/controllers/main_navigation_controller.dart';
import '../controllers/b2b_cart_controller.dart';

class B2BCartScreen extends StatefulWidget {
  const B2BCartScreen({super.key});

  @override
  State<B2BCartScreen> createState() => _B2BCartScreenState();
}

class _B2BCartScreenState extends State<B2BCartScreen> {
  @override
  Widget build(BuildContext context) {
    final B2BCartController controller = Get.find<B2BCartController>();
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: CustomAppBar(
        title: "Corporate Procurement",
        actions: [
          CustomButton(
            text: "Import CSV",
            onPressed: () => _showCsvImportDialog(context, controller, sw),
            variant: ButtonVariant.ghost,
            icon: Icons.upload_file,
            textColor: AppColors.camel,
            height: 35,
            fontSize: sw * 0.032,
            fontWeight: FontWeight.w600,
          ),
          Obx(() {
            if (controller.cartItems.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: "Clear bulk cart",
              onPressed: () => _confirmClearCart(context, controller),
              icon: const Icon(Icons.delete_outline, color: AppColors.charcoal),
            );
          }),
          SizedBox(width: sw * 0.01),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return _buildEmptyState(context, sw, controller);
        }

        return CustomScrollView(
          slivers: [
            // 1. Interactive Volume Pricing Tier Banner
            SliverToBoxAdapter(
              child: _buildVolumeTierBanner(sw, controller),
            ),

            // 2. Real Product Matrix Cards List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final group = controller.groupedProducts[index];
                  return _buildProductGroupCard(group, sw, controller);
                },
                childCount: controller.groupedProducts.length,
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: sw * 0.1),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.cartItems.isEmpty) return const SizedBox.shrink();
        return _buildB2BBottomBar(sw, controller);
      }),
    );
  }

  void _confirmClearCart(BuildContext context, B2BCartController controller) {
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      title: "Clear Bulk Procurement Cart?",
      description: "Are you sure you want to remove all wholesale lines from your cart?",
      grantText: "Clear All",
      denyText: "Cancel",
      onGrant: () => controller.clearCart(),
    );
  }

  Widget _buildVolumeTierBanner(double sw, B2BCartController controller) {
    final int totalUnits = controller.totalQuantity;
    final String tierName = controller.activeTierName;
    final nextInfo = controller.nextTierInfo;
    final int unitsNeeded = nextInfo['unitsNeeded'] as int;
    final double bulkSavings = controller.bulkSavings;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.03, sw * 0.04, sw * 0.02),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: AppColors.camel.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: AppColors.camel, size: sw * 0.055),
                  SizedBox(width: sw * 0.02),
                  Text(
                    tierName,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              if (bulkSavings > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sw * 0.008),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(sw * 0.015),
                  ),
                  child: Text(
                    "Saved \$${bulkSavings.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: sw * 0.025),

          // Tier Progression Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(sw * 0.02),
            child: LinearProgressIndicator(
              value: (totalUnits / 500).clamp(0.05, 1.0),
              minHeight: sw * 0.02,
              backgroundColor: AppColors.greySubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.camel),
            ),
          ),
          SizedBox(height: sw * 0.02),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$totalUnits Units in Order",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
              Text(
                unitsNeeded > 0
                    ? "Add $unitsNeeded units for ${nextInfo['nextTier']}"
                    : "Maximum Volume Discount Unlocked (30%)",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w600,
                  color: unitsNeeded > 0 ? AppColors.camel : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductGroupCard(
    B2BProductGroup group,
    double sw,
    B2BCartController controller,
  ) {
    final double tieredUnitPrice = controller.getTieredPrice(
      group.unitBasePrice,
      controller.totalQuantity,
    );

    return Container(
      margin: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.03),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Image, Style Name, Vendor & Delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(sw * 0.025),
                child: Image.network(
                  group.imageUrl.isNotEmpty
                      ? group.imageUrl
                      : 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=600&h=600&fit=crop',
                  width: sw * 0.16,
                  height: sw * 0.18,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: sw * 0.16,
                    height: sw * 0.18,
                    color: AppColors.greySubtle,
                    child: const Icon(Icons.broken_image, color: AppColors.grey),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sw * 0.005),
                    Text(
                      group.vendorName,
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.028,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: sw * 0.015),
                    Row(
                      children: [
                        Text(
                          "\$${tieredUnitPrice.toStringAsFixed(2)} / unit",
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.034,
                            fontWeight: FontWeight.w700,
                            color: AppColors.camel,
                          ),
                        ),
                        if (controller.activeDiscountRate > 0) ...[
                          SizedBox(width: sw * 0.02),
                          Text(
                            "\$${group.unitBasePrice.toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.028,
                              color: AppColors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: AppColors.grey, size: 20),
                onPressed: () => controller.removeProductFamily(group.baseProductId),
              ),
            ],
          ),

          SizedBox(height: sw * 0.025),
          const Divider(color: AppColors.greyLight, thickness: 0.8),
          SizedBox(height: sw * 0.02),

          // Matrix Column Headers
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text("VARIANT (SIZE / COLOR)", style: _matrixHeaderStyle(sw)),
              ),
              Expanded(
                flex: 3,
                child: Center(child: Text("QUANTITY", style: _matrixHeaderStyle(sw))),
              ),
              Expanded(
                flex: 2,
                child: Text("LINE TOTAL", textAlign: TextAlign.right, style: _matrixHeaderStyle(sw)),
              ),
            ],
          ),
          SizedBox(height: sw * 0.015),

          // Matrix Rows for each variant
          ...group.variants.map((variant) {
            final lineTotal = tieredUnitPrice * variant.quantity;
            final displayVariant = "${variant.size ?? 'M'} • ${variant.color ?? 'Standard'}";

            return Padding(
              padding: EdgeInsets.symmetric(vertical: sw * 0.012),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      displayVariant,
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.032,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: CustomStepper(
                        value: variant.quantity,
                        onChanged: (newQty) => controller.updateQuantity(variant.id, newQty),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "\$${lineTotal.toStringAsFixed(2)}",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.034,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: sw * 0.02),

          // Style Summary Footer with MOQ Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sw * 0.02),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      group.isMoqMet ? Icons.check_circle : Icons.info_outline,
                      size: sw * 0.035,
                      color: group.isMoqMet ? AppColors.success : AppColors.warning,
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      group.isMoqMet
                          ? "MOQ Met (${group.totalQuantity}/${group.moq} Units)"
                          : "MOQ: Min ${group.moq} Units required (${group.totalQuantity} in cart)",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.028,
                        fontWeight: FontWeight.w600,
                        color: group.isMoqMet ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${group.totalQuantity} PCS",
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _matrixHeaderStyle(double sw) => GoogleFonts.outfit(
    fontSize: sw * 0.026,
    fontWeight: FontWeight.w700,
    color: AppColors.grey,
    letterSpacing: 0.8,
  );

  Widget _buildEmptyState(BuildContext context, double sw, B2BCartController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: sw * 0.25,
              height: sw * 0.25,
              decoration: BoxDecoration(
                color: AppColors.camel.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_center_outlined,
                size: sw * 0.12,
                color: AppColors.camel,
              ),
            ),
            SizedBox(height: sw * 0.04),
            Text(
              "No Bulk Procurement Items",
              style: GoogleFonts.outfit(
                fontSize: sw * 0.05,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: sw * 0.015),
            Text(
              "Your corporate cart is empty. Add bulk apparel styles from Line Sheets or import a CSV procurement order.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: sw * 0.033,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
            SizedBox(height: sw * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: "Browse Portal",
                  width: sw * 0.4,
                  height: sw * 0.11,
                  buttonColor: AppColors.charcoal,
                  textColor: AppColors.white,
                  onPressed: () {
                    if (Get.isRegistered<MainNavigationController>()) {
                      Get.find<MainNavigationController>().changeTab(0);
                    } else {
                      Get.toNamed('/b2b-portal');
                    }
                  },
                ),
                SizedBox(width: sw * 0.03),
                CustomButton(
                  text: "Load Sample",
                  width: sw * 0.38,
                  height: sw * 0.11,
                  variant: ButtonVariant.outlined,
                  onPressed: () => controller.loadSampleB2BOrder(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildB2BBottomBar(double sw, B2BCartController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.06)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Volume",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.03,
                        color: AppColors.grey,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "${controller.totalQuantity} PCS",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.045,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Est. Wholesale Total",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.03,
                        color: AppColors.grey,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "\$${controller.subtotal.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.055,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: sw * 0.025),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Request Quote",
                    variant: ButtonVariant.outlined,
                    height: sw * 0.115,
                    onPressed: () => Get.toNamed('/checkout', arguments: {
                      'isB2B': true,
                      'initialOption': 'Quote',
                    }),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: CustomButton(
                    text: "Submit PO",
                    variant: ButtonVariant.primary,
                    height: sw * 0.115,
                    onPressed: () => Get.toNamed('/checkout', arguments: {
                      'isB2B': true,
                      'initialOption': 'PO',
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCsvImportDialog(
    BuildContext context,
    B2BCartController controller,
    double sw,
  ) {
    final textController = TextEditingController();
    textController.text =
        "Bulk Cotton Uniform Polos, M, Navy, 50, 12.50\n"
        "Bulk Cotton Uniform Polos, L, Black, 50, 12.50\n"
        "Executive Oxford Shirt, L, Classic White, 25, 28.00";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.04)),
        title: Row(
          children: [
            Icon(Icons.upload_file, color: AppColors.camel, size: sw * 0.06),
            SizedBox(width: sw * 0.02),
            Text(
              "Import Bulk CSV",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: sw * 0.045,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Format: Product Name, Size, Color, Quantity, Unit Price",
              style: GoogleFonts.outfit(fontSize: sw * 0.028, color: AppColors.grey),
            ),
            SizedBox(height: sw * 0.02),
            Container(
              height: sw * 0.35,
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(sw * 0.02),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: TextField(
                controller: textController,
                maxLines: null,
                style: GoogleFonts.outfit(fontSize: sw * 0.03),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.outfit(color: AppColors.grey)),
          ),
          CustomButton(
            text: "Import to Cart",
            width: sw * 0.35,
            height: sw * 0.1,
            buttonColor: AppColors.camel,
            textColor: AppColors.white,
            onPressed: () {
              final success = controller.importCsvData(textController.text);
              Navigator.pop(ctx);
              if (success) {
                Get.snackbar(
                  "CSV Imported",
                  "Bulk order items added to procurement cart.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.camel,
                  colorText: AppColors.white,
                );
              } else {
                Get.snackbar(
                  "Import Failed",
                  "Please check CSV format.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  colorText: AppColors.error,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
