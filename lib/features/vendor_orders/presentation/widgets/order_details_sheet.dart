import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../../domain/entities/vendor_order.dart';
import '../controllers/vendor_order_controller.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'rma_handling_card.dart';

class OrderDetailsSheet extends StatelessWidget {
  final VendorOrder order;
  final VendorOrderController controller;

  const OrderDetailsSheet({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: sw * 0.03,
        left: sw * 0.03,
        right: sw * 0.03,
        bottom: context.paddingBottom + sw * 0.02,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: sw * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: sw * 0.04),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.id,
                        style: GoogleFonts.outfit(
                          fontSize: context.sp(sw * 0.045),
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      _buildB2bBadge(context),
                    ],
                  ),
                  Text(
                    order.customerName,
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(sw * 0.045),
                      fontWeight: FontWeight.w500,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.charcoal,
                ),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          Divider(color: AppColors.greySubtle, height: sw * 0.03),

          // Content scrollable area
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.status == 'Returned') ...[
                    RmaHandlingCard(order: order, controller: controller),
                    SizedBox(height: sw * 0.06),
                  ],

                  // Items section
                  Text(
                    "Items Summary",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: sw * 0.02),

                  if (order.isB2B)
                    _buildB2bVariantMatrix(context, sw)
                  else
                    _buildB2cItemList(context, sw),

                  SizedBox(height: sw * 0.02),

                  // Order Timeline
                  Text(
                    "Fulfillment Timeline",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: sw * 0.04),
                  _buildTimeline(context, sw),

                  SizedBox(height: sw * 0.06),
                ],
              ),
            ),
          ),

          // Bottom Action
          _buildActionPanel(context, sw),
        ],
      ),
    );
  }

  Widget _buildB2bBadge(BuildContext context) {
    if (!order.isB2B) return const SizedBox.shrink();
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
          fontSize: context.sp(9),
          color: AppColors.camel,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildB2cItemList(BuildContext context, double sw) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      itemBuilder: (context, index) {
        final item = order.items[index];
        return Container(
          margin: EdgeInsets.only(bottom: sw * 0.03),
          padding: EdgeInsets.all(sw * 0.03),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl,
                  width: sw * 0.14,
                  height: sw * 0.14,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: sw * 0.14,
                    height: sw * 0.14,
                    color: AppColors.greyLight,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(14),
                        color: AppColors.charcoal,
                      ),
                    ),
                    SizedBox(height: sw * 0.005),
                    Text(
                      "Color: ${item.color ?? 'N/A'}  •  Size: ${item.size ?? 'N/A'}",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(12),
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
                    "\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: context.sp(14),
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    "${item.quantity}x @ \$${item.unitPrice.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(11),
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildB2bVariantMatrix(BuildContext context, double sw) {
    final sizes = order.b2bSizes ?? [];
    final colors = order.b2bColors ?? [];
    final matrix = order.b2bMatrix ?? {};

    final double colWidth = sw * 0.13;
    final double colorColWidth = sw * 0.25;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            horizontalMargin: 12,
            columnSpacing: 12,
            columns: [
              DataColumn(
                label: SizedBox(
                  width: colorColWidth,
                  child: Text(
                    "Color / Size",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: context.sp(10),
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ),
              ...sizes.map(
                (size) => DataColumn(
                  label: SizedBox(
                    width: colWidth,
                    child: Center(
                      child: Text(
                        size,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: context.sp(10),
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: colWidth,
                  child: Center(
                    child: Text(
                      "Total",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: context.sp(10),
                        color: AppColors.camel,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            rows: [
              ...colors.map((color) {
                final rowData = matrix[color] ?? {};
                int colorTotal = 0;
                for (final val in rowData.values) {
                  colorTotal += val;
                }

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: colorColWidth,
                        child: Text(
                          color,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: context.sp(12),
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                    ),
                    ...sizes.map((size) {
                      final count = rowData[size] ?? 0;
                      return DataCell(
                        SizedBox(
                          width: colWidth,
                          child: Center(
                            child: Text(
                              count > 0 ? count.toString() : "-",
                              style: GoogleFonts.outfit(
                                fontWeight: count > 0
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontSize: context.sp(12),
                                color: count > 0
                                    ? AppColors.charcoal
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    DataCell(
                      SizedBox(
                        width: colWidth,
                        child: Center(
                          child: Text(
                            colorTotal.toString(),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: context.sp(12),
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              // Total Row
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      "Grand Total",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: context.sp(10),
                        color: AppColors.camel,
                      ),
                    ),
                  ),
                  ...sizes.map((size) {
                    int sizeTotal = 0;
                    for (final c in colors) {
                      sizeTotal += (matrix[c]?[size] ?? 0);
                    }
                    return DataCell(
                      Center(
                        child: Text(
                          sizeTotal.toString(),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: context.sp(12),
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    Center(
                      child: Text(
                        _getGrandTotal().toString(),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: context.sp(13),
                          color: AppColors.camel,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getGrandTotal() {
    int total = 0;
    final matrix = order.b2bMatrix ?? {};
    for (final sizeMap in matrix.values) {
      for (final qty in sizeMap.values) {
        total += qty;
      }
    }
    return total;
  }

  Widget _buildTimeline(BuildContext context, double sw) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.timeline.length,
      itemBuilder: (context, index) {
        final step = order.timeline[index];
        final isLast = index == order.timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicator column
            Column(
              children: [
                Container(
                  width: sw * 0.035,
                  height: sw * 0.035,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted
                        ? AppColors.camel
                        : AppColors.greyLight,
                    border: Border.all(
                      color: step.isCompleted
                          ? AppColors.camelLight
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1.5,
                    height: sw * 0.1,
                    color: step.isCompleted
                        ? AppColors.camel
                        : AppColors.greyLight,
                  ),
              ],
            ),
            SizedBox(width: sw * 0.04),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: context.sp(13),
                      color: step.isCompleted
                          ? AppColors.charcoal
                          : AppColors.grey,
                    ),
                  ),
                  Text(
                    step.description,
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(11),
                      color: AppColors.grey,
                    ),
                  ),
                  if (step.timestamp != null) ...[
                    SizedBox(height: sw * 0.01),
                    Text(
                      "${step.timestamp!.hour}:${step.timestamp!.minute.toString().padLeft(2, '0')} • ${_getMonthDay(step.timestamp!)}",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(9),
                        color: AppColors.grey.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: sw * 0.04),
                ],
              ),
            ),
          ],
        );
      },
    );
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

  Widget _buildActionPanel(BuildContext context, double sw) {
    if (order.status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Accept Order",
              variant: ButtonVariant.primary,
              buttonColor: AppColors.camel,
              textColor: AppColors.white,
              onPressed: () {
                controller.acceptOrder(order.id);
              },
            ),
          ),
        ],
      );
    } else if (order.status == 'Processing') {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Proceed to Fulfillment",
              variant: ButtonVariant.primary,
              buttonColor: AppColors.camel,
              textColor: AppColors.white,
              onPressed: () {
                Get.back();
                Get.toNamed('/fulfillment-checklist', arguments: order);
              },
            ),
          ),
        ],
      );
    } else if (order.status == 'Returned') {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Process Refund",
              variant: ButtonVariant.primary,
              buttonColor: AppColors.error,
              textColor: AppColors.white,
              onPressed: () {
                controller.processReturn(order.id);
                Get.back();
              },
            ),
          ),
        ],
      );
    } else {
      // Shipped or other status
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Print Packing Slip",
              variant: ButtonVariant.outlined,
              onPressed: () {
                Get.snackbar(
                  'Slip Generated',
                  'Fulfillment slip for ${order.id} sent to cloud printer.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  colorText: AppColors.success,
                );
              },
            ),
          ),
        ],
      );
    }
  }
}
