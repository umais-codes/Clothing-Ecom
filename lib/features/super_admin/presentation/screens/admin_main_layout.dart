import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import 'admin_dashboard_screen.dart';
import 'kyc_queue_screen.dart';
import 'catalog_moderation_screen.dart';
import 'financial_ledger_screen.dart';
import 'global_catalog_screen.dart';
import 'user_management_screen.dart';
import 'financial_rules_screen.dart';
import 'monetization_dashboard_screen.dart';
import '../controllers/admin_crud_controller.dart';

class AdminMainLayout extends GetView<AdminController> {
  const AdminMainLayout({super.key});

  static const List<_SidebarItem> _items = [
    _SidebarItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _SidebarItem(
      icon: Icons.verified_user_outlined,
      activeIcon: Icons.verified_user_rounded,
      label: 'KYC Queue',
    ),
    _SidebarItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Moderation',
    ),
    _SidebarItem(
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance_rounded,
      label: 'Ledger',
    ),
    _SidebarItem(
      icon: Icons.inventory_outlined,
      activeIcon: Icons.inventory_rounded,
      label: 'Global Catalog',
    ),
    _SidebarItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'User Management',
    ),
    _SidebarItem(
      icon: Icons.monetization_on_outlined,
      activeIcon: Icons.monetization_on_rounded,
      label: 'Monetization',
    ),
    _SidebarItem(
      icon: Icons.settings_suggest_outlined,
      activeIcon: Icons.settings_suggest_rounded,
      label: 'Platform Rules',
    ),
  ];

  static const List<Widget> _pages = [
    AdminDashboardScreen(),
    KycQueueScreen(),
    CatalogModerationScreen(),
    FinancialLedgerScreen(),
    GlobalCatalogScreen(),
    UserManagementScreen(),
    MonetizationDashboardScreen(),
    FinancialRulesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(AdminCrudController());
    final isDesktop = context.isDesktopView;
    final isTablet = context.isTabletView;
    final isMobile = context.isMobileView;
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      drawer: isMobile
          ? Drawer(
              width: context.wp(75).clamp(240, 300),
              backgroundColor: AppColors.white,
              child: _FullSidebar(items: _items, controller: controller),
            )
          : null,
      appBar: isMobile
          ? CustomAppBar(
              elevation: 0,
              showBackButton: false,
              leading: Builder(
                builder: (innerContext) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: AppColors.charcoal,
                  iconSize: context.sp(sw * 0.06),
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                ),
              ),
              titleWidget: Obx(
                () => Text(
                  _items[controller.selectedSidebarIndex.value].label
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(sw * 0.05),
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            )
          : null,
      body: Row(
        children: [
          // ── Sidebar / Rail ──────────────────────────────────────────────────
          if (isDesktop)
            _FullSidebar(items: _items, controller: controller)
          else if (isTablet)
            _CollapsedRail(items: _items, controller: controller),

          // ── Content Area ────────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top header for Desktop/Tablet (Simplified)
                if (!isMobile)
                  Container(
                    height: context.hp(6).clamp(50, 64),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.wp(2.5).clamp(12.0, 24.0),
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.greyLight,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Obx(
                          () => Text(
                            _items[controller.selectedSidebarIndex.value].label,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const _AdminProfileBadge(),
                      ],
                    ),
                  ),

                // Actual Page Content
                Expanded(
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOut,
                      child: _pages[controller.selectedSidebarIndex.value],
                    ),
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

// ── Full Sidebar (Desktop/Mobile) ─────────────────────────────────────────────
class _FullSidebar extends StatelessWidget {
  const _FullSidebar({required this.items, required this.controller});
  final List<_SidebarItem> items;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: context.isMobileView ? null : context.wp(18).clamp(200, 260),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            right: BorderSide(color: AppColors.greyLight, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: context.hp(2.5)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.camel,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Velvet Maison',
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Admin Panel',
                          style: GoogleFonts.outfit(
                            fontSize: context.sp(10),
                            color: AppColors.grey,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.hp(2.5)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.wp(4)),
              child: Text(
                'NAVIGATION',
                style: GoogleFonts.outfit(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Nav items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  return Obx(() {
                    final isActive = controller.selectedSidebarIndex.value == i;
                    return _SidebarTile(
                      item: items[i],
                      isActive: isActive,
                      onTap: () {
                        controller.changeSidebarIndex(i);
                        if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                          Get.back();
                        }
                      },
                    );
                  });
                },
              ),
            ),

            // Footer
            const Divider(color: AppColors.greyLight, height: 1),
            _SidebarFooter(),
            SizedBox(height: context.hp(2)),
          ],
        ),
      ),
    );
  }
}

// ── Collapsed Rail (Tablet) ───────────────────────────────────────────────────
class _CollapsedRail extends StatelessWidget {
  const _CollapsedRail({required this.items, required this.controller});
  final List<_SidebarItem> items;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    return Container(
      width: sw * 0.1,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.greyLight, width: 1)),
      ),
      child: Column(
        children: [
          SizedBox(height: sw * 0.04),
          Container(
            width: sw * 0.08,
            height: sw * 0.08,
            decoration: BoxDecoration(
              color: AppColors.camel,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: AppColors.white,
              size: sw * 0.05,
            ),
          ),
          SizedBox(height: sw * 0.05),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                return Obx(() {
                  final isActive = controller.selectedSidebarIndex.value == i;
                  final item = items[i];
                  return Tooltip(
                    message: item.label,
                    preferBelow: false,
                    child: InkWell(
                      onTap: () => controller.changeSidebarIndex(i),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: sw * 0.025,
                          vertical: 4,
                        ),
                        padding: EdgeInsets.all(sw * 0.025),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.camel.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 22,
                          color: isActive ? AppColors.camel : AppColors.grey,
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: sw * 0.04),
            child: IconButton(
              icon: Icon(
                Icons.logout_rounded,
                size: sw * 0.05,
                color: AppColors.grey,
              ),
              tooltip: 'Sign Out',
              onPressed: _signOut,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual sidebar tile ────────────────────────────────────────────────────
class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(4),
              vertical: context.hp(1.4),
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.camel.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: context.sp(20),
                  color: isActive ? AppColors.camel : AppColors.grey,
                ),
                SizedBox(width: context.wp(3)),
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.outfit(
                      fontSize: context.sp(14.5),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.camel : AppColors.ink,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.camel,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sidebar footer ────────────────────────────────────────────────────────────
class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.wp(3),
        vertical: context.hp(1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: _signOut,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(3),
              vertical: context.hp(1),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.camel.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: context.sp(20),
                    color: AppColors.camel,
                  ),
                ),
                SizedBox(width: context.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Super Admin',
                        style: GoogleFonts.outfit(
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        'admin@velvetmaison.pk',
                        style: GoogleFonts.outfit(
                          fontSize: context.sp(10),
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.logout_rounded,
                  size: context.sp(20),
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _signOut() {
  final context = Get.context;
  if (context == null) return;

  CustomPermissionDialog.show(
    context: context,
    icon: Icons.logout_rounded,
    title: 'Sign Out?',
    description: 'Are you sure you want to sign out of the Admin Panel?',
    grantText: 'Log Out',
    denyText: 'Cancel',
    onGrant: () {
      Get.find<AuthController>().selectedRole.value = AuthRole.shopper;
      Get.offAllNamed('/onboarding');
    },
  );
}

// ── Data class ────────────────────────────────────────────────────────────────
class _SidebarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _AdminProfileBadge extends StatelessWidget {
  const _AdminProfileBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.camel.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.camel.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'SA',
          style: GoogleFonts.outfit(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w700,
            color: AppColors.camel,
          ),
        ),
      ),
    );
  }
}
