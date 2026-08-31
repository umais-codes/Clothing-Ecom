import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/tracking_controller.dart';

class OrderItemsCard extends GetView<TrackingController> {
  const OrderItemsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

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
              Obx(
                () => Text(
                  "ITEMS IN THIS PACKAGE (${controller.orderItems.length})",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Obx(
                () => Text(
                  "\$${controller.amount.value.toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w900,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.greySubtle, height: 20),
          Obx(() {
            if (controller.orderItems.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "No item records found for this order.",
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.grey),
                ),
              );
            }

            return ListView.separated(
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
            );
          }),
        ],
      ),
    );
  }
}
