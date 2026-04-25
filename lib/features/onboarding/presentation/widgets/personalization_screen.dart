import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ecom_app/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalizationScreen extends GetView<OnboardingController> {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Back + Progress ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(w * 0.03, h * 0.015, w * 0.05, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.prevPage,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    color: AppColors.charcoal,
                  ),
                  Expanded(child: OnboardingProgressBar(step: 3, total: 4)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  w * 0.07,
                  h * 0.03,
                  w * 0.07,
                  h * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Step label ──────────────────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.03,
                        vertical: h * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.camelLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'STEP 2 OF 3',
                        style: GoogleFonts.outfit(
                          fontSize: w * 0.028,
                          fontWeight: FontWeight.w700,
                          color: AppColors.camel,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    Text(
                      'Personalize\nYour Style',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: w * 0.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                        height: 1.1,
                        letterSpacing: -0.3,
                      ),
                    ),

                    SizedBox(height: h * 0.01),

                    Text(
                      'Tell us your style so we can surface the\nbest products and predict your perfect fit.',
                      style: GoogleFonts.outfit(
                        fontSize: w * 0.036,
                        color: AppColors.grey,
                        height: 1.55,
                      ),
                    ),

                    SizedBox(height: h * 0.04),

                    // ── Category Section ────────────────────────────────────
                    _SectionLabel(label: 'What are you shopping for?', w: w),
                    SizedBox(height: h * 0.016),

                    Obx(
                      () => Wrap(
                        spacing: w * 0.025,
                        runSpacing: h * 0.012,
                        children: controller.categories.map((cat) {
                          final label = cat['label'] as String;
                          final icon = cat['icon'] as IconData;
                          final isSelected = controller.selectedCategories
                              .contains(label);
                          return _CategoryChip(
                            label: label,
                            icon: icon,
                            selected: isSelected,
                            onTap: () => controller.toggleCategory(label),
                            w: w,
                            h: h,
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: h * 0.04),

                    // ── AI Size Section ────────────────────────────────────
                    _SectionLabel(label: 'Calibrate Your AI Size', w: w),
                    SizedBox(height: h * 0.008),
                    Text(
                      'Approximate values work great — you can always refine later.',
                      style: GoogleFonts.outfit(
                        fontSize: w * 0.032,
                        color: AppColors.grey,
                      ),
                    ),

                    SizedBox(height: h * 0.01),

                    // Height Slider
                    _MeasurementSlider(
                      label: 'Height',
                      unit: 'cm',
                      value: controller.height,
                      min: 140,
                      max: 210,
                      divisions: 70,
                      w: w,
                      h: h,
                    ),

                    SizedBox(height: h * 0.018),

                    // Weight Slider
                    _MeasurementSlider(
                      label: 'Weight',
                      unit: 'kg',
                      value: controller.weight,
                      min: 35,
                      max: 150,
                      divisions: 115,
                      w: w,
                      h: h,
                    ),

                    SizedBox(height: h * 0.034),

                    // ── Fit Preference ──────────────────────────────────────
                    _SectionLabel(label: 'Preferred Fit', w: w),
                    SizedBox(height: h * 0.016),

                    Obx(
                      () => Row(
                        children: controller.fitOptions.map((fit) {
                          final isSelected =
                              controller.selectedFit.value == fit;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectFit(fit),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: .only(
                                  right: fit != controller.fitOptions.last
                                      ? w * 0.02
                                      : 0,
                                ),
                                padding: .symmetric(vertical: h * 0.01),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.camel
                                      : AppColors.greySubtle,
                                  borderRadius: BorderRadius.circular(w * 0.03),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.camel
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  fit,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: w * 0.036,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.ink,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: h * 0.045),

                    // ── CTA ─────────────────────────────────────────────────
                    CustomButton(
                      text: 'Continue',
                      onPressed: controller.nextPage,
                    ),

                    SizedBox(height: h * 0.014),

                    Center(
                      child: GestureDetector(
                        onTap: controller.nextPage,
                        child: Text(
                          'Skip for now',
                          style: GoogleFonts.outfit(
                            fontSize: w * 0.033,
                            color: AppColors.grey,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final double w;

  const _SectionLabel({required this.label, required this.w});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: w * 0.04,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Chip
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final double w;
  final double h;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.013,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.camelLight : AppColors.greySubtle,
          borderRadius: BorderRadius.circular(w * 0.025),
          border: Border.all(
            color: selected ? AppColors.camel : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.camel.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: w * 0.042,
              color: selected ? AppColors.camel : AppColors.grey,
            ),
            SizedBox(width: w * 0.018),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: w * 0.034,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.camel : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Measurement Slider
// ─────────────────────────────────────────────────────────────────────────────
class _MeasurementSlider extends StatelessWidget {
  final String label;
  final String unit;
  final RxDouble value;
  final double min;
  final double max;
  final int divisions;
  final double w;
  final double h;

  const _MeasurementSlider({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: w * 0.025, vertical: h * 0.01),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        borderRadius: .circular(w * 0.04),
        border: .all(color: AppColors.greyLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: w * 0.035,
                  fontWeight: .w600,
                  color: AppColors.charcoal,
                ),
              ),
              Obx(
                () => Container(
                  padding: .symmetric(
                    horizontal: w * 0.03,
                    vertical: h * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.camelLight,
                    borderRadius: .circular(6),
                  ),
                  child: Text(
                    '${value.value.round()} $unit',
                    style: GoogleFonts.outfit(
                      fontSize: w * 0.03,
                      fontWeight: .w600,
                      color: AppColors.camel,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: w * 0.005),
          Obx(
            () => SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.camel,
                inactiveTrackColor: AppColors.greyLight,
                thumbColor: AppColors.camel,
                overlayColor: AppColors.camel.withValues(alpha: 0.12),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                trackHeight: 3,
              ),
              child: Slider(
                value: value.value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: (v) => value.value = v,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                '${min.round()} $unit',
                style: GoogleFonts.outfit(
                  fontSize: w * 0.025,
                  color: AppColors.grey,
                ),
              ),
              Text(
                '${max.round()} $unit',
                style: GoogleFonts.outfit(
                  fontSize: w * 0.025,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
