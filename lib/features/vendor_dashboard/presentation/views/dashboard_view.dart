import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/stat_card.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(sw),
      body: SingleChildScrollView(
        padding: .fromLTRB(sw * 0.042, sw * 0.032, sw * 0.042, sw * 0.06),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _buildHeader(sw),
            SizedBox(height: sw * 0.025),
            _buildQuickBadges(sw),
            SizedBox(height: sw * 0.035),
            _buildSectionLabel('Overview', sw),
            SizedBox(height: sw * 0.015),
            _buildStatsGrid(sw),
            SizedBox(height: sw * 0.035),
            _buildSectionLabel('Recent Activity', sw),
            SizedBox(height: sw * 0.015),
            _buildRecentActivity(sw),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(double sw) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.greyLight),
      ),
      title: Row(
        children: [
          Container(
            width: sw * 0.075,
            height: sw * 0.075,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.camel, AppColors.rose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: AppColors.white,
              size: sw * 0.038,
            ),
          ),
          SizedBox(width: sw * 0.025),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Store Admin',
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Umais Garments',
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.026,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // notification bell
        Container(
          margin: EdgeInsets.only(right: sw * 0.02),
          child: Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_outlined,
                  size: sw * 0.052,
                  color: AppColors.ink,
                ),
                tooltip: 'Notifications',
              ),
              Positioned(
                top: sw * 0.018,
                right: sw * 0.018,
                child: Container(
                  width: sw * 0.016,
                  height: sw * 0.016,
                  decoration: const BoxDecoration(
                    color: AppColors.camel,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: sw * 0.025),
          child: CustomButton(
            text: 'Exit',
            onPressed: () => Get.offAllNamed('/home'),
            variant: ButtonVariant.outlined,
            icon: Icons.logout_rounded,
            width: sw * 0.22,
            height: sw * 0.09,
          ),
        ),
      ],
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double sw) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good afternoon 👋',
                style: GoogleFonts.outfit(
                  color: AppColors.grey,
                  fontSize: sw * 0.029,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: sw * 0.005),
              Text(
                'Umais Garments',
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.054,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),
        // avatar
        Container(
          width: sw * 0.12,
          height: sw * 0.12,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.camel, AppColors.rose],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.camel.withValues(alpha: 0.3),
                blurRadius: sw * 0.03,
                offset: Offset(0, sw * 0.01),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'UG',
              style: GoogleFonts.outfit(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: sw * 0.036,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Quick Badges ──────────────────────────────────────────────────────────

  Widget _buildQuickBadges(double sw) {
    final badges = [
      {
        'label': 'Active',
        'icon': Icons.circle,
        'color': AppColors.success,
        'bg': AppColors.success,
      },
      {
        'label': '4 New Orders',
        'icon': Icons.receipt_long_rounded,
        'color': AppColors.camel,
        'bg': AppColors.camel,
      },
      {
        'label': 'Mon – Sat',
        'icon': Icons.schedule_rounded,
        'color': AppColors.ink,
        'bg': AppColors.ink,
      },
    ];

    return Wrap(
      spacing: sw * 0.022,
      runSpacing: sw * 0.016,
      children: badges.map((b) {
        final color = b['color'] as Color;
        final icon = b['icon'] as IconData;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.028,
            vertical: sw * 0.014,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(sw * 0.02),
            border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: sw * 0.028, color: color),
              SizedBox(width: sw * 0.014),
              Text(
                b['label'] as String,
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.027,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Section Label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, double sw) {
    return Row(
      children: [
        Container(
          width: sw * 0.007,
          height: sw * 0.042,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.camel, AppColors.rose],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(sw * 0.01),
          ),
        ),
        SizedBox(width: sw * 0.022),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: sw * 0.036,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ─── Stats Grid ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(double sw) {
    return Obx(
      () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: sw * 0.024,
          mainAxisSpacing: sw * 0.024,
          childAspectRatio: 1.75,
        ),
        itemCount: controller.stats.length,
        itemBuilder: (context, index) {
          final stat = controller.stats[index];
          return StatCard(stat: stat, sw: sw);
        },
      ),
    );
  }

  // ─── Recent Activity ───────────────────────────────────────────────────────

  Widget _buildRecentActivity(double sw) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(sw * 0.038),
          border: Border.all(color: AppColors.greyLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.04),
              blurRadius: sw * 0.04,
              offset: Offset(0, sw * 0.012),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(sw * 0.038),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentActivity.length,
            separatorBuilder: (_, __) => Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: sw * 0.042),
              color: AppColors.greyLight,
            ),
            itemBuilder: (context, index) {
              final activity = controller.recentActivity[index];
              final bool isPositive = activity['amount']!.startsWith('+');
              final bool isNeutral =
                  !isPositive && !activity['amount']!.startsWith('-');

              final Color dotColor = isPositive
                  ? AppColors.success
                  : isNeutral
                  ? AppColors.camel
                  : AppColors.error;

              final IconData iconData = isPositive
                  ? Icons.trending_up_rounded
                  : isNeutral
                  ? Icons.inventory_2_outlined
                  : Icons.trending_down_rounded;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.042,
                  vertical: sw * 0.022,
                ),
                child: Row(
                  children: [
                    // icon badge
                    Container(
                      width: sw * 0.088,
                      height: sw * 0.088,
                      decoration: BoxDecoration(
                        color: dotColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(sw * 0.024),
                      ),
                      child: Icon(iconData, size: sw * 0.04, color: dotColor),
                    ),
                    SizedBox(width: sw * 0.028),

                    // title + time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['title']!,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: sw * 0.032,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: sw * 0.005),
                          Text(
                            activity['time']!,
                            style: GoogleFonts.outfit(
                              color: AppColors.grey,
                              fontSize: sw * 0.026,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: sw * 0.016),

                    // amount chip
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.024,
                        vertical: sw * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: dotColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(sw * 0.016),
                      ),
                      child: Text(
                        activity['amount']!,
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.03,
                          fontWeight: FontWeight.w700,
                          color: dotColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
