import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../controllers/monetization_controller.dart';
import '../../../domain/models/vendor_billing.dart';
import '../admin_card.dart';
import '../admin_widgets.dart';
import '../admin_form_widgets.dart';

class VendorBillingOversight extends GetView<MonetizationController> {
  const VendorBillingOversight({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AdminFormCardHeader(
                  icon: Icons.receipt_long_rounded,
                  title: 'Vendor Billing Oversight',
                  subtitle: 'Active subscriptions & billing status',
                ),
              ),
              Obx(() {
                final pastDueCount = controller.vendorBillings
                    .where((b) => b.billingStatus == 'Past Due')
                    .length;
                if (pastDueCount == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$pastDueCount Past Due',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),

          // ── Billing List ──────────────────────────────────────────────────
          Obx(() {
            if (controller.vendorBillings.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: AdminEmptyState(
                  message: 'No vendor billing records found.',
                  icon: Icons.receipt_long_outlined,
                ),
              );
            }
            return Column(
              children: controller.vendorBillings
                  .map(
                    (billing) => _VendorBillingTile(
                      billing: billing,
                      controller: controller,
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Vendor Billing Tile ──────────────────────────────────────────────────────

class _VendorBillingTile extends StatelessWidget {
  const _VendorBillingTile({required this.billing, required this.controller});

  final VendorBilling billing;
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    final isPastDue = billing.billingStatus == 'Past Due';
    final isActive = billing.billingStatus == 'Active';

    final Color statusColor;
    final Color statusBg;
    if (isActive) {
      statusColor = AppColors.success;
      statusBg = AppColors.success.withValues(alpha: 0.08);
    } else if (isPastDue) {
      statusColor = AppColors.warning;
      statusBg = AppColors.warning.withValues(alpha: 0.08);
    } else {
      statusColor = AppColors.error;
      statusBg = AppColors.error.withValues(alpha: 0.08);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPastDue
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.greySubtle,
        ),
      ),
      child: Column(
        children: [
          // Top row: vendor name + status chip
          Row(
            children: [
              // Vendor avatar
              AdminAvatar(name: billing.vendorName, size: 34),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      billing.vendorName,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      billing.activePlanName,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      billing.billingStatus,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          Container(height: 1, color: AppColors.greySubtle),
          const SizedBox(height: 10),

          // Bottom row: plan + next billing + action
          Row(
            children: [
              // Plan info
              Expanded(
                child: _InfoColumn(
                  label: 'Active Plan',
                  value: billing.activePlanName,
                ),
              ),

              // Next billing
              Expanded(
                child: _InfoColumn(
                  label: 'Next Billing',
                  value: DateFormat(
                    'MMM dd, yyyy',
                  ).format(billing.nextBillingDate),
                  valueColor: isPastDue
                      ? AppColors.warning
                      : AppColors.charcoal,
                ),
              ),

              // Action menu
              _BillingActionMenu(billing: billing, controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}

class _BillingActionMenu extends StatelessWidget {
  const _BillingActionMenu({required this.billing, required this.controller});

  final VendorBilling billing;
  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.greyLight.withValues(alpha: 0.5)),
      ),
      color: AppColors.white,
      elevation: 4,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.greySubtle,
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          color: AppColors.ink,
          size: 16,
        ),
      ),
      onSelected: (result) =>
          controller.changeVendorBillingAction(billing.vendorId, result),
      itemBuilder: (_) => [
        _popupItem('Upgrade', Icons.arrow_upward_rounded, AppColors.success),
        _popupItem(
          'Downgrade',
          Icons.arrow_downward_rounded,
          AppColors.warning,
        ),
        _popupItem('Extend', Icons.update_rounded, AppColors.camel),
        const PopupMenuDivider(),
        _popupItem('Cancel', Icons.cancel_outlined, AppColors.error),
      ],
    );
  }

  PopupMenuItem<String> _popupItem(String value, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
