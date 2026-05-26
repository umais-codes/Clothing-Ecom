import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class CustomDropdownField extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? hinttext;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? fillColor;
  final String? errorText;
  final bool isRequired;

  const CustomDropdownField({
    super.key,
    this.label,
    this.icon,
    required this.value,
    required this.items,
    this.onChanged,
    this.hinttext,
    this.borderRadius,
    this.margin,
    this.fillColor,
    this.errorText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final height = context.screenHeight;
    final Color focusColor = AppColors.camel;

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: height * 0.012),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ────────────────────────────────────────────────────────
          if (label != null)
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.01,
                bottom: height * 0.008,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: width * 0.038,
                      color: focusColor,
                    ),
                    SizedBox(width: width * 0.016),
                  ],
                  Text(
                    label!,
                    style: GoogleFonts.outfit(
                      fontSize: width * 0.033,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      letterSpacing: 0.1,
                    ),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 3),
                    Text(
                      '*',
                      style: GoogleFonts.outfit(
                        fontSize: width * 0.033,
                        fontWeight: FontWeight.w700,
                        color: AppColors.camel,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // ── Dropdown Button ──────────────────────────────────────────────
          DropdownButtonFormField<String>(
            initialValue: items.contains(value) ? value : null,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.outfit(
                    fontSize: width * 0.035,
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor ?? const Color(0xFFFAF9F7),
              hintText: hinttext,
              errorText: errorText,
              hintStyle: GoogleFonts.outfit(
                color: AppColors.grey.withValues(alpha: 0.55),
                fontSize: width * 0.032,
                fontWeight: FontWeight.w400,
              ),
              errorStyle: GoogleFonts.outfit(
                fontSize: width * 0.03,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.012,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? width * 0.028,
                ),
                borderSide: BorderSide(
                  color: errorText != null
                      ? AppColors.error
                      : AppColors.greyLight.withValues(alpha: 0.9),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? width * 0.028,
                ),
                borderSide: BorderSide(color: focusColor, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? width * 0.028,
                ),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? width * 0.028,
                ),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.8,
                ),
              ),
            ),
            dropdownColor: AppColors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
