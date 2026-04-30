import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/b2b_portal_controller.dart';

class MatrixOrderWidget extends GetView<B2BPortalController> {
  const MatrixOrderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.06),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMatrixHeader(sw),
          SizedBox(height: sw * 0.04),
          ...controller.colors.map((color) => _buildMatrixRow(sw, color)).toList(),
          SizedBox(height: sw * 0.06),
          _buildMatrixFooter(sw),
        ],
      ),
    );
  }

  Widget _buildMatrixHeader(double sw) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text("COLOR", style: _headerStyle(sw))),
        ...controller.sizes.map((size) => Expanded(
          child: Center(child: Text(size, style: _headerStyle(sw))),
        )).toList(),
      ],
    );
  }

  Widget _buildMatrixRow(double sw, Map<String, dynamic> color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.015),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: sw * 0.04,
                  height: sw * 0.04,
                  decoration: BoxDecoration(
                    color: Color(color['hex'] as int),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: sw * 0.02),
                Expanded(
                  child: Text(
                    color['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: sw * 0.028,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ...controller.sizes.map((size) => Expanded(
            child: Container(
              height: sw * 0.1,
              margin: EdgeInsets.symmetric(horizontal: sw * 0.005),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(sw * 0.02),
                border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.5), width: 0.5),
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: sw * 0.035, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                onChanged: (val) {
                  final qty = int.tryParse(val) ?? 0;
                  controller.updateMatrixQuantity(size, color['name'] as String, qty);
                },
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMatrixFooter(double sw) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.camel.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL UNITS",
                style: TextStyle(color: AppColors.grey, fontSize: sw * 0.025, fontWeight: FontWeight.w700),
              ),
              Obx(() => Text(
                "${controller.totalMatrixQuantity} Units",
                style: TextStyle(color: AppColors.charcoal, fontSize: sw * 0.04, fontWeight: FontWeight.w800),
              )),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "EST. WHOLESALE TOTAL",
                style: TextStyle(color: AppColors.grey, fontSize: sw * 0.025, fontWeight: FontWeight.w700),
              ),
              Obx(() => Text(
                "\$${controller.totalMatrixPrice.toStringAsFixed(2)}",
                style: TextStyle(color: AppColors.camel, fontSize: sw * 0.045, fontWeight: FontWeight.w900),
              )),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(double sw) => TextStyle(
    color: AppColors.grey,
    fontWeight: FontWeight.w700,
    fontSize: sw * 0.022,
    letterSpacing: 0.5,
  );
}
