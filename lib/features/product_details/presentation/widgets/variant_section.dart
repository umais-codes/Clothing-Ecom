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
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style: Get.textTheme.labelLarge?.copyWith(
            color: AppColors.grey,
            fontSize: sw * 0.028,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: sw * 0.01),
        Obx(
          () => Wrap(
            spacing: sw * 0.02,
            runSpacing: sw * 0.02,
            children: items.map((item) {
              final isSelected = selectedItem.value == item;
              return GestureDetector(
                onTap: () => selectedItem.value = item,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: .symmetric(
                    horizontal: sw * 0.04,
                    vertical: sw * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.charcoal : AppColors.white,
                    borderRadius: .circular(sw * 0.025),
                    border: .all(
                      color: isSelected
                          ? AppColors.charcoal
                          : AppColors.greyLight,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      color: isSelected ? AppColors.white : AppColors.ink,
                      fontWeight: isSelected ? .w600 : .w400,
                      fontSize: sw * 0.03,
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
