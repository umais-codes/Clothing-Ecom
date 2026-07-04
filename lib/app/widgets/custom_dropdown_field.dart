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
    final fieldWidth = width - context.wp(10);
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
                    Icon(icon, size: width * 0.038, color: focusColor),
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
          DropdownMenu<String>(
            initialSelection: items.contains(value) ? value : null,
            width: fieldWidth,
            menuHeight: height * 0.35,
            hintText: hinttext,
            errorText: errorText,
            dropdownMenuEntries: items.map((item) {
              return DropdownMenuEntry<String>(
                value: item,
                label: item,
                style: MenuItemButton.styleFrom(
                  foregroundColor: AppColors.charcoal,
                  textStyle: GoogleFonts.outfit(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onSelected: onChanged,
            trailingIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.charcoal,
            ),
            selectedTrailingIcon: const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: AppColors.charcoal,
            ),
            textStyle: GoogleFonts.outfit(
              fontSize: width * 0.035,
              color: AppColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
            inputDecorationTheme: InputDecorationTheme(
              constraints: BoxConstraints(
                minWidth: fieldWidth,
                maxWidth: fieldWidth,
                minHeight: height * 0.055,
                maxHeight: height * 0.055,
              ),
              isDense: true,
              filled: true,
              fillColor: fillColor ?? const Color(0xFFFAF9F7),
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
                vertical: 0.0,
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
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(AppColors.white),
              elevation: WidgetStateProperty.all(4.0),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? width * 0.035,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
