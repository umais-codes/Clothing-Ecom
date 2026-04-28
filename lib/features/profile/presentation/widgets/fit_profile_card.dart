import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class FitProfileCard extends GetView<ProfileController> {
  const FitProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Container(
      width: .infinity,
      padding: .symmetric(
        horizontal: size.width * 0.035,
        vertical: size.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: .circular(size.width * 0.03),
        border: .all(color: AppColors.greyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'My AI Fit Profile',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: size.width * 0.05,
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.camel,
                size: size.width * 0.06,
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Obx(
            () => Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                _buildMetric(context, 'Height', controller.height.value),
                _buildMetric(context, 'Weight', controller.weight.value),
                _buildMetric(context, 'Fit', controller.fitPreference.value),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.015),
          CustomButton(
            onPressed: controller.updateBodyMetrics,
            text: 'Update Body Metrics',
            icon: Icons.edit_note_rounded,
            height: size.height * 0.065,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: .w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: size.height * 0.005),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: .w600,
            fontSize: size.width * 0.035,
          ),
        ),
      ],
    );
  }
}
