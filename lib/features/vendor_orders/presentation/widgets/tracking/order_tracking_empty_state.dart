import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class OrderTrackingEmptyState extends StatelessWidget {
  const OrderTrackingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

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
}
