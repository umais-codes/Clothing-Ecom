import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class OnboardingProgressBar extends StatelessWidget {
  final int step;
  final int total;

  const OnboardingProgressBar({
    super.key,
    required this.step,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    return Row(
      children: List.generate(total, (i) {
        final bool filled = i < step;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            margin: .only(right: i < total - 1 ? w * 0.015 : 0),
            height: 2,
            decoration: BoxDecoration(
              color: filled ? AppColors.camel : AppColors.greyLight,
              borderRadius: .circular(2),
            ),
          ),
        );
      }),
    );
  }
}
