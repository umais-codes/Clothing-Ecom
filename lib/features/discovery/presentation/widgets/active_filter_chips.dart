import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/custom_button.dart';
import '../controllers/filter_controller.dart';

class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final FilterController controller = Get.find<FilterController>();
    final Size size = MediaQuery.sizeOf(context);
    final double sw = size.width;

    return Obx(() {
      final activeFilters = controller.activeFiltersList;

      if (activeFilters.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: sw * 0.08,
        alignment: Alignment.centerLeft,
        child: ListView.builder(
          scrollDirection: .horizontal,
          padding: .symmetric(horizontal: sw * 0.03),
          itemCount: activeFilters.length + (activeFilters.length >= 2 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == activeFilters.length) {
              return CustomButton(
                text: 'Clear All',
                variant: ButtonVariant.ghost,
                textColor: AppColors.camel,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                width: null,
                height: sw * 0.08,
                borderRadius: 4,
                onPressed: () => controller.clearAll(),
              );
            }

            final item = activeFilters[index];

            return Container(
              margin: const EdgeInsets.only(right: 6),
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.015,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.camelLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.camel.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  SizedBox(width: sw * 0.01),
                  GestureDetector(
                    onTap: () => controller.removeActiveFilter(item),
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: AppColors.error.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
