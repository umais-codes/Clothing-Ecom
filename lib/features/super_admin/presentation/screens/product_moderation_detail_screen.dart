import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/app_downloader.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_card.dart';
import 'package:ecom_app/features/super_admin/presentation/widgets/admin_widgets.dart';

class ProductModerationDetailScreen extends GetView<AdminController> {
  const ProductModerationDetailScreen({super.key, required this.product});

  final PendingProductEntity product;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileView;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Product Moderation',
        actions: [
          Center(child: AdminStatusBadge(status: 'pending')),
          SizedBox(width: 12),
        ],
      ),
      backgroundColor: AppColors.offWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: isMobile
                ? _MobileLayout(product: product, controller: controller)
                : _DesktopLayout(product: product, controller: controller),
          ),
          _ActionBar(product: product, controller: controller),
        ],
      ),
    );
  }
}


class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.product, required this.controller});
  final PendingProductEntity product;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProductImageGallery(product: product),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _ProductDetailsBody(product: product),
          ),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.product, required this.controller});
  final PendingProductEntity product;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _ProductImageGallery(product: product)),
        const VerticalDivider(color: AppColors.greyLight, width: 1),
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _ProductDetailsBody(product: product),
          ),
        ),
      ],
    );
  }
}

class _ProductImageGallery extends StatefulWidget {
  const _ProductImageGallery({required this.product});
  final PendingProductEntity product;

  @override
  State<_ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  late List<String> allImages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    allImages = [widget.product.imageUrl, ...widget.product.additionalImages];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobileView;
    final galleryHeight = isMobile ? context.hp(35) : double.infinity;

    return Hero(
      tag: 'product-${widget.product.id}',
      child: Stack(
        children: [
          SizedBox(
            height: galleryHeight,
            width: double.infinity,
            child: PageView.builder(
              itemCount: allImages.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: allImages[i],
                fit: .cover,
                placeholder: (_, _) => Container(color: AppColors.greySubtle),
              ),
            ),
          ),
          if (allImages.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  allImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentIndex == index ? 12 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? AppColors.charcoal
                          : AppColors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 12,
            right: 12,
            child: AppDownloader(
              url: allImages[_currentIndex],
              fileName: '${widget.product.name}_${_currentIndex + 1}',
              size: 32,
              iconSize: 18,
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.charcoal.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.product.category.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailsBody extends StatelessWidget {
  const _ProductDetailsBody({required this.product});
  final PendingProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          product.name,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: .w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PKR ${product.price.toStringAsFixed(0)}',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: .w600,
            color: AppColors.camel,
          ),
        ),
        const SizedBox(height: 12),
        const AdminSectionHeader(title: 'PRODUCT INFORMATION'),
        const SizedBox(height: 8),
        AdminCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              AdminInfoRow(
                icon: Icons.store_mall_directory_outlined,
                label: 'Vendor',
                value: product.vendorName,
              ),
              AdminInfoRow(
                icon: Icons.category_outlined,
                label: 'Category',
                value: product.category,
              ),
              AdminInfoRow(
                icon: Icons.inventory_2_outlined,
                label: 'Status',
                value: 'Pending Review',
                valueColor: AppColors.warning,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const AdminSectionHeader(title: 'DESCRIPTION'),
        const SizedBox(height: 4),
        Text(
          product.description,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppColors.ink,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        const AdminSectionHeader(title: 'SIZES'),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: product.sizes.map((size) => _SizeChip(size: size)).toList(),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.product, required this.controller});
  final PendingProductEntity product;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.greyLight, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              onPressed: () {
                controller.rejectProduct(product.id);
                Get.back();
              },
              text: 'Reject',
              variant: ButtonVariant.outlined,
              textColor: AppColors.error,
              height: 40,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              onPressed: () {
                controller.approveProduct(product.id);
                Get.back();
              },
              text: 'Approve',
              variant: ButtonVariant.primary,
              buttonColor: AppColors.success,
              height: 40,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.size});
  final String size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.greyLight, width: 1.0),
      ),
      child: Text(
        size,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
      ),
    );
  }
}
