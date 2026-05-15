import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'admin_dashboard_screen.dart';
import 'kyc_queue_screen.dart';
import 'catalog_moderation_screen.dart';
import 'financial_ledger_screen.dart';
import 'global_catalog_screen.dart';
import 'user_management_screen.dart';
import 'financial_rules_screen.dart';
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
    FinancialRulesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(AdminCrudController());
    final isDesktop = context.isDesktopView;
    final isTablet = context.isTabletView;
    final isMobile = context.isMobileView;

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
          ? AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(
                color: AppColors.charcoal,
                size: 20,
              ),
              title: Obx(
                () => Text(
                  _items[controller.selectedSidebarIndex.value].label
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: context.wp(2.5).clamp(16, 20),
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              centerTitle: true,
              shape: const Border(
                bottom: BorderSide(color: AppColors.greyLight, width: 0.5),
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
        width: context.wp(18).clamp(200, 260),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            right: BorderSide(color: AppColors.greyLight, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.camel,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aura',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: AppColors.grey,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'NAVIGATION',
                style: GoogleFonts.outfit(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 6),

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
                      onTap: () => controller.changeSidebarIndex(i),
                    );
                  });
                },
              ),
            ),

            // Footer
            const Divider(color: AppColors.greyLight, height: 1),
            _SidebarFooter(),
            const SizedBox(height: 20),
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
    return Container(
      width: 68,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.greyLight, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.camel,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 24),
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
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.all(10),
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
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                size: 20,
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
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  size: 17,
                  color: isActive ? AppColors.camel : AppColors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.camel : AppColors.ink,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 4,
                    height: 4,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: _signOut,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.camel.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: AppColors.camel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Super Admin',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        'admin@aura.pk',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.logout_rounded,
                  size: 16,
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
  Get.find<AuthController>().selectedRole.value = AuthRole.shopper;
  Get.offAllNamed('/onboarding');
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
      child: const Center(
        child: Text(
          'SA',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.camel,
          ),
        ),
      ),
    );
  }
}
