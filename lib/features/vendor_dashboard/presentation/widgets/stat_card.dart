import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final Map<String, String> stat;
  final double sw;

  const StatCard({
    super.key,
    required this.stat,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCamel = stat['color'] == 'camel';
    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: isCamel ? AppColors.camelLight : AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          color: isCamel ? AppColors.camel.withValues(alpha: 0.25) : AppColors.greyLight,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat['title']!,
            style: Get.textTheme.labelLarge?.copyWith(
              fontSize: sw * 0.028,
              color: AppColors.grey,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat['value']!,
              style: Get.textTheme.headlineMedium?.copyWith(
                fontSize: sw * 0.05,
                fontWeight: FontWeight.w800,
                color: isCamel ? AppColors.camel : AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
