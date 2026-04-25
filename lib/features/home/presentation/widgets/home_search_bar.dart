import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final double sw;
  const HomeSearchBar({super.key, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: sw * 0.04, vertical: sw * 0.03),
      child: Container(
        padding: .symmetric(horizontal: sw * 0.04),
        height: sw * 0.12,
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: .circular(sw * 0.035),
          border: .all(color: AppColors.greyLight, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.grey, size: sw * 0.05),
            SizedBox(width: sw * 0.025),
            Expanded(
              child: TextField(
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: sw * 0.035,
                  color: AppColors.charcoal,
                ),
                decoration: InputDecoration(
                  hintText: 'Search collections...',
                  hintStyle: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey,
                    fontSize: sw * 0.033,
                    letterSpacing: 0.5,
                  ),
                  filled: false,
                  border: .none,
                  enabledBorder: .none,
                  focusedBorder: .none,
                  isDense: true,
                  contentPadding: .zero,
                ),
              ),
            ),
            Icon(Icons.tune_rounded, color: AppColors.grey, size: sw * 0.045),
          ],
        ),
      ),
    );
  }
}
