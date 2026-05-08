import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outlined, ghost }

class CustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? buttonColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    this.text,
    this.onPressed,
    this.variant = .primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.borderRadius,
    this.buttonColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDisabled = onPressed == null || isLoading;

    final Color effectiveBgColor = _getBgColor();
    final Color effectiveTextColor = _getTextColor();
    final Border? effectiveBorder = _getBorder();
    final List<BoxShadow>? effectiveShadow = _getShadow(sw);
    final Gradient? effectiveGradient = _getGradient();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        width:
            width ?? (variant == ButtonVariant.ghost ? null : double.infinity),
        height: height ?? sw * 0.13,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          gradient: effectiveGradient,
          borderRadius: .circular(borderRadius ?? sw * 0.035),
          border: effectiveBorder,
          boxShadow: effectiveShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: .circular(borderRadius ?? sw * 0.035),
            splashColor: effectiveTextColor.withValues(alpha: 0.1),
            highlightColor: effectiveTextColor.withValues(alpha: 0.05),
            child: Padding(
              padding: .symmetric(horizontal: sw * 0.04),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: sw * 0.05,
                        height: sw * 0.05,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            effectiveTextColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: sw * 0.045,
                              color: effectiveTextColor,
                            ),
                            if (text != null) SizedBox(width: sw * 0.02),
                          ],
                          if (text != null)
                            Text(
                              text!,
                              style: GoogleFonts.outfit(
                                fontSize: fontSize ?? sw * 0.035,
                                fontWeight: fontWeight ?? .w700,
                                color: effectiveTextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBgColor() {
    if (buttonColor != null) return buttonColor!;
    switch (variant) {
      case .primary:
        return AppColors.charcoal;
      case .secondary:
        return AppColors.greySubtle;
      case .outlined:
      case .ghost:
        return Colors.transparent;
    }
  }

  Gradient? _getGradient() {
    if (variant == ButtonVariant.primary) {
      return const LinearGradient(
        colors: [AppColors.camel, AppColors.rose],
        begin: .topLeft,
        end: .bottomRight,
      );
    }
    return null;
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;
    switch (variant) {
      case .primary:
        return AppColors.white;
      case .secondary:
      case .outlined:
      case .ghost:
        return AppColors.charcoal;
    }
  }

  Border? _getBorder() {
    if (variant == ButtonVariant.outlined) {
      return Border.all(color: AppColors.greyLight, width: 1.2);
    }
    return null;
  }

  List<BoxShadow>? _getShadow(double sw) {
    if (variant == ButtonVariant.primary) {
      return [
        BoxShadow(
          color: AppColors.camel.withValues(alpha: 0.25),
          blurRadius: sw * 0.04,
          offset: Offset(0, sw * 0.015),
        ),
      ];
    }
    return null;
  }
}
