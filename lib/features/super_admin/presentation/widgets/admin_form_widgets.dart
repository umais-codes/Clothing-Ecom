import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_dropdown_field.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';

class AdminFormField extends StatelessWidget {
  const AdminFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.labelIcon,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.prefixText,
    this.inputFormatters,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData labelIcon;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      icon: labelIcon,
      hinttext: hint,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      prefixText: prefixText,
      inputFormatters: inputFormatters,
      isRequired: isRequired,
      margin: EdgeInsets.zero,
    );
  }
}

class AdminDropdownField extends StatelessWidget {
  const AdminDropdownField({
    super.key,
    required this.label,
    required this.labelIcon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
  });

  final String label;
  final IconData labelIcon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownField(
      label: label,
      icon: labelIcon,
      value: value,
      items: items,
      onChanged: onChanged,
      isRequired: isRequired,
      margin: EdgeInsets.zero,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminStatusDropdown — reusable GetX-safe status selector using CustomDropdownField
// ─────────────────────────────────────────────────────────────────────────────

class AdminStatusDropdown extends StatelessWidget {
  final String label;
  final IconData labelIcon;
  final ProductStatus initialStatus;
  final ValueChanged<ProductStatus>? onChanged;
  final Rx<ProductStatus> selected;

  AdminStatusDropdown({
    super.key,
    required this.label,
    required this.labelIcon,
    required this.initialStatus,
    this.onChanged,
  }) : selected = initialStatus.obs;

  static const Map<ProductStatus, String> _statusToLabel = {
    ProductStatus.approved: 'Approved',
    ProductStatus.pending: 'Pending Review',
    ProductStatus.rejected: 'Rejected',
  };

  static const Map<String, ProductStatus> _labelToStatus = {
    'Approved': ProductStatus.approved,
    'Pending Review': ProductStatus.pending,
    'Rejected': ProductStatus.rejected,
  };

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomDropdownField(
        label: label,
        icon: labelIcon,
        value: _statusToLabel[selected.value] ?? 'Approved',
        items: _statusToLabel.values.toList(),
        onChanged: (val) {
          if (val != null && _labelToStatus.containsKey(val)) {
            final newStatus = _labelToStatus[val]!;
            selected.value = newStatus;
            onChanged?.call(newStatus);
          }
        },
        margin: EdgeInsets.zero,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminFormCardHeader — icon + title + subtitle section header
// ─────────────────────────────────────────────────────────────────────────────

class AdminFormCardHeader extends StatelessWidget {
  const AdminFormCardHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final double iconPadding = context.responsive(
      mobile: 8.0,
      tablet: 9.0,
      desktop: 10.0,
    );
    final double iconSize = context.responsive(
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    final double borderRadius = context.responsive(
      mobile: 8.0,
      tablet: 10.0,
      desktop: 10.0,
    );
    final double gapWidth = context.responsive(
      mobile: 10.0,
      tablet: 12.0,
      desktop: 14.0,
    );
    final double titleFontSize = context.responsive(
      mobile: 13.0,
      tablet: 14.0,
      desktop: 15.0,
    );
    final double subtitleFontSize = context.responsive(
      mobile: 10.5,
      tablet: 11.5,
      desktop: 12.5,
    );

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            color: AppColors.camelLight,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(icon, size: iconSize, color: AppColors.camel),
        ),
        SizedBox(width: gapWidth),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                  letterSpacing: -0.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminImageCountBadge — reactive Obx pill showing X/5
// ─────────────────────────────────────────────────────────────────────────────

class AdminImageCountBadge extends StatelessWidget {
  const AdminImageCountBadge({super.key, required this.count});

  final RxInt count;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = count.value;
      final isFull = c >= 5;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isFull
              ? AppColors.error.withValues(alpha: 0.08)
              : AppColors.greySubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFull
                ? AppColors.error.withValues(alpha: 0.25)
                : AppColors.greyLight,
            width: 1,
          ),
        ),
        child: Text(
          '$c / 5',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isFull ? AppColors.error : AppColors.grey,
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AdminAddPhotoTile — reactive add-photo button
// ─────────────────────────────────────────────────────────────────────────────

class AdminAddPhotoTile extends StatelessWidget {
  const AdminAddPhotoTile({
    super.key,
    required this.size,
    required this.isLoading,
    required this.onTap,
  });

  final double size;
  final RxBool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = isLoading.value;
      return GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: loading ? AppColors.greySubtle : AppColors.camelLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: loading
                  ? AppColors.greyLight
                  : AppColors.camel.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.camel,
                      ),
                    )
                  : const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.camel,
                      size: 22,
                    ),
              const SizedBox(height: 5),
              Text(
                loading ? 'Opening...' : 'Add Photo',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: loading ? AppColors.grey : AppColors.camel,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
