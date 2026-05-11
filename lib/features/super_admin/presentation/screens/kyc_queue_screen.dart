import 'package:ecom_app/app/widgets/app_downloader.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_ping_badge.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_widgets.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/screen_header.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_card.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';

class KycQueueScreen extends GetView<AdminController> {
  const KycQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopView;
    final isTablet = context.isTabletView;
    final isSplit = isDesktop || isTablet;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            title: 'KYC & Onboarding Queue',
            subtitle: 'Review pending vendor applications',
            trailing: Obx(
              () => AdminPingBadge(
                count: controller.kycQueue.length,
                label: 'Pending',
              ),
            ),
          ),

          Expanded(
            child: isSplit
                ? Row(
                    children: [
                      const VerticalDivider(
                        color: AppColors.greyLight,
                        width: 1,
                      ),

                      Expanded(
                        flex: isDesktop ? 2 : 3,
                        child: _VendorTable(controller: controller),
                      ),

                      Expanded(
                        flex: isDesktop ? 3 : 4,
                        child: Obx(
                          () => controller.selectedVendor.value != null
                              ? _VendorDetailPanel(
                                  vendor: controller.selectedVendor.value!,
                                  controller: controller,
                                )
                              : const AdminEmptyState(
                                  message: 'Select a vendor to review',
                                  icon: Icons.touch_app_outlined,
                                ),
                        ),
                      ),
                    ],
                  )
                : _VendorTable(
                    controller: controller,
                    onSelectNarrow: (v) => _showBottomSheet(v),
                  ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(KycVendorEntity vendor) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.96,
        expand: false,
        builder: (_, scrollCtrl) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 6),

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 6),

                Expanded(
                  child: _VendorDetailPanel(
                    vendor: vendor,
                    controller: controller,
                    scrollController: scrollCtrl,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      enterBottomSheetDuration: const Duration(milliseconds: 250),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vendor Table
// ─────────────────────────────────────────────────────────────────────────────

class _VendorTable extends StatelessWidget {
  const _VendorTable({required this.controller, this.onSelectNarrow});

  final AdminController controller;
  final void Function(KycVendorEntity)? onSelectNarrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.greyLight.withValues(alpha: 0.25),
              border: const Border(
                top: BorderSide(color: AppColors.greyLight, width: 0.8),
                bottom: BorderSide(color: AppColors.greyLight, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'BRAND',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal.withValues(alpha: 0.5),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'CATEGORY',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal.withValues(alpha: 0.5),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'APPLIED',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal.withValues(alpha: 0.5),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(
              () => controller.kycQueue.isEmpty
                  ? const AdminEmptyState(
                      message: 'No pending KYC applications.',
                    )
                  : ListView.builder(
                      itemCount: controller.kycQueue.length,
                      itemBuilder: (_, i) {
                        final vendor = controller.kycQueue[i];

                        return Obx(() {
                          final isSelected =
                              controller.selectedVendor.value?.id == vendor.id;

                          return _VendorRow(
                            vendor: vendor,
                            isSelected: isSelected,
                            onTap: () {
                              if (onSelectNarrow != null) {
                                onSelectNarrow!(vendor);
                              } else {
                                controller.selectVendor(vendor);
                              }
                            },
                          );
                        });
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorRow extends StatelessWidget {
  const _VendorRow({
    required this.vendor,
    required this.isSelected,
    required this.onTap,
  });

  final KycVendorEntity vendor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.camel.withValues(alpha: 0.09)
              : Colors.transparent,
          border: Border(
            bottom: const BorderSide(color: AppColors.greyLight, width: 0.6),
            left: BorderSide(
              color: isSelected ? AppColors.camel : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  AdminAvatar(name: vendor.brandName, size: 38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          vendor.ownerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    vendor.category,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vendor.appliedDate.split(',')[0],
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '2026',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: AppColors.grey,
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

class _VendorDetailPanel extends StatelessWidget {
  const _VendorDetailPanel({
    required this.vendor,
    required this.controller,
    this.scrollController,
  });

  final KycVendorEntity vendor;
  final AdminController controller;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.offWhite,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: AppColors.white,
            child: Row(
              children: [
                AdminAvatar(name: vendor.brandName, size: 42),

                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.brandName,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '${vendor.city} • ${vendor.category}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                AdminStatusBadge(status: vendor.status.name),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.greyLight),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AdminSectionHeader(title: 'VENDOR IDENTITY'),
                  const SizedBox(height: 12),
                  AdminCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        AdminInfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Owner Name',
                          value: vendor.ownerName,
                        ),
                        AdminInfoRow(
                          icon: Icons.category_outlined,
                          label: 'Business Category',
                          value: vendor.category,
                        ),
                        AdminInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Applied Date',
                          value: vendor.appliedDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const AdminSectionHeader(title: 'CONTACT DETAILS'),
                  const SizedBox(height: 12),
                  AdminCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        AdminInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: vendor.email,
                        ),
                        AdminInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: vendor.phone,
                        ),
                        AdminInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'City',
                          value: vendor.city,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const AdminSectionHeader(title: 'BRAND OVERVIEW'),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    child: Text(
                      vendor.bio,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.ink,
                        height: 1.7,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const AdminSectionHeader(title: 'VERIFICATION DOCUMENTS'),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _DocumentCard(
                          label: 'CNIC / National ID',
                          imageUrl: vendor.cnicDocUrl,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _DocumentCard(
                          label: 'SECP Certificate',
                          imageUrl: vendor.secpDocUrl,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.greyLight, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Reject',
                    variant: ButtonVariant.outlined,
                    icon: Icons.close_rounded,
                    textColor: AppColors.error,
                    onPressed: () {
                      controller.rejectVendor(vendor.id);
                      Get.back();
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: CustomButton(
                    text: 'Approve',
                    variant: ButtonVariant.primary,
                    icon: Icons.check_rounded,
                    onPressed: () {
                      controller.approveVendor(vendor.id);
                      Get.back();
                    },
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.label, required this.imageUrl});

  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const .vertical(top: Radius.circular(11)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 130,
                  width: .infinity,
                  fit: .cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AppDownloader(url: imageUrl, fileName: label),
              ),
            ],
          ),

          Padding(
            padding: const .symmetric(horizontal: 8, vertical: 4),
            child: Text(
              label,
              textAlign: .center,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: .w600,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

