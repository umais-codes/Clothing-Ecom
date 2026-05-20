import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import '../controllers/global_catalog_edit_controller.dart';
import '../widgets/admin_card.dart';
import '../widgets/admin_form_widgets.dart';

class GlobalCatalogEditScreen extends GetView<GlobalCatalogEditController> {
  const GlobalCatalogEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GlobalCatalogEditController>()) {
      Get.put(GlobalCatalogEditController(product: Get.arguments));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EE),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4).clamp(16.0, 28.0),
            vertical: context.hp(2).clamp(16.0, 24.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageGallery(context),
              SizedBox(height: context.hp(2).clamp(16, 20)),
              _buildIdentityCard(context),
              SizedBox(height: context.hp(1.5).clamp(12, 16)),
              _buildPricingCard(context),
              SizedBox(height: context.hp(1.5).clamp(12, 16)),
              _buildDescriptionCard(context),
              SizedBox(height: context.hp(3).clamp(24, 32)),
              _buildCommitButton(),
              SizedBox(height: context.hp(2).clamp(16, 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: .symmetric(
            horizontal: context.wp(2).clamp(8, 12),
            vertical: context.wp(2).clamp(8, 12),
          ),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(10),
            border: .all(color: AppColors.greyLight, width: 1),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15,
            color: AppColors.charcoal,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            controller.product == null ? 'New Catalog Entry' : 'Catalog Audit',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
              letterSpacing: -0.2,
            ),
          ),
          if (controller.product != null)
            Text(
              controller.product!.name,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: controller.discardChanges,
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.greyLight, width: 1),
            ),
            child: Center(
              child: Text(
                'Discard',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.greyLight.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  // ── Image Gallery ───────────────────────────────────────────────────────────

  Widget _buildImageGallery(BuildContext context) {
    final tileSize = context.hp(11).clamp(78.0, 90.0);

    return AdminCard(
      padding: EdgeInsets.all(context.wp(3.5).clamp(14, 18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row — static icon + reactive count badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.camelLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 15,
                  color: AppColors.camel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Product Gallery',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              // Only this widget reacts to galleryImages changes
              AdminImageCountBadge(count: controller.galleryImages.length.obs),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'First image will be used as the primary display photo.',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: context.hp(1.5).clamp(10, 14)),

          // Horizontal thumbnail row — only list rebuilds on image changes
          SizedBox(
            height: tileSize,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  AdminAddPhotoTile(
                    size: tileSize,
                    isLoading: controller.isPickingImage,
                    onTap: controller.addImage,
                  ),
                  SizedBox(width: context.wp(2).clamp(8, 12)),
                  ...List.generate(
                    controller.galleryImages.length,
                    (i) => _ImageThumbnail(
                      key: ValueKey(controller.galleryImages[i]),
                      path: controller.galleryImages[i],
                      isPrimary: i == 0,
                      size: tileSize,
                      spacing: context.wp(2).clamp(8, 12),
                      onRemove: () => controller.removeImage(i),
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

  // ── Identity Card ───────────────────────────────────────────────────────────

  Widget _buildIdentityCard(BuildContext context) {
    return AdminCard(
      padding: EdgeInsets.all(context.wp(4).clamp(16, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminFormCardHeader(
            icon: Icons.badge_outlined,
            title: 'Product Identity',
            subtitle: 'Core listing information',
          ),
          const SizedBox(height: 20),
          AdminFormField(
            controller: controller.nameController,
            label: 'Product Display Name',
            labelIcon: Icons.label_outline_rounded,
            hint: 'e.g. Signature Silk Kaftan',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          AdminFormField(
            controller: controller.skuController,
            label: 'System SKU / ID',
            labelIcon: Icons.tag_rounded,
            hint: 'PRD-XXXX (leave blank to auto-generate)',
            prefixText: '#',
          ),
        ],
      ),
    );
  }

  // ── Pricing Card ────────────────────────────────────────────────────────────

  Widget _buildPricingCard(BuildContext context) {
    return AdminCard(
      padding: EdgeInsets.all(context.wp(4).clamp(16, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminFormCardHeader(
            icon: Icons.sell_outlined,
            title: 'Pricing & Classification',
            subtitle: 'Financial and catalog metadata',
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AdminFormField(
                  controller: controller.priceController,
                  label: 'Price (PKR)',
                  labelIcon: Icons.payments_outlined,
                  hint: '0.00',
                  isRequired: true,
                  prefixText: '₨',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminFormField(
                  controller: controller.categoryController,
                  label: 'Category',
                  labelIcon: Icons.category_outlined,
                  hint: 'e.g. Luxury Wear',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdminStatusDropdown(
            label: 'Approval Status',
            labelIcon: Icons.verified_outlined,
            initialStatus: controller.product?.status ?? ProductStatus.pending,
          ),
        ],
      ),
    );
  }

  // ── Description Card ────────────────────────────────────────────────────────

  Widget _buildDescriptionCard(BuildContext context) {
    return AdminCard(
      padding: EdgeInsets.all(context.wp(4).clamp(16, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminFormCardHeader(
            icon: Icons.description_outlined,
            title: 'Audit Description',
            subtitle: 'Full product details for catalog review',
          ),
          const SizedBox(height: 20),
          AdminFormField(
            controller: controller.descriptionController,
            label: 'Description',
            labelIcon: Icons.notes_rounded,
            hint:
                'Enter complete product details, materials, dimensions, care instructions...',
            maxLines: 5,
            // keyboardType & textInputAction auto-resolved to multiline by AdminFormField
          ),
        ],
      ),
    );
  }

  // ── Commit Button ───────────────────────────────────────────────────────────

  Widget _buildCommitButton() {
    return Obx(
      () => CustomButton(
        text: 'COMMIT CHANGES',
        onPressed: controller.saveProduct,
        buttonColor: AppColors.camel,
        isLoading: controller.isLoading.value,
        height: 52.0,
        width: double.infinity,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        icon: Icons.verified_user_rounded,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: Image Thumbnail widget (no GetX, pure StatelessWidget)
// ─────────────────────────────────────────────────────────────────────────────

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    super.key,
    required this.path,
    required this.isPrimary,
    required this.size,
    required this.spacing,
    required this.onRemove,
  });

  final String path;
  final bool isPrimary;
  final double size;
  final double spacing;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http');

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(right: spacing),
      decoration: BoxDecoration(
        borderRadius: .circular(12),
        border: .all(
          color: isPrimary
              ? AppColors.camel.withValues(alpha: 0.55)
              : AppColors.greyLight,
          width: isPrimary ? 2 : 1,
        ),
        image: DecorationImage(
          image: isNetwork
              ? NetworkImage(path) as ImageProvider
              : FileImage(File(path)),
          fit: .cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const .all(4),
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withValues(alpha: 0.72),
                  shape: .circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                  size: 11,
                ),
              ),
            ),
          ),
          if (isPrimary)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const .symmetric(vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: .bottomCenter,
                    end: .topCenter,
                    colors: [
                      AppColors.camel.withValues(alpha: 0.92),
                      AppColors.camel.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(11),
                  ),
                ),
                child: Text(
                  'PRIMARY',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
