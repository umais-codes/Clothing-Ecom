import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/validations/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final TextEditingController controller;
  final IconData? icon;
  final Gradient? gradient;
  final TextInputType? keyboardType;
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

  // New additions
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;

  const CustomTextField({
    super.key,
    this.label,
    required this.controller,
    this.icon,
    this.gradient,
    this.keyboardType,
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
    this.prefixText,
    this.inputFormatters,
    this.isRequired = false,
  });

  TextInputType get _resolvedKeyboardType {
    if (keyboardType != null) return keyboardType!;
    return maxLines > 1 ? TextInputType.multiline : TextInputType.text;
  }

  TextInputAction get _resolvedTextInputAction {
    if (textInputAction != null) return textInputAction!;
    return maxLines > 1 ? TextInputAction.newline : TextInputAction.next;
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final height = context.screenHeight;
    final effectiveFocusColor = focusColor ?? AppColors.camel;

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
                    gradient != null
                        ? ShaderMask(
                            shaderCallback: (bounds) =>
                                gradient!.createShader(bounds),
                            child: Icon(
                              icon,
                              size: width * 0.038,
                              color: AppColors.white,
                            ),
                          )
                        : Icon(
                            icon,
                            size: width * 0.038,
                            color: effectiveFocusColor,
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

          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: _resolvedKeyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            textAlign: textAlign,
            inputFormatters: inputFormatters,
            validator: (value) {
              if (value != null && AppValidator.hasEmoji(value)) {
                return 'Emojis are not allowed';
              }
              if (validator != null) return validator!(value);
              return null;
            },
            textCapitalization: TextCapitalization.sentences,
            enabled: enabled,
            readOnly: readOnly,
            obscureText: obscureText,
            cursorHeight: height * 0.022,
            cursorWidth: 1.8,
            cursorColor: effectiveFocusColor,
            style:
                style ??
                GoogleFonts.outfit(
                  fontSize: width * 0.035,
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            autofocus: autoFocus,
            textInputAction: _resolvedTextInputAction,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: fillColor ?? const Color(0xFFFAF9F7),
              hintText: hinttext,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              errorText: errorText,
              prefixText: prefixText != null ? '$prefixText  ' : null,
              prefixStyle: GoogleFonts.outfit(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
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
              contentPadding:
                  contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: maxLines > 1 ? height * 0.015 : height * 0.012,
                  ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? width * 0.028,
                ),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.error
                      : AppColors.greyLight.withValues(alpha: 0.9),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? width * 0.028,
                ),
                borderSide: BorderSide(color: effectiveFocusColor, width: 1.8),
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
          ),
        ],
      ),
    );
  }
}
