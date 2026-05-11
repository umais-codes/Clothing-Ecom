import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// AdminStatusDropdown — reusable GetX-safe status selector
// ─────────────────────────────────────────────────────────────────────────────

typedef _StatusConfig = ({String label, Color color, IconData icon, Color bg});

const Map<ProductStatus, _StatusConfig> _kStatusConfig = {
  ProductStatus.approved: (
    label: 'Approved',
    color: AppColors.success,
    icon: Icons.check_circle_outline_rounded,
    bg: Color(0xFFEDF7F1),
  ),
  ProductStatus.pending: (
    label: 'Pending Review',
    color: AppColors.warning,
    icon: Icons.hourglass_empty_rounded,
    bg: Color(0xFFFDF3EA),
  ),
  ProductStatus.rejected: (
    label: 'Rejected',
    color: AppColors.error,
    icon: Icons.cancel_outlined,
    bg: Color(0xFFFDEDEC),
  ),
};

class AdminStatusDropdown extends StatefulWidget {
  const AdminStatusDropdown({
    super.key,
    required this.label,
    required this.labelIcon,
    required this.initialStatus,
    this.onChanged,
  });

  final String label;
  final IconData labelIcon;
  final ProductStatus initialStatus;
  final ValueChanged<ProductStatus>? onChanged;

  @override
  State<AdminStatusDropdown> createState() => _AdminStatusDropdownState();
}

class _AdminStatusDropdownState extends State<AdminStatusDropdown> {
  late ProductStatus _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: widget.label, icon: widget.labelIcon),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF9F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.9),
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProductStatus>(
              value: _selected,
              isExpanded: true,
              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(
                Icons.unfold_more_rounded,
                size: 18,
                color: AppColors.grey,
              ),
              // Selected item shown inside the button
              selectedItemBuilder: (_) => ProductStatus.values.map((s) {
                final c = _kStatusConfig[s]!;
                return _StatusTile(config: c);
              }).toList(),
              // Full items in the dropdown menu
              items: ProductStatus.values.map((s) {
                final c = _kStatusConfig[s]!;
                return DropdownMenuItem<ProductStatus>(
                  value: s,
                  child: _StatusTile(config: c),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selected = v);
                  widget.onChanged?.call(v);
                }
              },
            ),
          ),
        ),
      ],
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.camelLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.camel),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
                letterSpacing: -0.1,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.grey,
              ),
            ),
          ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers (internal to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.grey),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.config});

  final _StatusConfig config;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: config.bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(config.icon, size: 13, color: config.color),
        ),
        const SizedBox(width: 10),
        Text(
          config.label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
