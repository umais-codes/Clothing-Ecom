import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import '../../domain/entities/vendor_order.dart';

class ShippingLabelModal extends StatelessWidget {
  final VendorOrder order;
  final String? courier;
  final String? trackingNumber;
  final double? weight;

  const ShippingLabelModal({
    super.key,
    required this.order,
    this.courier,
    this.trackingNumber,
    this.weight,
  });

  static void show({
    required BuildContext context,
    required VendorOrder order,
    String? courier,
    String? trackingNumber,
    double? weight,
  }) {
    Get.bottomSheet(
      ShippingLabelModal(
        order: order,
        courier: courier,
        trackingNumber: trackingNumber,
        weight: weight,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final String activeCourier =
        courier ?? order.courierPartner ?? "Trax Logistics";
    final String activeAwb =
        trackingNumber ??
        order.trackingNumber ??
        "TRX-${order.id.replaceAll('#', '')}-PK";
    final double activeWeight = weight ?? order.packageWeight ?? 1.2;

    return Container(
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.88),
      padding: EdgeInsets.all(sw * 0.05),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.print_outlined,
                        color: AppColors.charcoal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Shipping Label & Packing Slip",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.grey),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(height: 20),

            // Printable Thermal Label Container
            Container(
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.charcoal, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "VALVET MAISON",
                        style: GoogleFonts.cinzel(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.charcoal,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "AIRWAY BILL (AWB)",
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(8),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: AppColors.charcoal,
                    thickness: 1.2,
                    height: 16,
                  ),

                  // Courier & AWB Barcode Simulation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "LOGISTICS PARTNER",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(9),
                              fontWeight: FontWeight.w800,
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            activeCourier,
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.w800,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "WEIGHT: ${activeWeight}kg",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(11),
                              fontWeight: FontWeight.w800,
                              color: AppColors.charcoal,
                            ),
                          ),
                          Text(
                            "PREPAID • 0 COD",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(9),
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Visual Barcode Bar
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 32,
                            color: AppColors.charcoal,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activeAwb,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.greyLight, height: 20),

                  // Shipper / Consignee Address Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SHIP FROM:",
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(9),
                                fontWeight: FontWeight.w800,
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Valvet Maison Hub",
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(11),
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                              ),
                            ),
                            Text(
                              "Sector 5, Industrial Area, Karachi",
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(10),
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Receiver
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SHIP TO (CONSIGNEE):",
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(9),
                                fontWeight: FontWeight.w800,
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.customerName,
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(11),
                                fontWeight: FontWeight.w800,
                                color: AppColors.charcoal,
                              ),
                            ),
                            Text(
                              order.shippingAddress ??
                                  "Customer Shipping Address",
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(10),
                                color: AppColors.charcoal,
                              ),
                            ),
                            if (order.customerPhone != null) ...[
                              Text(
                                "Tel: ${order.customerPhone}",
                                style: GoogleFonts.outfit(
                                  fontSize: context.sp(10),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.greyLight, height: 20),

                  // Packing Manifest Items
                  Text(
                    "PACKING MANIFEST (${order.items.length} Items)",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(9),
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...order.items.map((it) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "• ${it.name} (${it.size ?? 'M'} / ${it.color ?? 'Std'})",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(11),
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ),
                          Text(
                            "x${it.quantity}",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(11),
                              fontWeight: FontWeight.w800,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Share Digital AWB",
                    variant: ButtonVariant.outlined,
                    height: sw * 0.11,
                    textColor: AppColors.charcoal,
                    onPressed: () {
                      Get.snackbar(
                        'AWB Shared',
                        'Shipping label link generated for courier portal.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.camelLight,
                        colorText: AppColors.charcoal,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: "Print Label",
                    buttonColor: AppColors.charcoal,
                    textColor: AppColors.white,
                    height: sw * 0.11,
                    onPressed: () {
                      Get.snackbar(
                        'Sent to Printer',
                        'Airway Bill $activeAwb queued on thermal label printer.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.successBg,
                        colorText: AppColors.success,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
