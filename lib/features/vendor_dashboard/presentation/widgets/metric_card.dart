import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final IconData icon;
  final Color? accentColor;
  final bool isLarge;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    required this.icon,
    this.accentColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;

    return Container(
      height: isLarge ? sw * 0.18 : sw * 0.18,
      padding: EdgeInsets.symmetric(horizontal: sw * 0.015, vertical: sw * 0.01),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.15),
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
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.015,
                  vertical: sw * 0.008,
                ),
                decoration: BoxDecoration(
                  color: (accentColor ?? AppColors.camel).withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: sw * 0.04,
                  color: accentColor ?? AppColors.camel,
                ),
              ),
              if (trend != null)
                Text(
                  trend!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: sw * 0.024,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                  fontSize: sw * 0.025,
                ),
              ),
              Text(
                value,
                style:
                    (isLarge
                            ? Theme.of(context).textTheme.displaySmall
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: isLarge ? sw * 0.045 : sw * 0.035,
                          height: 1.1,
                          color: AppColors.charcoal,
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
