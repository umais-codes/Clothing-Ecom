import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../controllers/tracking_controller.dart';

class OrderPickerModal extends StatelessWidget {
  const OrderPickerModal({super.key});

  static void show(BuildContext context) {
    Get.bottomSheet(
      const OrderPickerModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrackingController>();
    final double sw = context.screenWidth;

    return Container(
      padding: EdgeInsets.all(sw * 0.05),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Order to Track",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.grey),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(height: 16),
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.userOrders.length,
              separatorBuilder: (ctx, idx) =>
                  const Divider(color: AppColors.greySubtle, height: 12),
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
          ),
        ],
      ),
    );
  }
}
