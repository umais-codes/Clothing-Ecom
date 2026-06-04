import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import '../controllers/review_controller.dart';

class ReviewSubmissionSheet extends GetView<ReviewController> {
  final String orderId;
  final String productId;
  final String productName;
  final String productImageUrl;

  const ReviewSubmissionSheet({
    super.key,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.03, sw * 0.05, 0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle Indicator
            Center(
              child: Container(
                width: sw * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: sw * 0.04),

            // Sheet Title
            Text(
              "Rate Your Purchase",
              style: GoogleFonts.outfit(
                fontSize: context.sp(18),
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
            const Divider(color: AppColors.greySubtle, height: 24),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Summary Info
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            productImageUrl,
                            width: sw * 0.15,
                            height: sw * 0.15,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              width: sw * 0.15,
                              height: sw * 0.15,
                              color: AppColors.greySubtle,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: context.sp(14),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              Text(
                                "Order ID: $orderId",
                                style: GoogleFonts.outfit(
                                  fontSize: context.sp(11),
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sw * 0.06),

                    // 1. 5-Star Interactive Rating Row
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "How would you rate this item?",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: sw * 0.02),
                          Obx(() {
                            final currentRating = controller.rating.value;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starVal = index + 1.0;
                                final isSelected = starVal <= currentRating;
                                return IconButton(
                                  iconSize: sw * 0.1,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.01,
                                  ),
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    isSelected
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: isSelected
                                        ? AppColors.camel
                                        : AppColors.greyLight,
                                  ),
                                  onPressed: () =>
                                      controller.setRating(starVal),
                                );
                              }),
                            );
                          }),
                          SizedBox(height: sw * 0.01),
                          Obx(
                            () => Text(
                              controller.ratingLabel,
                              style: GoogleFonts.outfit(
                                fontSize: context.sp(12),
                                color: controller.rating.value > 0
                                    ? AppColors.camel
                                    : AppColors.grey,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // 2. Fit Assessment Slider
                    Text(
                      "Fit Assessment",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    SizedBox(height: sw * 0.02),
                    Obx(() {
                      return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.camel,
                          inactiveTrackColor: AppColors.greySubtle,
                          thumbColor: AppColors.camel,
                          overlayColor: AppColors.camel.withValues(alpha: 0.12),
                          valueIndicatorColor: AppColors.camel,
                          valueIndicatorTextStyle: GoogleFonts.outfit(
                            color: AppColors.white,
                          ),
                          tickMarkShape: const RoundSliderTickMarkShape(
                            tickMarkRadius: 4,
                          ),
                          activeTickMarkColor: AppColors.camel,
                          inactiveTickMarkColor: AppColors.greyLight,
                        ),
                        child: Slider(
                          value: controller.fitRating.value,
                          min: 0.0,
                          max: 2.0,
                          divisions: 2,
                          label: controller.fitDescription,
                          onChanged: (v) => controller.setFitRating(v),
                        ),
                      );
                    }),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Runs Small",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(10),
                              color: AppColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "True to Size",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(10),
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Runs Large",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(10),
                              color: AppColors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sw * 0.06),

                    // 3. Review Feedback Text (using global CustomTextField)
                    CustomTextField(
                      controller: controller.reviewTextController,
                      label: "Share your feedback",
                      hinttext: "Write your honest review here (optional)...",
                      maxLines: 4,
                      fillColor: AppColors.offWhite,
                      borderRadius: sw * 0.03,
                    ),
                    SizedBox(height: sw * 0.04),

                    // 4. Social Proof Photo Uploader
                    Text(
                      "Add Photos for Social Proof",
                      style: GoogleFonts.outfit(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    SizedBox(height: sw * 0.02),
                    SizedBox(
                      height: sw * 0.2,
                      child: Obx(() {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.reviewImages.length + 1,
                          itemBuilder: (context, idx) {
                            if (idx == 0) {
                              // Camera upload trigger button
                              return InkWell(
                                onTap: () => _showImageSourceSelector(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: sw * 0.2,
                                  margin: EdgeInsets.only(right: sw * 0.02),
                                  decoration: BoxDecoration(
                                    color: AppColors.offWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.greyLight,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.camel,
                                    size: sw * 0.07,
                                  ),
                                ),
                              );
                            }

                            final img = controller.reviewImages[idx - 1];
                            return Stack(
                              children: [
                                Container(
                                  width: sw * 0.2,
                                  margin: EdgeInsets.only(right: sw * 0.02),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.greySubtle,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(img.path),
                                      width: sw * 0.2,
                                      height: sw * 0.2,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: InkWell(
                                    onTap: () =>
                                        controller.removeImage(idx - 1),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }),
                    ),
                    SizedBox(height: sw * 0.06),
                  ],
                ),
              ),
            ),

            // Submit Button Row
            Padding(
              padding: EdgeInsets.only(bottom: sw * 0.04),
              child: Obx(() {
                final isButtonDisabled = controller.rating.value == 0.0;
                return CustomButton(
                  text: "Submit Review",
                  width: double.infinity,
                  buttonColor: isButtonDisabled
                      ? AppColors.greyLight
                      : AppColors.camel,
                  textColor: AppColors.white,
                  isLoading: controller.isLoading.value,
                  onPressed: isButtonDisabled
                      ? null
                      : () => controller.submitReview(orderId, productId),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSelector(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Select Image Source",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.camel,
              ),
              title: Text(
                "Take Photo",
                style: GoogleFonts.outfit(color: AppColors.charcoal),
              ),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.camel,
              ),
              title: Text(
                "Choose from Gallery",
                style: GoogleFonts.outfit(color: AppColors.charcoal),
              ),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
