import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import 'package:ecom_app/features/auth/presentation/screens/auth_gateway_screen.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';

class PerspectiveSwitcher extends StatelessWidget {
  const PerspectiveSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final w = context.screenWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('Switch Perspective', style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(w * 0.04),
            border: Border.all(color: AppColors.greyLight, width: 1),
          ),
          child: Obx(() {
            final activeRole = authController.selectedRole.value;

            return Column(
              children: [
                ProfileMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Consumer Mode',
                  onTap: () {
                    if (activeRole != AuthRole.shopper) {
                      _trySwitchRole(
                        context,
                        authController,
                        AuthRole.shopper,
                        'Consumer Mode',
                      );
                    }
                  },
                  trailing: activeRole == AuthRole.shopper
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.camel,
                          size: w * 0.06,
                        )
                      : null,
                ),
                ProfileMenuItem(
                  icon: Icons.storefront_outlined,
                  title: 'Vendor Portal',
                  onTap: () {
                    if (activeRole != AuthRole.vendor) {
                      _trySwitchRole(
                        context,
                        authController,
                        AuthRole.vendor,
                        'Vendor Portal',
                      );
                    }
                  },
                  trailing: activeRole == AuthRole.vendor
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.camel,
                          size: w * 0.06,
                        )
                      : null,
                ),
                ProfileMenuItem(
                  icon: Icons.business_outlined,
                  title: 'Corporate Sourcing',
                  onTap: () {
                    if (activeRole != AuthRole.corporate) {
                      _trySwitchRole(
                        context,
                        authController,
                        AuthRole.corporate,
                        'Corporate Sourcing',
                      );
                    }
                  },
                  trailing: activeRole == AuthRole.corporate
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.camel,
                          size: w * 0.06,
                        )
                      : null,
                ),
                ProfileMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Super Admin Control',
                  onTap: () {
                    if (activeRole != AuthRole.admin) {
                      _trySwitchRole(
                        context,
                        authController,
                        AuthRole.admin,
                        'Super Admin Control',
                      );
                    }
                  },
                  trailing: activeRole == AuthRole.admin
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.camel,
                          size: w * 0.06,
                        )
                      : null,
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  void _trySwitchRole(
    BuildContext context,
    AuthController authController,
    AuthRole targetRole,
    String roleName,
  ) async {
    // Admin switch goes directly to admin login flow
    if (targetRole == AuthRole.admin) {
      _confirmSwitch(context, roleName, () => Get.toNamed('/admin-login'));
      return;
    }

    final user = authController.currentUser;
    if (user == null) {
      _showRoleAccountMismatchDialog(
        context: context,
        authController: authController,
        currentRoleName: 'Guest',
        targetRole: targetRole,
        targetRoleName: roleName,
      );
      return;
    }

    // Show backdrop loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.camel),
        ),
      ),
    );

    try {
      final supabase = Get.find<SupabaseService>().client;

      // 1. Fetch user's actual database registered profile
      Map<String, dynamic>? profile;
      try {
        profile = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();
      } catch (pe) {
        debugPrint('Failed to load user profile role in switcher: $pe');
      }

      final String dbRole =
          profile?['role']?.toString().toLowerCase() ?? 'shopper';

      // 2. Fetch vendor registration details
      Map<String, dynamic>? vendorRes;
      try {
        vendorRes = await supabase
            .from('vendors')
            .select('*')
            .eq('owner_id', user.id)
            .maybeSingle();
      } catch (_) {}

      Get.back(); // close loader
      if (!context.mounted) return;

      // Case A: Switching to Shopper when logged in with a Vendor/Corporate account
      if (targetRole == AuthRole.shopper) {
        if (dbRole == 'vendor' || vendorRes != null || dbRole == 'corporate') {
          _showRoleAccountMismatchDialog(
            context: context,
            authController: authController,
            currentRoleName: dbRole.toUpperCase(),
            targetRole: AuthRole.shopper,
            targetRoleName: 'Consumer Mode',
          );
        } else {
          _confirmSwitch(
            context,
            roleName,
            () => authController.setRole(AuthRole.shopper),
          );
        }
        return;
      }

      // Case B: Switching to Vendor
      if (targetRole == AuthRole.vendor) {
        if (vendorRes == null ||
            (dbRole != 'vendor' && dbRole.isNotEmpty && dbRole != 'shopper')) {
          _showRoleAccountMismatchDialog(
            context: context,
            authController: authController,
            currentRoleName: dbRole.toUpperCase(),
            targetRole: AuthRole.vendor,
            targetRoleName: 'Vendor Portal',
          );
          return;
        }

        final String kycStatus =
            vendorRes['kyc_status']?.toString().toLowerCase() ?? 'pending';

        if (kycStatus == 'approved') {
          _confirmSwitch(
            context,
            roleName,
            () => authController.setRole(AuthRole.vendor),
          );
        } else if (kycStatus == 'rejected') {
          CustomPermissionDialog.show(
            context: context,
            icon: Icons.cancel_outlined,
            iconColor: AppColors.error,
            iconBgColor: AppColors.errorBg,
            title: 'Application Rejected',
            description:
                'Your vendor application was rejected. Please contact partner support.',
            grantText: 'Close',
            denyText: 'Not Now',
            onGrant: () {},
          );
        } else {
          CustomPermissionDialog.show(
            context: context,
            icon: Icons.hourglass_top_rounded,
            iconColor: AppColors.warning,
            iconBgColor: AppColors.warningBg,
            title: 'Application Pending',
            description:
                'Your vendor partner application is pending admin approval.',
            grantText: 'Close',
            denyText: 'Not Now',
            onGrant: () {},
          );
        }
        return;
      }

      // Case C: Switching to Corporate
      if (targetRole == AuthRole.corporate) {
        if (dbRole != 'corporate') {
          _showRoleAccountMismatchDialog(
            context: context,
            authController: authController,
            currentRoleName: dbRole.toUpperCase(),
            targetRole: AuthRole.corporate,
            targetRoleName: 'Corporate Sourcing',
          );
          return;
        }

        _confirmSwitch(
          context,
          roleName,
          () => authController.setRole(AuthRole.corporate),
        );
        return;
      }
    } catch (e) {
      Get.back(); // close loader
      if (!context.mounted) return;
      _showRoleAccountMismatchDialog(
        context: context,
        authController: authController,
        currentRoleName: 'Current Account',
        targetRole: targetRole,
        targetRoleName: roleName,
      );
    }
  }

  void _showRoleAccountMismatchDialog({
    required BuildContext context,
    required AuthController authController,
    required String currentRoleName,
    required AuthRole targetRole,
    required String targetRoleName,
  }) {
    IconData dialogIcon = Icons.manage_accounts_rounded;
    String cleanTargetName = targetRoleName;
    if (targetRole == AuthRole.vendor) {
      dialogIcon = Icons.storefront_rounded;
      cleanTargetName = "Vendor";
    } else if (targetRole == AuthRole.corporate) {
      dialogIcon = Icons.business_center_rounded;
      cleanTargetName = "Corporate";
    } else if (targetRole == AuthRole.shopper) {
      dialogIcon = Icons.shopping_bag_rounded;
      cleanTargetName = "Shopper";
    }

    CustomPermissionDialog.show(
      context: context,
      icon: dialogIcon,
      title: 'Separate Account Required',
      description: Text.rich(
        TextSpan(
          text: 'You are currently signed in with a ',
          style: GoogleFonts.outfit(
            fontSize: context.sp(12),
            color: AppColors.grey,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: '$currentRoleName ',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            const TextSpan(text: 'account. To access '),
            TextSpan(
              text: '$targetRoleName, ',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: AppColors.camel,
              ),
            ),
            const TextSpan(
              text: 'please sign in with your separate credentials.',
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      grantText: 'Sign in to $cleanTargetName',
      denyText: 'Stay on Account',
      onGrant: () async {
        await authController.signOut();
        authController.setRole(targetRole);
        Get.offAll(() => const AuthGatewayScreen());
      },
    );
  }

  void _confirmSwitch(
    BuildContext context,
    String name,
    VoidCallback onConfirm,
  ) {
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.swap_horiz_rounded,
      title: 'Switch Perspective?',
      description: Text.rich(
        TextSpan(
          text: 'Are you sure you want to switch to ',
          style: GoogleFonts.outfit(
            fontSize: context.sp(14),
            color: AppColors.grey,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: name,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            const TextSpan(text: '?'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      grantText: 'Switch',
      denyText: 'Cancel',
      onGrant: onConfirm,
    );
  }
}
