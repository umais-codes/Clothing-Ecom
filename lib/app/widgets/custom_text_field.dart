import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/validations/validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final IconData? icon;
  final Gradient? gradient;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool enabled;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscureText;
  final Color? focusColor;
  final bool hasError;
  final String? hinttext;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final int? maxLength;
  final EdgeInsetsGeometry? contentPadding;
  final bool readOnly;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? fillColor;
  final String? errorText;
  final TextStyle? style;
  final void Function(String)? onFieldSubmitted;
  final bool autoFocus;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.label,
    required this.controller,
    this.icon,
    this.gradient,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false,
    this.focusColor,
    this.hasError = false,
    this.hinttext,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.contentPadding,
    this.readOnly = false,
    this.borderRadius,
    this.margin,
    this.fillColor,
    this.errorText,
    this.style,
    this.onFieldSubmitted,
    this.autoFocus = false,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      margin: margin ?? .only(bottom: height * 0.012),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (label != null)
            Padding(
              padding: .only(left: width * 0.015, bottom: height * 0.012),
              child: Row(
                children: [
                  if (icon != null)
                    gradient != null
                        ? ShaderMask(
                            shaderCallback: (bounds) =>
                                gradient!.createShader(bounds),
                            child: Icon(
                              icon,
                              size: width * 0.045,
                              color: AppColors.white,
                            ),
                          )
                        : Icon(
                            icon,
                            size: width * 0.045,
                            color: focusColor ?? AppColors.camel,
                          ),
                  if (icon != null) SizedBox(width: width * 0.02),
                  Text(
                    label!,
                    style: GoogleFonts.outfit(
                      fontSize: width * 0.035,
                      fontWeight: .w600,
                      color: AppColors.ink,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            textAlign: textAlign,
            validator: (value) {
              if (value != null && AppValidator.hasEmoji(value)) {
                return "Emojis are not allowed";
              }
              if (validator != null) {
                return validator!(value);
              }
              return null;
            },
            textCapitalization: .sentences,
            enabled: enabled,
            readOnly: readOnly,
            obscureText: obscureText,
            cursorHeight: height * 0.022,
            cursorWidth: 2,
            cursorColor: focusColor,
            style:
                style ??
                GoogleFonts.poppins(
                  fontSize: width * 0.035,
                  color: const Color(0xFF1F2937),
                  fontWeight: .w500,
                  height: 1.3,
                ),
            onChanged: onChanged,
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: fillColor ?? const Color(0xFFF8FAFC),
              hintText: hinttext,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              errorText: errorText,

              enabledBorder: OutlineInputBorder(
                borderRadius: .circular(borderRadius ?? width * 0.03),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.error
                      : AppColors.grey.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: .circular(borderRadius ?? width * 0.03),
                borderSide: BorderSide(
                  color: focusColor ?? AppColors.camel,
                  width: 1.8,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: .circular(borderRadius ?? width * 0.03),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: .circular(borderRadius ?? width * 0.03),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1.8,
                ),
              ),

              contentPadding:
                  contentPadding ??
                  .symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.012,
                  ),

              hintStyle: GoogleFonts.outfit(
                color: AppColors.grey.withValues(alpha: 0.6),
                fontSize: width * 0.032,
                fontWeight: .w400,
              ),
              errorStyle: TextStyle(fontSize: width * 0.03, fontWeight: .w500),
            ),
            onFieldSubmitted: onFieldSubmitted,
            autofocus: autoFocus,
            textInputAction: textInputAction,
          ),
        ],
      ),
    );
  }
}
