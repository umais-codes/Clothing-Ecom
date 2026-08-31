import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../controllers/tracking_controller.dart';
import 'package:ecom_app/features/post_purchase/presentation/views/review_submission_sheet.dart';
import 'package:ecom_app/features/post_purchase/presentation/controllers/review_controller.dart';
import 'package:ecom_app/features/vendor_orders/domain/entities/vendor_order.dart';

class CustomerTrackingView extends GetView<TrackingController> {
  const CustomerTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: "ORDER TRACKING",
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.userOrders.length > 1) {
              return IconButton(
                tooltip: "Switch Order",
                icon: const Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.charcoal,
                ),
                onPressed: () => _showOrderPickerSheet(context, sw),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.camel),
            ),
          );
        }

        if (controller.hasNoOrders.value || controller.orderId.value.isEmpty) {
          return _buildEmptyState(context, sw);
        }

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(context, sw),
                SizedBox(height: sw * 0.035),
                _buildTimelineCard(context, sw),
                SizedBox(height: sw * 0.035),
                _buildCourierCard(context, sw),
                SizedBox(height: sw * 0.035),
                _buildOrderItemsCard(context, sw),
                SizedBox(height: sw * 0.035),
                _buildShippingAddressCard(context, sw),
                SizedBox(height: sw * 0.035),
                _buildDeliveredActionSection(context, sw),
                SizedBox(height: sw * 0.06),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, double sw) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sw * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: sw * 0.22,
              height: sw * 0.22,
              decoration: BoxDecoration(
                color: AppColors.camel.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 40,
                color: AppColors.camel,
              ),
            ),
            SizedBox(height: sw * 0.05),
            Text(
              "No Active Orders",
              style: GoogleFonts.outfit(
                fontSize: context.sp(18),
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: sw * 0.02),
            Text(
              "You have not placed any orders yet. Explore our curated collections to get started.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: context.sp(13),
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
            SizedBox(height: sw * 0.06),
            CustomButton(
              text: "Explore Collections",
              width: sw * 0.6,
              buttonColor: AppColors.charcoal,
              textColor: AppColors.white,
              onPressed: () => Get.offNamed('/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
                  Text(
                    controller.orderId.value,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: context.sp(16),
                      color: AppColors.charcoal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.orderId.value),
                      );
                      Get.snackbar(
                        'Copied',
                        'Order ID copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(context),
            ],
          ),
          SizedBox(height: sw * 0.02),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.camel,
              ),
              const SizedBox(width: 6),
              Text(
                "Estimated Delivery: ",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(12),
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  controller.expectedDelivery.value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(12),
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (controller.createdAtFormatted.value.isNotEmpty) ...[
            SizedBox(height: sw * 0.01),
            Text(
              "Placed on ${controller.createdAtFormatted.value}",
              style: GoogleFonts.outfit(
                fontSize: context.sp(11),
                color: AppColors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final s = controller.status.value.toLowerCase();
    Color bg = AppColors.camelLight;
    Color fg = AppColors.camelDark;

    if (s.contains('delivered') || s.contains('completed')) {
      bg = AppColors.successBg;
      fg = AppColors.success;
    } else if (s.contains('shipped') || s.contains('transit')) {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0369A1);
    } else if (s.contains('packed') || s.contains('processing')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            controller.status.value.toUpperCase(),
            style: GoogleFonts.outfit(
              color: fg,
              fontSize: context.sp(10),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
              Text(
                "DELIVERY TIMELINE",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Realtime Live",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 22),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.steps.length,
            itemBuilder: (context, index) {
              final step = controller.steps[index];
              final isCompleted = index <= controller.activeStepIndex.value;
              final isCurrent = index == controller.activeStepIndex.value;
              final isLast = index == controller.steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? AppColors.camel
                              : (isCompleted
                                    ? AppColors.charcoal
                                    : AppColors.offWhite),
                          border: Border.all(
                            color: isCompleted
                                ? (isCurrent
                                      ? AppColors.camel
                                      : AppColors.charcoal)
                                : AppColors.greyLight,
                            width: 2,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppColors.camel.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: AppColors.white,
                                )
                              : Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 38,
                          color: index < controller.activeStepIndex.value
                              ? AppColors.charcoal
                              : AppColors.greyLight,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title']!,
                            style: GoogleFonts.outfit(
                              fontWeight: isCurrent
                                  ? FontWeight.w800
                                  : (isCompleted
                                        ? FontWeight.w700
                                        : FontWeight.w500),
                              fontSize: context.sp(13),
                              color: isCompleted
                                  ? AppColors.charcoal
                                  : AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['subtitle']!,
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(11),
                              color: isCompleted
                                  ? AppColors.charcoal.withValues(alpha: 0.7)
                                  : AppColors.greyLight,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourierCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.camel.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.camel,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "LOGISTICS PARTNER",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                controller.courierName.value,
                style: GoogleFonts.outfit(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AWB Tracking Code",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(10),
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.trackingId.value,
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: "Copy Code",
                variant: ButtonVariant.outlined,
                width: sw * 0.28,
                height: sw * 0.09,
                textColor: AppColors.charcoal,
                onPressed: () => controller.copyTrackingId(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
              Text(
                "ITEMS IN THIS PACKAGE (${controller.orderItems.length})",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                "\$${controller.amount.value.toStringAsFixed(2)}",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w900,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 20),
          if (controller.orderItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "No item records found for this order.",
                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.orderItems.length,
              separatorBuilder: (ctx, idx) =>
                  const Divider(color: AppColors.greySubtle, height: 16),
              itemBuilder: (ctx, idx) {
                final item = controller.orderItems[idx];
                final String name =
                    item['product_name']?.toString() ?? 'Product';
                final String img = item['image_url']?.toString() ?? '';
                final double price =
                    (item['unit_price'] as num?)?.toDouble() ?? 0.0;
                final int qty = (item['quantity'] as num?)?.toInt() ?? 1;
                final String size = item['size']?.toString() ?? 'M';
                final String color = item['color']?.toString() ?? '';

                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: img.isNotEmpty
                          ? Image.network(
                              img,
                              width: sw * 0.14,
                              height: sw * 0.14,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                width: sw * 0.14,
                                height: sw * 0.14,
                                color: AppColors.greyLight,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 18,
                                  color: AppColors.grey,
                                ),
                              ),
                            )
                          : Container(
                              width: sw * 0.14,
                              height: sw * 0.14,
                              color: AppColors.greyLight,
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 18,
                                color: AppColors.grey,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: context.sp(13),
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                "Qty: $qty",
                                style: GoogleFonts.outfit(
                                  fontSize: context.sp(11),
                                  color: AppColors.grey,
                                ),
                              ),
                              if (size.isNotEmpty) ...[
                                Text(
                                  " • Size: $size",
                                  style: GoogleFonts.outfit(
                                    fontSize: context.sp(11),
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                              if (color.isNotEmpty) ...[
                                Text(
                                  " • $color",
                                  style: GoogleFonts.outfit(
                                    fontSize: context.sp(11),
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "\$${(price * qty).toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: context.sp(13),
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressCard(BuildContext context, double sw) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.camel,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "DELIVERY DESTINATION",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 20),
          Text(
            controller.customerName.value,
            style: GoogleFonts.outfit(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            controller.shippingAddress.value,
            style: GoogleFonts.outfit(
              fontSize: context.sp(12),
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          if (controller.customerPhone.value.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "Contact: ${controller.customerPhone.value}",
              style: GoogleFonts.outfit(
                fontSize: context.sp(11),
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveredActionSection(BuildContext context, double sw) {
    final isDelivered =
        controller.activeStepIndex.value == controller.steps.length - 1;
    if (!isDelivered) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.camel.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.camel.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Package Delivered",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.015),
          Text(
            "We hope your new wardrobe pieces exceed expectations. You may request an exchange/return within 7 days or leave a verified garment review.",
            style: GoogleFonts.outfit(
              fontSize: context.sp(11),
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          SizedBox(height: sw * 0.04),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "Request RMA Return",
                  variant: ButtonVariant.outlined,
                  textColor: AppColors.charcoal,
                  height: sw * 0.11,
                  onPressed: () {
                    final vendorOrder = VendorOrder(
                      id: controller.orderId.value,
                      customerName: controller.customerName.value,
                      amount: controller.amount.value,
                      status: "Delivered",
                      orderDate: DateTime.now().subtract(
                        const Duration(days: 2),
                      ),
                      isB2B: false,
                      items: controller.orderItems.map((it) {
                        return VendorOrderItem(
                          id: it['product_id']?.toString() ?? 'item_1',
                          name: it['product_name']?.toString() ?? 'Garment',
                          quantity: (it['quantity'] as num?)?.toInt() ?? 1,
                          unitPrice:
                              (it['unit_price'] as num?)?.toDouble() ?? 0.0,
                          imageUrl: it['image_url']?.toString() ?? '',
                          size: it['size']?.toString() ?? 'M',
                          color: it['color']?.toString() ?? '',
                        );
                      }).toList(),
                      timeline: [],
                    );
                    Get.toNamed('/rma-request', arguments: vendorOrder);
                  },
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: CustomButton(
                  text: "Rate & Review",
                  buttonColor: AppColors.camel,
                  textColor: AppColors.white,
                  height: sw * 0.11,
                  onPressed: () {
                    Get.put(ReviewController());
                    final firstItem = controller.orderItems.isNotEmpty
                        ? controller.orderItems.first
                        : null;
                    Get.bottomSheet(
                      ReviewSubmissionSheet(
                        orderId: controller.orderId.value,
                        productId:
                            firstItem?['product_id']?.toString() ?? "prod_1",
                        productName:
                            firstItem?['product_name']?.toString() ?? "Product",
                        productImageUrl:
                            firstItem?['image_url']?.toString() ?? "",
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderPickerSheet(BuildContext context, double sw) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(sw * 0.05),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Order to Track",
              style: GoogleFonts.outfit(
                fontSize: context.sp(16),
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              itemCount: controller.userOrders.length,
              itemBuilder: (ctx, idx) {
                final ord = controller.userOrders[idx];
                final id = ord['id']?.toString() ?? '';
                final isSelected = id == controller.orderId.value;
                final amt = (ord['amount'] as num?)?.toDouble() ?? 0.0;
                final st = ord['status']?.toString() ?? 'Pending';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? AppColors.camel : AppColors.grey,
                  ),
                  title: Text(
                    id,
                    style: GoogleFonts.outfit(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  subtitle: Text(
                    "Status: $st • Total: \$${amt.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.switchOrder(id);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
