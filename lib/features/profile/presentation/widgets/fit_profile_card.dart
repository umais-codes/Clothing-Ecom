import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class FitProfileCard extends GetView<ProfileController> {
  const FitProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final h = context.screenHeight;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.035,
        vertical: h * 0.015,
      ),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(w * 0.03),
        border: Border.all(color: AppColors.greyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My AI Fit Profile',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: w * 0.05,
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.camel,
                size: w * 0.06,
              ),
            ],
          ),
          SizedBox(height: h * 0.01),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric(context, 'Height', controller.height.value),
                _buildMetric(context, 'Weight', controller.weight.value),
                _buildMetric(context, 'Fit', controller.fitPreference.value),
              ],
            ),
          ),
          SizedBox(height: h * 0.015),
          CustomButton(
            onPressed: controller.updateBodyMetrics,
            text: 'Update Body Metrics',
            icon: Icons.edit_note_rounded,
            height: h * 0.065,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final w = context.screenWidth;
    final h = context.screenHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: h * 0.005),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: w * 0.035,
          ),
        ),
      ],
    );
  }
}
