import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class CustomStepper extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  final double? size;
  final double? iconSize;
  final Color? activeColor;

  const CustomStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.size,
    this.iconSize,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final double effectiveSize = size ?? sw * 0.08;
    final double effectiveIconSize = iconSize ?? sw * 0.04;

    return Row(
      mainAxisSize: .min,
      children: [
        _buildButton(
          icon: Icons.remove,
          onTap: value > 1 ? () => onChanged(value - 1) : null,
          size: effectiveSize,
          iconSize: effectiveIconSize,
          isDisabled: value <= 1,
        ),
        Container(
          constraints: BoxConstraints(minWidth: sw * 0.08),
          padding: .symmetric(horizontal: sw * 0.02),
          alignment: .center,
          child: Text(
            "$value",
            style: GoogleFonts.outfit(
              fontSize: sw * 0.035,
              fontWeight: .w700,
              color: AppColors.charcoal,
            ),
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
          size: effectiveSize,
          iconSize: effectiveIconSize,
          active: true,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onTap,
    required double size,
    required double iconSize,
    bool active = false,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(size * 0.2),
        decoration: BoxDecoration(
          color: active
              ? (onTap == null
                    ? AppColors.greyLight
                    : activeColor ?? AppColors.camel)
              : AppColors.white,
          shape: .circle,
          border: .all(
            color: active ? Colors.transparent : AppColors.greyLight,
            width: 1,
          ),
          boxShadow: active && !isDisabled
              ? [
                  BoxShadow(
                    color: (activeColor ?? AppColors.camel).withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: active
              ? AppColors.white
              : (isDisabled ? AppColors.greyLight : AppColors.charcoal),
        ),
      ),
    );
  }
}
