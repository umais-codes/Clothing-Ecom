import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import 'package:ecom_app/app/widgets/custom_dropdown_field.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import '../controllers/rma_controller.dart';

class RmaRequestView extends GetView<RmaController> {
  const RmaRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: CustomAppBar(
        title: "Request Return",
        onBackPressed: () => _handleBackPress(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Stepper Progress Indicator
            _buildStepper(context, sw),

            // Step Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sw * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item summary card always visible at the top of forms
                    _buildItemSummaryCard(context, sw),
                    SizedBox(height: sw * 0.06),

                    // Multi-step content switcher
                    Obx(() {
                      switch (controller.currentStep.value) {
                        case 1:
                          return _buildStepReason(context, sw);
                        case 2:
                          return _buildStepEvidence(context, sw);
                        case 3:
                          return _buildStepReview(context, sw);
                        default:
                          return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ),

            // Persistent Action Buttons at the Bottom
            _buildBottomActionBar(context, sw),
          ],
        ),
      ),
    );
  }

  void _handleBackPress() {
    if (controller.currentStep.value > 1) {
      controller.prevStep();
    } else {
      Get.back();
    }
  }

  Widget _buildStepper(BuildContext context, double sw) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: sw * 0.04, horizontal: sw * 0.1),
      child: Obx(() {
        final step = controller.currentStep.value;
        return Row(
          children: [
            _buildStepNode(1, "Reason", step >= 1, step > 1, sw, context),
            _buildStepConnector(step > 1, sw),
            _buildStepNode(2, "Photos", step >= 2, step > 2, sw, context),
            _buildStepConnector(step > 2, sw),
            _buildStepNode(3, "Submit", step >= 3, false, sw, context),
          ],
        );
      }),
    );
  }

  Widget _buildStepNode(
    int index,
    String label,
    bool isReached,
    bool isCompleted,
    double sw,
    BuildContext context,
  ) {
    Color bg = AppColors.greySubtle;
    Color border = AppColors.greyLight;
    Color labelColor = AppColors.grey;
    Widget child = Text(
      index.toString(),
      style: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        fontSize: context.sp(11),
        color: AppColors.grey,
      ),
    );

    if (isCompleted) {
      bg = AppColors.success;
      border = AppColors.success;
      labelColor = AppColors.charcoal;
      child = const Icon(Icons.check_rounded, color: AppColors.white, size: 14);
    } else if (isReached) {
      bg = AppColors.camelLight;
      border = AppColors.camel;
      labelColor = AppColors.camel;
      child = Text(
        index.toString(),
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: context.sp(11),
          color: AppColors.camel,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: sw * 0.075,
          height: sw * 0.075,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.5),
          ),
          child: Center(child: child),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: context.sp(9),
            fontWeight: isReached ? FontWeight.w700 : FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isDone, double sw) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: sw * 0.035),
        color: isDone ? AppColors.success : AppColors.greyLight,
      ),
    );
  }

  Widget _buildItemSummaryCard(BuildContext context, double sw) {
    final item = controller.order.items.first;
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.imageUrl,
              width: sw * 0.16,
              height: sw * 0.16,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                width: sw * 0.16,
                height: sw * 0.16,
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
                  item.name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: context.sp(13),
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  "Size: ${item.size ?? 'Standard'} | Color: ${item.color ?? 'Neutral'}",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(11),
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  "\$${item.unitPrice.toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: context.sp(12),
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 1: Reason Select ---
  Widget _buildStepReason(BuildContext context, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Why are you returning this?",
          style: GoogleFonts.outfit(
            fontSize: context.sp(14),
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        SizedBox(height: sw * 0.03),

        // Custom Dropdown Field global widget
        Obx(() {
          return CustomDropdownField(
            label: "Reason for Return",
            value: controller.selectedReason.value.isEmpty
                ? null
                : controller.selectedReason.value,
            items: controller.returnReasons,
            hinttext: "Select return reason",
            isRequired: true,
            onChanged: (v) {
              if (v != null) controller.selectedReason.value = v;
            },
          );
        }),
        SizedBox(height: sw * 0.04),

        // Custom Text Field global widget
        CustomTextField(
          controller: controller.commentsController,
          label: "Comments & Explanation (Optional)",
          hinttext: "Describe the issue or fitting problems in details...",
          maxLines: 4,
          fillColor: AppColors.white,
          borderRadius: sw * 0.03,
        ),
      ],
    );
  }

  // --- Step 2: Attach Evidence ---
  Widget _buildStepEvidence(BuildContext context, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attach Photo Evidence",
          style: GoogleFonts.outfit(
            fontSize: context.sp(14),
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        SizedBox(height: sw * 0.01),
        Text(
          "Please upload clear photos of tags, fit, or any damages to fast-track approval.",
          style: GoogleFonts.outfit(
            fontSize: context.sp(11),
            color: AppColors.grey,
            height: 1.3,
          ),
        ),
        SizedBox(height: sw * 0.06),

        // Dash-bordered secure uploader block
        InkWell(
          onTap: () => _showImageSourceSelector(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: sw * 0.08),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.camel.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.camera_enhance_outlined,
                  color: AppColors.camel,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  "Upload Evidence Photo",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.camel,
                  ),
                ),
                Text(
                  "Supports JPEG, PNG up to 10MB",
                  style: GoogleFonts.outfit(
                    fontSize: context.sp(10),
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: sw * 0.06),

        // Selected files list
        Obx(() {
          if (controller.evidenceImages.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Uploaded Evidence (${controller.evidenceImages.length})",
                style: GoogleFonts.outfit(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: sw * 0.02),
              SizedBox(
                height: sw * 0.22,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.evidenceImages.length,
                  itemBuilder: (context, idx) {
                    final img = controller.evidenceImages[idx];
                    return Stack(
                      children: [
                        Container(
                          width: sw * 0.22,
                          margin: EdgeInsets.only(right: sw * 0.03),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.greyLight),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(img.path),
                              width: sw * 0.22,
                              height: sw * 0.22,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: InkWell(
                            onTap: () => controller.removeImage(idx),
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
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // --- Step 3: Review details ---
  Widget _buildStepReview(BuildContext context, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Review Return Request",
          style: GoogleFonts.outfit(
            fontSize: context.sp(14),
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
          ),
        ),
        SizedBox(height: sw * 0.04),

        // Summary details card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(sw * 0.045),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow("Order Number", controller.order.id, context),
              const Divider(color: AppColors.greySubtle, height: 20),
              _buildReviewRow(
                "Reason for Return",
                controller.selectedReason.value,
                context,
              ),
              const Divider(color: AppColors.greySubtle, height: 20),
              _buildReviewRow(
                "Comments",
                controller.commentsController.text.trim().isNotEmpty
                    ? controller.commentsController.text.trim()
                    : "No comments provided",
                context,
              ),
              const Divider(color: AppColors.greySubtle, height: 20),
              _buildReviewRow(
                "Evidence Attached",
                "${controller.evidenceImages.length} photo(s)",
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String title, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: context.sp(10),
            color: AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: context.sp(13),
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // --- Bottom Action Navigation Bar ---
  Widget _buildBottomActionBar(BuildContext context, double sw) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.all(sw * 0.04),
      child: Obx(() {
        final step = controller.currentStep.value;
        final isLastStep = step == 3;

        return Row(
          children: [
            if (step > 1) ...[
              Expanded(
                child: CustomButton(
                  text: "Back",
                  variant: ButtonVariant.outlined,
                  textColor: AppColors.charcoal,
                  onPressed: () => controller.prevStep(),
                ),
              ),
              SizedBox(width: sw * 0.04),
            ],
            Expanded(
              flex: 2,
              child: CustomButton(
                text: isLastStep ? "Submit Return Request" : "Continue",
                buttonColor: AppColors.camel,
                textColor: AppColors.white,
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (isLastStep) {
                    controller.submitReturnRequest();
                  } else {
                    controller.nextStep();
                  }
                },
              ),
            ),
          ],
        );
      }),
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
