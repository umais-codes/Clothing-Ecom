import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/features/product_details/presentation/widgets/product_detail_back_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/pdp_controller.dart';
import '../widgets/pdp_carousel.dart';
import '../widgets/variant_section.dart';
import '../widgets/ai_size_predictor_card.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/features/wishlist/domain/models/product_model.dart';
import 'package:ecom_app/features/wishlist/presentation/controllers/wishlist_controller.dart';
import 'package:ecom_app/app/widgets/custom_stepper.dart';

class PdpView extends GetView<PdpController> {
  const PdpView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          _buildContent(context, sw, scrollController),
          _buildBottomBar(sw),
          const ProductDetailBackButton(),
          _buildFavoriteButton(context, sw),
        ],
      ),
    );
  }

  void _scrollToReviews(ScrollController scrollController) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildContent(
    BuildContext context,
    double sw,
    ScrollController scrollController,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PdpCarousel(sw: sw, imageUrl: controller.product['image']),
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.015, sw * 0.04, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 BRAND NAME
                Text(
                  (controller.product['vendor'] ?? 'BOUTIQUE APPAREL')
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.024,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.camel,
                  ),
                ),

                SizedBox(height: sw * 0.015),

                /// 🌟 RATING SUMMARY BADGE (CLICKABLE)
                if (controller.product['isB2B'] != true) ...[
                  Obx(() {
                    if (controller.reviews.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return InkWell(
                      onTap: () => _scrollToReviews(scrollController),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                final starVal = index + 1.0;
                                final avg = controller.averageRating;
                                return Icon(
                                  starVal <= avg
                                      ? Icons.star_rounded
                                      : (starVal - 0.5 <= avg
                                            ? Icons.star_half_rounded
                                            : Icons.star_outline_rounded),
                                  color: AppColors.camel,
                                  size: sw * 0.045,
                                );
                              }),
                            ),
                            SizedBox(width: sw * 0.015),
                            Text(
                              controller.averageRating.toStringAsFixed(1),
                              style: GoogleFonts.outfit(
                                fontSize: sw * 0.032,
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                              ),
                            ),
                            SizedBox(width: sw * 0.015),
                            Text(
                              "(${controller.reviews.length} Reviews)",
                              style: GoogleFonts.outfit(
                                fontSize: sw * 0.03,
                                color: AppColors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            SizedBox(width: sw * 0.03),
                            Container(
                              width: 1.5,
                              height: 12,
                              color: AppColors.greySubtle,
                            ),
                            SizedBox(width: sw * 0.03),
                            Text(
                              controller.fitSummary,
                              style: GoogleFonts.outfit(
                                fontSize: sw * 0.03,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: sw * 0.02),
                ],

                /// 🔹 PRODUCT NAME + PRICE/QTY
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        controller.product['name'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: sw * 0.055,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),

                    SizedBox(width: sw * 0.02),

                    /// RIGHT SIDE (PRICE + QTY)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        /// PRICE
                        Text(
                          '\$${controller.product['price'].toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.w800,
                            color: AppColors.camel,
                          ),
                        ),

                        SizedBox(height: sw * 0.015),

                        /// 🔥 QTY STEPPER (FIXED)
                        Obx(
                          () => CustomStepper(
                            value: controller.quantity.value,
                            onChanged: (newQty) =>
                                controller.updateQuantity(newQty),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: sw * 0.02),

                VariantSection(
                  title: 'Select Size',
                  items: controller.sizes,
                  selectedItem: controller.selectedSize,
                  sw: sw,
                ),

                SizedBox(height: sw * 0.05),

                VariantSection(
                  title: 'Select Color',
                  items: controller.colors,
                  selectedItem: controller.selectedColor,
                  sw: sw,
                ),

                SizedBox(height: sw * 0.06),

                Text(
                  'Description',
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.024,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppColors.grey,
                  ),
                ),

                SizedBox(height: sw * 0.02),

                Text(
                  controller.description,
                  style: GoogleFonts.outfit(
                    fontSize: sw * 0.034,
                    height: 1.7,
                    color: AppColors.charcoal.withValues(alpha: 0.85),
                  ),
                ),

                SizedBox(height: sw * 0.03),

                AISizePredictorCard(
                  sw: sw,
                  onPredict: () => controller.runAIPrediction(),
                ),

                SizedBox(height: sw * 0.01),

                /// 🌟 CUSTOMER REVIEWS SECTION
                if (controller.product['isB2B'] != true) ...[
                  _buildReviewsSection(context, sw),
                ],

                SizedBox(height: sw * 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.greySubtle, height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Customer Reviews",
              style: GoogleFonts.outfit(
                fontSize: sw * 0.024,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppColors.grey,
              ),
            ),
            Obx(
              () => Text(
                "${controller.reviews.length} Ratings",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w700,
                  color: AppColors.camel,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: sw * 0.02),

        // Rating & Fit distribution summary
        Obx(() {
          if (controller.reviews.isEmpty) return const SizedBox.shrink();

          // Fit calculation
          int trueToSize = 0;
          int runsSmall = 0;
          int runsLarge = 0;
          for (var r in controller.reviews) {
            final f = r['fit_rating'];
            if (f is num) {
              final val = f.toDouble();
              if (val < 0.5) {
                runsSmall++;
              } else if (val > 1.5) {
                runsLarge++;
              } else {
                trueToSize++;
              }
            }
          }
          final total = controller.reviews.length;
          final double ratioSmall = total > 0 ? runsSmall / total : 0.0;
          final double ratioTrue = total > 0 ? trueToSize / total : 0.0;
          final double ratioLarge = total > 0 ? runsLarge / total : 0.0;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.02,
            ),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Average Rating Big Badge
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.averageRating.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.09,
                          fontWeight: FontWeight.w900,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starVal = index + 1.0;
                          final avg = controller.averageRating;
                          return Icon(
                            starVal <= avg
                                ? Icons.star_rounded
                                : (starVal - 0.5 <= avg
                                      ? Icons.star_half_rounded
                                      : Icons.star_outline_rounded),
                            color: AppColors.camel,
                            size: sw * 0.035,
                          );
                        }),
                      ),
                      SizedBox(height: sw * 0.01),
                      Text(
                        "Out of 5 stars",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.024,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical divider
                Container(
                  width: 1,
                  height: sw * 0.18,
                  color: AppColors.greySubtle,
                  margin: EdgeInsets.symmetric(horizontal: sw * 0.03),
                ),

                // Fit Distribution Progress Bars
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fit Assessment",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.024,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: sw * 0.02),
                      _buildFitDistributionRow("Runs Small", ratioSmall, sw),
                      SizedBox(height: sw * 0.012),
                      _buildFitDistributionRow("True to Size", ratioTrue, sw),
                      SizedBox(height: sw * 0.012),
                      _buildFitDistributionRow("Runs Large", ratioLarge, sw),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        SizedBox(height: sw * 0.04),

        // Reviews List Column
        Obx(() {
          if (controller.isLoadingReviews.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.camel),
              ),
            );
          }

          if (controller.reviews.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No reviews yet. Be the first to review this product!",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.03,
                  color: AppColors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return Column(
            children: controller.reviews.map((rev) {
              return _buildReviewCard(context, rev, sw);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildFitDistributionRow(String label, double ratio, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: sw * 0.024,
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "${(ratio * 100).round()}%",
              style: GoogleFonts.outfit(
                fontSize: sw * 0.024,
                color: AppColors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: sw * 0.005),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 4,
            backgroundColor: AppColors.greySubtle,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.camel),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    Map<String, dynamic> review,
    double sw,
  ) {
    final double ratingVal = (review['rating'] as num?)?.toDouble() ?? 5.0;
    final List<dynamic> imgList = review['images'] ?? [];

    // Parse date
    String dateStr = 'Recently';
    if (review['created_at'] != null) {
      try {
        final date = DateTime.parse(review['created_at']);
        final diff = DateTime.now().difference(date);
        if (diff.inDays == 0) {
          dateStr = 'Today';
        } else if (diff.inDays == 1) {
          dateStr = 'Yesterday';
        } else if (diff.inDays < 7) {
          dateStr = '${diff.inDays} days ago';
        } else {
          dateStr = '${date.day}/${date.month}/${date.year}';
        }
      } catch (_) {}
    }

    // Determine fit text
    String fitText = 'True to Size';
    final fitRating = review['fit_rating'];
    if (fitRating is num) {
      if (fitRating.toDouble() < 0.5) {
        fitText = 'Runs Small';
      } else if (fitRating.toDouble() > 1.5) {
        fitText = 'Runs Large';
      }
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: sw * 0.02),
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greySubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Stars + Name + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (idx) {
                  return Icon(
                    idx < ratingVal.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.camel,
                    size: sw * 0.035,
                  );
                }),
              ),
              Text(
                review['customer_name'] ?? 'Verified Buyer',
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),

          SizedBox(height: sw * 0.015),

          // Variant Details + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${review['variant_info'] ?? 'Size: M | Color: Sand'} | Fit: $fitText",
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.026,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                dateStr,
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.026,
                  color: AppColors.grey.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          Divider(color: AppColors.greySubtle, height: sw * 0.03),

          // Review Content Text
          if (review['review_text'] != null &&
              review['review_text'].toString().isNotEmpty) ...[
            Text(
              review['review_text'],
              style: GoogleFonts.outfit(
                fontSize: sw * 0.03,
                height: 1.5,
                color: AppColors.charcoal.withValues(alpha: 0.85),
              ),
            ),
            SizedBox(height: sw * 0.02),
          ],

          // Photo Attachments (if any)
          if (imgList.isNotEmpty) ...[
            SizedBox(
              height: sw * 0.16,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imgList.length,
                itemBuilder: (ctx, index) {
                  final imgUrl = imgList[index].toString();
                  return InkWell(
                    onTap: () => _showImageLightbox(context, imgUrl),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: sw * 0.16,
                      margin: EdgeInsets.only(right: sw * 0.02),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.greySubtle),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: AppColors.greyLight,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.grey,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showImageLightbox(BuildContext context, String imageUrl) {
    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Black backdrop
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(color: AppColors.charcoal),
                  ),
                ),
                // Zoomable/Pannable Image
                Center(
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      // Shows a loading indicator while the image is being fetched/cached
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      ),
                      // Equivalent to your previous errorBuilder
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image,
                        color: AppColors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                // Close button top right
                Positioned(
                  top: context.paddingTop + 16,
                  right: 16,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, _, child) {
        return FadeTransition(opacity: anim, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildBottomBar(double sw) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.05)),
        ),
        child: CustomButton(
          text: 'Add to Cart',
          onPressed: () => controller.addToCart(),
          icon: Icons.shopping_cart_checkout_rounded,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, double sw) {
    final wishlistController = Get.put(WishlistController());
    final product = Product.fromMap(controller.product);

    return Positioned(
      top: context.paddingTop + sw * 0.015,
      right: sw * 0.04,
      child: Obx(
        () => Container(
          width: sw * 0.1,
          height: sw * 0.1,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(sw * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              wishlistController.isInWishlist(product.id)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: wishlistController.isInWishlist(product.id)
                  ? AppColors.camel
                  : AppColors.charcoal,
              size: sw * 0.05,
            ),
            onPressed: () => wishlistController.toggleWishlist(product),
          ),
        ),
      ),
    );
  }
}
