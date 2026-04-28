import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CustomQuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final double sw;

  const CustomQuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        _buildQuantityBtn(
          Icons.remove_rounded,
          () => onChanged(quantity - 1),
          sw,
          "Decrease",
        ),
        SizedBox(
          width: sw * 0.08,
          child: Center(
            child: Text(
              '$quantity',
              style: GoogleFonts.outfit(
                fontSize: sw * 0.032,
                fontWeight: .w700,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ),
        _buildQuantityBtn(
          Icons.add_rounded,
          () => onChanged(quantity + 1),
          sw,
          "Increase",
        ),
      ],
    );
  }

  Widget _buildQuantityBtn(
    IconData icon,
    VoidCallback onPressed,
    double sw,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: .circular(sw * 0.03),
        child: Container(
          width: sw * 0.065,
          height: sw * 0.065,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: .circle,
            border: .all(color: AppColors.camel.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: sw * 0.04, color: AppColors.camel),
        ),
      ),
    );
  }
}
