import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: .symmetric(horizontal: w * 0.03, vertical: w * 0.02),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.camel.withValues(alpha: 0.1)
              : AppColors.greySubtle,
          borderRadius: .circular(w * 0.03),
          border: .all(
            color: selected ? AppColors.camel : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.camel.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                icon,
                size: w * 0.04,
                color: selected ? AppColors.camel : AppColors.grey,
              ),
            ),
            SizedBox(width: w * 0.02),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: w * 0.032,
                fontWeight: selected ? .w600 : .w500,
                color: selected ? AppColors.camel : AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
