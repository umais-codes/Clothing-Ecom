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
                      _confirmSwitch(
                        context,
                        'Consumer Mode',
                        () => authController.setRole(AuthRole.shopper),
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
    // 1. Consumer Mode switches immediately (anyone can act as shopper)
    if (targetRole == AuthRole.shopper) {
      _confirmSwitch(
        context,
        roleName,
        () => authController.setRole(AuthRole.shopper),
      );
      return;
    }

    // 2. Admin switch goes directly to admin login flow
    if (targetRole == AuthRole.admin) {
      _confirmSwitch(context, roleName, () => Get.toNamed('/admin-login'));
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
      final user = authController.currentUser;
      if (user == null) {
        Get.back(); // close loader
        _showPermissionRequiredDialog(context, authController, targetRole);
        return;
      }

      final supabase = Get.find<SupabaseService>().client;
      final res = await supabase
          .from('vendors')
          .select('*')
          .eq('owner_id', user.id)
          .maybeSingle();

      Get.back(); // close loader
      if (!context.mounted) return;

      if (res == null) {
        _showPermissionRequiredDialog(context, authController, targetRole);
      } else {
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

        if (!context.mounted) return;

        final roleStr = profile?['role']?.toString() ?? 'vendor';
        final kycStatus =
            res['kyc_status']?.toString().toLowerCase() ?? 'pending';

        final isCorrectRole =
            (targetRole == AuthRole.vendor && roleStr == 'vendor') ||
            (targetRole == AuthRole.corporate && roleStr == 'corporate');

        if (!isCorrectRole) {
          _showPermissionRequiredDialog(context, authController, targetRole);
          return;
        }

        if (kycStatus == 'approved') {
          _confirmSwitch(
            context,
            roleName,
            () => authController.setRole(targetRole),
          );
        } else if (kycStatus == 'rejected') {
          CustomPermissionDialog.show(
            context: context,
            icon: Icons.cancel_outlined,
            title: 'Application Rejected',
            description:
                'Your application has been rejected. Please contact partner support for more information.',
            grantText: 'Close',
            denyText: 'Not Now',
            onGrant: () {},
          );
        } else {
          CustomPermissionDialog.show(
            context: context,
            icon: Icons.hourglass_top_rounded,
            title: 'Application Pending',
            description:
                'Your application is currently pending admin approval. You will receive portal access once approved.',
            grantText: 'Close',
            denyText: 'Not Now',
            onGrant: () {},
          );
        }
      }
    } catch (e) {
      Get.back(); // close loader
      if (!context.mounted) return;
      _showPermissionRequiredDialog(context, authController, targetRole);
    }
  }

  void _showPermissionRequiredDialog(
    BuildContext context,
    AuthController authController,
    AuthRole targetRole,
  ) {
    CustomPermissionDialog.show(
      context: context,
      icon: Icons.lock_outline,
      title: 'Permission Required',
      description:
          'You have not registered for a ${targetRole == AuthRole.vendor ? "Vendor" : "Corporate"} partner account yet. To access this portal, please apply first.',
      grantText: 'Register Now',
      denyText: 'Cancel',
      onGrant: () {
        authController.setRole(targetRole);
        Get.to(() => const AuthGatewayScreen());
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
