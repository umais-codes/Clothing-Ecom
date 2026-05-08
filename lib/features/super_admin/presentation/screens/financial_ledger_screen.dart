// lib/features/super_admin/presentation/screens/financial_ledger_screen.dart
//
// Stripe Connect split-payment master ledger.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/screen_header.dart';

class FinancialLedgerScreen extends GetView<AdminController> {
  const FinancialLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopView;
    final isTablet = context.isTabletView;
    final isWide = isDesktop || isTablet;
    final outerMargin = context.wp(2.5).clamp(12.0, 20.0);
    final innerPadding = context.wp(2).clamp(10.0, 16.0);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          ScreenHeader(
            title: 'Financial & Commission Ledger',
            subtitle: 'Stripe Connect split-payment routing overview',
          ),

          // ── Summary Strip ──────────────────────────────────────────────────
          Obx(
            () => Container(
              margin: EdgeInsets.symmetric(horizontal: outerMargin, vertical: 8),
              padding: EdgeInsets.symmetric(
                horizontal: innerPadding,
                vertical: context.hp(1.2).clamp(8.0, 14.0),
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: _LedgerStat(
                            label: 'Total Volume',
                            value: controller.formatCurrency(
                              controller.transactions.fold<double>(
                                0,
                                (s, t) => s + t.grossAmount,
                              ),
                            ),
                            icon: Icons.bar_chart_rounded,
                            color: AppColors.camel,
                          ),
                        ),
                        const _VerticalSeparator(),
                        Expanded(
                          child: _LedgerStat(
                            label: 'Platform Revenue',
                            value: controller.formatCurrency(
                              controller.transactions.fold<double>(
                                0,
                                (s, t) => s + t.platformEarned,
                              ),
                            ),
                            icon: Icons.percent_rounded,
                            color: AppColors.success,
                          ),
                        ),
                        const _VerticalSeparator(),
                        Expanded(
                          child: _LedgerStat(
                            label: 'Net to Vendors',
                            value: controller.formatCurrency(
                              controller.transactions.fold<double>(
                                0,
                                (s, t) => s + t.netToVendor,
                              ),
                            ),
                            icon: Icons.send_rounded,
                            color: AppColors.sage,
                          ),
                        ),
                        const _VerticalSeparator(),
                        Expanded(
                          child: _LedgerStat(
                            label: 'Pending Payouts',
                            value: controller.formatCurrency(
                              controller.transactions
                                  .where((t) => t.status == 'Pending Payout')
                                  .fold<double>(0, (s, t) => s + t.netToVendor),
                            ),
                            icon: Icons.schedule_rounded,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      children: [
                        _LedgerStat(
                          label: 'Total Volume',
                          value: controller.formatCurrency(
                            controller.transactions.fold<double>(
                              0,
                              (s, t) => s + t.grossAmount,
                            ),
                          ),
                          icon: Icons.bar_chart_rounded,
                          color: AppColors.camel,
                        ),
                        _LedgerStat(
                          label: 'Platform Revenue',
                          value: controller.formatCurrency(
                            controller.transactions.fold<double>(
                              0,
                              (s, t) => s + t.platformEarned,
                            ),
                          ),
                          icon: Icons.percent_rounded,
                          color: AppColors.success,
                        ),
                      ],
                    ),
            ),
          ),

          // ── Table ──────────────────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                outerMargin,
                0,
                outerMargin,
                outerMargin,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: Column(
                children: [
                  // Column headers
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.greyLight),
                      ),
                    ),
                    child: isWide
                        ? const _LedgerTableHeader()
                        : const SizedBox.shrink(),
                  ),

                  // Rows
                  Expanded(
                    child: Obx(
                      () => ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: controller.transactions.length,
                        separatorBuilder: (_, _) => const Divider(
                          color: AppColors.greyLight,
                          height: 1,
                        ),
                        itemBuilder: (_, i) {
                          final txn = controller.transactions[i];
                          return isWide
                              ? _LedgerRowWide(txn: txn)
                              : _LedgerRowNarrow(txn: txn);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerTableHeader extends StatelessWidget {
  const _LedgerTableHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 2, child: _ColHeader('TXN ID')),
        const Expanded(flex: 2, child: _ColHeader('CUSTOMER')),
        const Expanded(flex: 2, child: _ColHeader('VENDOR')),
        const Expanded(flex: 2, child: _ColHeader('GROSS AMT')),
        const Expanded(flex: 1, child: _ColHeader('FEE %')),
        const Expanded(flex: 2, child: _ColHeader('PLATFORM CUT')),
        const Expanded(flex: 2, child: _ColHeader('NET TO VENDOR')),
        const Expanded(flex: 1, child: _ColHeader('STATUS')),
      ],
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.grey,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _LedgerRowWide extends StatelessWidget {
  const _LedgerRowWide({required this.txn});
  final TransactionEntity txn;

  @override
  Widget build(BuildContext context) {
    final isPending = txn.status == 'Pending Payout';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              txn.id,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              txn.customerName,
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.ink),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              txn.vendorName,
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.ink),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'PKR ${txn.grossAmount.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${txn.platformFeePercent.toStringAsFixed(1)}%',
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.grey),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'PKR ${txn.platformEarned.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'PKR ${txn.netToVendor.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.camel,
              ),
            ),
          ),
          Expanded(
            child: _StatusPill(
              label: txn.status,
              color: isPending ? AppColors.warning : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerRowNarrow extends StatelessWidget {
  const _LedgerRowNarrow({required this.txn});
  final TransactionEntity txn;

  @override
  Widget build(BuildContext context) {
    final isPending = txn.status == 'Pending Payout';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                txn.id,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const Spacer(),
              _StatusPill(
                label: txn.status,
                color: isPending ? AppColors.warning : AppColors.success,
              ),
            ],
          ),
          Text(
            txn.vendorName,
            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.grey),
          ),

          Row(
            children: [
              _MiniStat(
                label: 'Gross',
                value: 'PKR ${txn.grossAmount.toStringAsFixed(0)}',
                color: AppColors.charcoal,
              ),
              const Spacer(),
              _MiniStat(
                label: 'Platform (${txn.platformFeePercent}%)',
                value: 'PKR ${txn.platformEarned.toStringAsFixed(0)}',
                color: AppColors.success,
              ),
              const Spacer(),
              _MiniStat(
                label: 'Net to Vendor',
                value: 'PKR ${txn.netToVendor.toStringAsFixed(0)}',
                color: AppColors.camel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9, color: AppColors.grey),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _LedgerStat extends StatelessWidget {
  const _LedgerStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Column(
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
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VerticalSeparator extends StatelessWidget {
  const _VerticalSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.greyLight,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}
