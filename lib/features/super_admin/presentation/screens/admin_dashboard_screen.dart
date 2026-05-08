import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_card.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_ping_badge.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_widgets.dart';

class AdminDashboardScreen extends GetView<AdminController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopView;
    final isTablet = context.isTabletView;

    final outerPadding = context.wp(2.5).clamp(12.0, 20.0);
    final titleSize = context.wp(4).clamp(18.0, 24.0);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(outerPadding, 12, outerPadding, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Good evening, Admin.',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Obx(
                        () => AdminPingBadge(
                          label: 'Live',
                          isActive: controller.kycQueue.isNotEmpty,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Here\'s your platform summary for today.',
                    style: GoogleFonts.outfit(
                      fontSize: context.wp(2.5).clamp(10.0, 11.5),
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      outerPadding,
                      8,
                      outerPadding,
                      18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: (isDesktop || isTablet)
                          ? _WideDashboardLayout(controller: controller)
                          : _NarrowDashboardLayout(controller: controller),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideDashboardLayout extends StatelessWidget {
  const _WideDashboardLayout({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: .stretch,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Obx(
                      () => AdminStatCard(
                        title: 'Total GMV',
                        value: controller.formatCurrency(
                          controller.totalGmv.value,
                        ),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.camel,
                        trend: '+12.4%',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => AdminStatCard(
                        title: 'Commission Earned',
                        value: controller.formatCurrency(
                          controller.totalCommission.value,
                        ),
                        icon: Icons.percent_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => AdminStatCard(
                        title: 'Pending Payouts',
                        value: controller.formatCurrency(
                          controller.pendingPayouts.value,
                        ),
                        icon: Icons.schedule_send_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: _ActivityFeedCard(controller: controller),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _OperationCountCard(
                  label: 'KYC Awaiting',
                  count: controller.kycQueue.length,
                  icon: Icons.verified_user_outlined,
                  color: AppColors.camel,
                  onTap: () => controller.changeSidebarIndex(1),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _OperationCountCard(
                  label: 'Moderation Queue',
                  count: controller.pendingProducts.length,
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.rose,
                  onTap: () => controller.changeSidebarIndex(2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OperationCountCard(
                label: 'System Ledger',
                count: 142,
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.charcoal,
                onTap: () => controller.changeSidebarIndex(3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NarrowDashboardLayout extends StatelessWidget {
  const _NarrowDashboardLayout({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => AdminStatCard(
            title: 'Total GMV',
            value: controller.formatCurrency(controller.totalGmv.value),
            icon: Icons.trending_up_rounded,
            color: AppColors.camel,
            trend: '+12.4%',
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => AdminStatCard(
            title: 'Commission Earned',
            value: controller.formatCurrency(controller.totalCommission.value),
            icon: Icons.percent_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => AdminStatCard(
            title: 'Pending Payouts',
            value: controller.formatCurrency(controller.pendingPayouts.value),
            icon: Icons.schedule_send_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _OperationCountCard(
                  label: 'KYC Awaiting',
                  count: controller.kycQueue.length,
                  icon: Icons.verified_user_outlined,
                  color: AppColors.camel,
                  onTap: () => controller.changeSidebarIndex(1),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(
                () => _OperationCountCard(
                  label: 'Moderation',
                  count: controller.pendingProducts.length,
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.rose,
                  onTap: () => controller.changeSidebarIndex(2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ActivityFeedCard(controller: controller),
      ],
    );
  }
}

class _OperationCountCard extends StatelessWidget {
  const _OperationCountCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.grey,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActivityFeedCard extends StatelessWidget {
  const _ActivityFeedCard({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionHeader(
            title: 'Recent Activity',
            trailing: const AdminPingBadge(label: 'Live'),
          ),
          const SizedBox(height: 4),
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.activityFeed.length.clamp(0, 8),
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                final item = controller.activityFeed[i];
                return _ActivityTile(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final ActivityFeedItem item;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (item.type) {
      case ActivityType.approval:
        color = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case ActivityType.rejection:
        color = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
      case ActivityType.payout:
        color = AppColors.camel;
        icon = Icons.payments_outlined;
        break;
      case ActivityType.vendorSignup:
        color = AppColors.sage;
        icon = Icons.storefront_outlined;
        break;
      case ActivityType.transaction:
        color = AppColors.ink;
        icon = Icons.receipt_long_outlined;
        break;
    }

    return AdminActivityTile(
      title: item.title,
      subtitle: item.subtitle,
      time: item.time,
      icon: icon,
      iconColor: color,
    );
  }
}
