import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../controllers/vendor_order_controller.dart';
import '../../domain/entities/vendor_order.dart';
import '../widgets/order_details_sheet.dart';
import '../widgets/shipping_label_modal.dart';
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';

class VendorOrdersView extends GetView<VendorOrderController> {
  const VendorOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: const CustomAppBar(
        title: "Fulfillment Workspace",
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sub-header displaying active count
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sw * 0.01,
              ),
              child: Obx(() {
                final count = controller.filteredOrders.length;
                return Text(
                  "Showing $count active ${count == 1 ? 'order' : 'orders'}",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(sw * 0.03),
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                );
              }),
            ),

            // Horizontal Tab Bar
            _buildTabBar(context, sw),
            SizedBox(height: sw * 0.005),

            // Orders list
            Expanded(
              child: Obx(() {
                final list = controller.filteredOrders;
                if (list.isEmpty) {
                  return _buildEmptyState(context, sw);
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final order = list[index];
                    return _buildOrderCard(context, order, sw);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, double sw) {
    return SizedBox(
      height: sw * 0.1,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
        itemCount: controller.tabs.length,
        itemBuilder: (context, index) {
          final tabName = controller.tabs[index];
          return Obx(() {
            final isSelected = controller.selectedTab.value == tabName;
            return GestureDetector(
              onTap: () => controller.selectedTab.value = tabName,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(
                  horizontal: sw * 0.01,
                  vertical: 2,
                ),
                padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.camel : AppColors.white,
                  borderRadius: BorderRadius.circular(sw * 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.charcoal.withValues(
                        alpha: isSelected ? 0.12 : 0.03,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  tabName,
                  style: GoogleFonts.outfit(
                    color: isSelected ? AppColors.white : AppColors.charcoal,
                    fontSize: context.sp(sw * 0.03),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double sw) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.charcoal.withValues(alpha: 0.03),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: sw * 0.12,
              color: AppColors.camel.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: sw * 0.05),
          Text(
            "No Orders Found",
            style: GoogleFonts.playfairDisplay(
              fontSize: context.sp(20),
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(height: sw * 0.01),
          Text(
            "There are currently no orders in this category.",
            style: GoogleFonts.outfit(
              fontSize: context.sp(12),
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, VendorOrder order, double sw) {
    Color statusColor = AppColors.grey;
    if (order.status == 'Pending') {
      statusColor = AppColors.camel;
    } else if (order.status == 'Processing') {
      statusColor = AppColors.rose;
    } else if (order.status == 'Shipped') {
      statusColor = AppColors.success;
    } else if (order.status == 'Returned') {
      statusColor = AppColors.error;
    }

    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          OrderDetailsSheet(order: order, controller: controller),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: sw * 0.02),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sw * 0.01,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.greyLight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status Ribbon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: context.sp(14),
                    color: AppColors.charcoal,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02,
                    vertical: sw * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: statusColor,
                      fontSize: context.sp(9),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sw * 0.01),

            // Customer Name & Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: GoogleFonts.outfit(
                          fontSize: context.sp(sw * 0.035),
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      SizedBox(height: sw * 0.005),
                      Text(
                        "${_getMonthDay(order.orderDate)}  •  ${order.items.length} ${_getItemsText(order)}",
                        style: GoogleFonts.outfit(
                          fontSize: context.sp(sw * 0.028),
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${order.amount.toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: context.sp(sw * 0.035),
                        color: AppColors.charcoal,
                      ),
                    ),
                    SizedBox(height: sw * 0.01),
                    _buildB2bBadge(context, order, sw),
                  ],
                ),
              ],
            ),

            Divider(color: AppColors.greySubtle, height: sw * 0.04),

            // Card Quick Action
            _buildCardQuickAction(context, order, sw),
          ],
        ),
      ),
    );
  }

  Widget _buildB2bBadge(BuildContext context, VendorOrder order, double sw) {
    if (!order.isB2B) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.02,
          vertical: sw * 0.005,
        ),
        decoration: BoxDecoration(
          color: AppColors.greySubtle,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "B2C RETAIL",
          style: GoogleFonts.outfit(
            fontSize: context.sp(8),
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.camelLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.camel.withValues(alpha: 0.3)),
      ),
      child: Text(
        "B2B BULK",
        style: GoogleFonts.outfit(
          fontSize: context.sp(8),
          color: AppColors.camel,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCardQuickAction(
    BuildContext context,
    VendorOrder order,
    double sw,
  ) {
    final s = order.status.toLowerCase();

    if (s == 'pending' || s == 'paid' || s == 'authorized') {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: CustomButton(
              text: "Decline",
              variant: ButtonVariant.outlined,
              textColor: AppColors.error,
              height: sw * 0.1,
              fontSize: context.sp(12),
              onPressed: () => _showRejectOrderDialog(context, order),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: "Accept Order",
              variant: ButtonVariant.primary,
              buttonColor: AppColors.camel,
              textColor: AppColors.white,
              height: sw * 0.1,
              fontSize: context.sp(12),
              onPressed: () => controller.acceptOrder(order.id),
            ),
          ),
        ],
      );
    } else if (s == 'processing' || s == 'packed') {
      return CustomButton(
        text: "Fulfill & Ship",
        variant: ButtonVariant.primary,
        buttonColor: AppColors.camel,
        textColor: AppColors.white,
        height: sw * 0.1,
        fontSize: context.sp(12),
        onPressed: () =>
            Get.toNamed('/fulfillment-checklist', arguments: order),
      );
    } else if (s == 'returned' || s == 'cancelled' || s == 'refunded') {
      return CustomButton(
        text: "Process Refund",
        variant: ButtonVariant.primary,
        buttonColor: AppColors.error,
        textColor: AppColors.white,
        height: sw * 0.1,
        fontSize: context.sp(12),
        onPressed: () => controller.processReturn(order.id),
      );
    } else if (s == 'shipped') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "AWB: ${order.trackingNumber ?? 'In Transit'}",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomButton(
                    text: "Slip",
                    variant: ButtonVariant.outlined,
                    height: 28,
                    width: sw * 0.14,
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.w600,
                    onPressed: () {
                      ShippingLabelModal.show(context: context, order: order);
                    },
                  ),
                  const SizedBox(width: 6),
                  CustomButton(
                    text: "Track",
                    variant: ButtonVariant.outlined,
                    textColor: AppColors.camel,
                    height: 28,
                    width: sw * 0.14,
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.w600,
                    onPressed: () {
                      Get.toNamed('/vendor-tracking');
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: "Mark As Delivered",
            variant: ButtonVariant.primary,
            buttonColor: AppColors.success,
            textColor: AppColors.white,
            height: sw * 0.09,
            fontSize: context.sp(11),
            onPressed: () => controller.markAsDelivered(order.id),
          ),
        ],
      );
    } else if (s == 'delivered') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
            const SizedBox(width: 6),
            Text(
              "Delivered • Fulfilled Successfully",
              style: GoogleFonts.outfit(
                fontSize: context.sp(11),
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  String _getMonthDay(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
  }

  String _getItemsText(VendorOrder order) {
    if (order.isB2B) {
      int totalItems = 0;
      if (order.b2bMatrix != null) {
        for (final sizeMap in order.b2bMatrix!.values) {
          for (final qty in sizeMap.values) {
            totalItems += qty;
          }
        }
      }
      return "items ($totalItems units)";
    }
    int totalItems = 0;
    for (final item in order.items) {
      totalItems += item.quantity;
    }
    return totalItems == 1 ? "item" : "items";
  }

  void _showRejectOrderDialog(BuildContext context, VendorOrder order) {
    final reasons = [
      'Item Out of Stock / Fabric Defect',
      'Bespoke Size / Pattern Unavailable',
      'Delivery Address Unserviceable',
      'Catalog Pricing / Quantity Error',
      'Suspected Fraud / Duplicate Order',
    ];
    final selectedReason = reasons.first.obs;
    final notesController = TextEditingController();

    CustomPermissionDialog.show(
      context: context,
      icon: Icons.cancel_outlined,
      iconColor: AppColors.error,
      iconBgColor: AppColors.errorBg,
      grantButtonColor: AppColors.error,
      title: 'Decline Order ${order.id}',
      description:
          'Select a reason for declining this order. A full customer refund will be initiated immediately.',
      content: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...reasons.map((r) {
              final isSel = selectedReason.value == r;
              return InkWell(
                onTap: () => selectedReason.value = r,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isSel
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 16,
                        color: isSel ? AppColors.error : AppColors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r,
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(11),
                            fontWeight:
                                isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppColors.charcoal : AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            CustomTextField(
              controller: notesController,
              hinttext: 'Additional notes (optional)',
            ),
          ],
        ),
      ),
      grantText: 'Decline & Refund',
      denyText: 'Keep Order',
      onGrant: () {
        final reasonText = notesController.text.trim().isNotEmpty
            ? '${selectedReason.value} - ${notesController.text.trim()}'
            : selectedReason.value;
        controller.rejectOrder(order.id, reasonText);
      },
    );
  }
}
