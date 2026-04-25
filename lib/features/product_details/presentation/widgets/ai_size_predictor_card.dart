import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class AISizePredictorCard extends StatelessWidget {
  final double sw;
  final VoidCallback onPredict;

  const AISizePredictorCard({
    super.key,
    required this.sw,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: sw * 0.03, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.camelLight,
        borderRadius: .circular(sw * 0.04),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Container(
                padding: .all(sw * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.camel.withValues(alpha: 0.15),
                  borderRadius: .circular(sw * 0.02),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.camel,
                  size: sw * 0.045,
                ),
              ),
              SizedBox(width: sw * 0.025),
              Text(
                'AI Size Predictor',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontSize: sw * 0.036,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.02),
          Text(
            'Get your perfect fit using our intelligent size recommendation engine.',
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontSize: sw * 0.028,
              height: 1.5,
            ),
          ),
          SizedBox(height: sw * 0.035),
          CustomButton(
            text: 'Predict My Size',
            onPressed: onPredict,
            height: sw * 0.11,
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ),
    );
  }
}
