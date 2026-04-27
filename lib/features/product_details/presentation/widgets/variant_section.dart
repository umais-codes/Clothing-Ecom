import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class VariantSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final RxString selectedItem;
  final double sw;

  const VariantSection({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: AppColors.grey,
            fontSize: sw * 0.025,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: sw * 0.015),
        Obx(
          () => Wrap(
            spacing: sw * 0.03,
            runSpacing: sw * 0.03,
            children: items.map((item) {
              final isSelected = selectedItem.value == item;
              return GestureDetector(
                onTap: () => selectedItem.value = item,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.05,
                    vertical: sw * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.charcoal : AppColors.white,
                    borderRadius: BorderRadius.circular(sw * 0.02),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.charcoal
                          : AppColors.greyLight.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.charcoal.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.outfit(
                      color: isSelected ? AppColors.white : AppColors.charcoal,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: sw * 0.032,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
