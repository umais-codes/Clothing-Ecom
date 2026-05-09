import 'package:flutter/material.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = AppColors.charcoal,
    this.trend,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(2.5).clamp(10.0, 16.0),
        vertical: context.hp(0.8).clamp(4.0, 10.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Container(
                padding: .symmetric(
                  horizontal: context.wp(1.5).clamp(6.0, 10.0),
                  vertical: context.wp(1.0).clamp(4.0, 6.0),
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: .circular(8),
                ),
                child: Icon(
                  icon,
                  size: context.sp(16).clamp(14.0, 20.0),
                  color: color,
                ),
              ),
              if (trend != null)
                Text(
                  trend!,
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(12).clamp(10.0, 14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
            ],
          ),
          SizedBox(height: context.hp(0.6).clamp(4.0, 8.0)),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: context.sp(12).clamp(10.0, 14.0),
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: context.hp(0.4).clamp(2.0, 6.0)),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: context.sp(16).clamp(12.0, 20.0),
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader({
    super.key,
    required this.title,
    this.onActionTap,
    this.actionLabel,
    this.trailing,
  });

  final String title;
  final VoidCallback? onActionTap;
  final String? actionLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: context.sp(14).clamp(12.0, 16.0),
            fontWeight: .w700,
            color: AppColors.charcoal,
          ),
        ),
        const Spacer(),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class AdminInfoRow extends StatelessWidget {
  const AdminInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(
        horizontal: context.wp(3).clamp(12.0, 16.0),
        vertical: context.hp(1).clamp(8.0, 12.0),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: context.sp(14).clamp(12.0, 16.0),
            color: AppColors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: context.sp(11).clamp(10.0, 13.0),
              color: AppColors.grey,
              fontWeight: .w500,
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: context.sp(12).clamp(11.0, 14.0),
                fontWeight: .w600,
                color: valueColor ?? AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminStatusBadge extends StatelessWidget {
  const AdminStatusBadge({
    super.key,
    required this.status,
    this.padding = const .symmetric(horizontal: 10, vertical: 4),
  });

  final String status;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status.capitalizeFirst ?? status;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
      case 'success':
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        break;
      case 'rejected':
      case 'failed':
      case 'error':
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        break;
      case 'pending':
      case 'awaiting':
      case 'warning':
        bg = AppColors.warning.withValues(alpha: 0.12);
        fg = AppColors.warning;
        break;
      default:
        bg = AppColors.greyLight.withValues(alpha: 0.3);
        fg = AppColors.charcoal;
    }

    return Container(
      padding: .symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: .circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.15), width: 0.8),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: .circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: context.sp(10.5).clamp(10.0, 11.5),
              fontWeight: .w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(
            icon,
            size: context.sp(48).clamp(32.0, 64.0),
            color: AppColors.greyLight,
          ),
          SizedBox(height: context.hp(1).clamp(8.0, 12.0)),
          Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: context.sp(14).clamp(12.0, 16.0),
              color: AppColors.grey,
              fontWeight: .w500,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminActivityTile extends StatelessWidget {
  const AdminActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(
        vertical: context.hp(1).clamp(6.0, 10.0),
        horizontal: context.wp(2.5).clamp(10.0, 16.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: .circular(12),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: .symmetric(
              vertical: context.hp(0.7).clamp(3.5, 5.5),
              horizontal: context.wp(1.2).clamp(3.5, 5.5),
            ),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: .circular(10),
            ),
            child: Icon(
              icon,
              size: context.sp(16).clamp(14.0, 20.0),
              color: iconColor,
            ),
          ),
          SizedBox(width: context.wp(3).clamp(10.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: context.sp(12.5).clamp(11.0, 14.0),
                          fontWeight: .w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(10).clamp(9.0, 12.0),
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.hp(0.3).clamp(2.0, 4.0)),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(11).clamp(10.0, 13.0),
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminAvatar extends StatelessWidget {
  const AdminAvatar({super.key, required this.name, this.size = 36});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.camel.withValues(alpha: 0.15),
        shape: .circle,
      ),
      alignment: .center,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: context.sp(size * 0.38).clamp(size * 0.3, size * 0.5),
          fontWeight: .w700,
          color: AppColors.camel,
        ),
      ),
    );
  }
}
