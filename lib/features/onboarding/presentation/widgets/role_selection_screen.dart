import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_network_image.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ecom_app/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class RoleSelectionScreen extends GetView<OnboardingController> {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = context.screenWidth;
    final h = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Back + Progress ────────────────────────────────────────────
            Padding(
              padding: .fromLTRB(w * 0.03, h * 0.015, w * 0.05, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.prevPage,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    color: AppColors.charcoal,
                  ),
                  Expanded(child: OnboardingProgressBar(step: 2, total: 4)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: .fromLTRB(w * 0.07, h * 0.01, w * 0.07, h * 0.01),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // ── Step label ──────────────────────────────────────────
                    Container(
                      padding: .symmetric(
                        horizontal: w * 0.03,
                        vertical: h * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.camelLight,
                        borderRadius: .circular(4),
                      ),
                      child: Text(
                        'STEP 1 OF 3',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.camel,
                          fontSize: w * 0.025,
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.01),

                    // ── Headline ────────────────────────────────────────────
                    Text(
                      'Tailor your journey',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: w * 0.08,
                      ),
                    ),

                    SizedBox(height: h * 0.01),

                    Text(
                      'Choose your curated experience to unlock personalised features designed for you.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: w * 0.03,
                        color: AppColors.grey,
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    // ── Role Cards ──────────────────────────────────────────
                    Obx(
                      () => Column(
                        children: [
                          _PremiumRoleCard(
                            role: UserRole.shopper,
                            selected:
                                controller.selectedRole.value ==
                                UserRole.shopper,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              controller.selectRole(UserRole.shopper);
                            },
                            title: 'Personal Shopper',
                            subtitle: 'Browse authentic brands & AI size tech.',
                            image: controller.roleImages[UserRole.shopper]!,
                            tag: 'B2C',
                          ),
                          SizedBox(height: h * 0.02),
                          _PremiumRoleCard(
                            role: UserRole.corporateBuyer,
                            selected:
                                controller.selectedRole.value ==
                                UserRole.corporateBuyer,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              controller.selectRole(UserRole.corporateBuyer);
                            },
                            title: 'Corporate Client',
                            subtitle: 'Bulk orders & dedicated portal.',
                            image:
                                controller.roleImages[UserRole.corporateBuyer]!,
                            tag: 'B2B',
                          ),
                          SizedBox(height: h * 0.02),
                          _PremiumRoleCard(
                            role: UserRole.fashionBrand,
                            selected:
                                controller.selectedRole.value ==
                                UserRole.fashionBrand,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              controller.selectRole(UserRole.fashionBrand);
                            },
                            title: 'Fashion Brand',
                            subtitle: 'List products & scale your label.',
                            image:
                                controller.roleImages[UserRole.fashionBrand]!,
                            tag: 'VENDOR',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.05),

                    // ── CTA ─────────────────────────────────────────────────
                    Obx(
                      () => CustomButton(
                        text: 'Initialize Experience',
                        onPressed: controller.selectedRole.value != null
                            ? controller.nextPage
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumRoleCard extends StatelessWidget {
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final String image;
  final String tag;

  const _PremiumRoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = context.screenWidth;

    return AnimatedScale(
      scale: selected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: w * 0.31,
          decoration: BoxDecoration(
            borderRadius: .circular(w * 0.045),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.camel.withValues(alpha: 0.15)
                    : AppColors.charcoal.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: .circular(w * 0.045),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomNetworkImage(imageUrl: image, fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: .centerLeft,
                        end: .centerRight,
                        colors: [
                          selected
                              ? AppColors.charcoal.withValues(alpha: 0.85)
                              : AppColors.charcoal.withValues(alpha: 0.65),
                          AppColors.charcoal.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: .symmetric(horizontal: w * 0.06),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: .center,
                          crossAxisAlignment: .start,
                          children: [
                            Container(
                              padding: .symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.camel
                                    : AppColors.white.withValues(alpha: 0.2),
                                borderRadius: .circular(4),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.white,
                                  fontSize: 9,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: AppColors.white,
                                fontSize: w * 0.05,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: w * 0.03,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Check icon
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: selected ? 1.0 : 0.0,
                        child: Container(
                          padding: const .all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.camel,
                            shape: .circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: w * 0.026,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (selected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: .circular(w * 0.045),
                        border: .all(color: AppColors.camel, width: 2.5),
                      ),
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
