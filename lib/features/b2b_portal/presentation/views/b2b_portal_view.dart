import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_text_field.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../controllers/b2b_portal_controller.dart';
import '../widgets/line_sheet_card.dart';
import '../widgets/matrix_order_widget.dart';

class B2BPortalView extends GetView<B2BPortalController> {
  const B2BPortalView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: CustomAppBar(
          title: "CORPORATE HUB",
          showBackButton: false,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.camel,
            indicatorWeight: 3,
            labelColor: AppColors.charcoal,
            unselectedLabelColor: AppColors.grey,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: sw * 0.028,
              letterSpacing: 1.0,
            ),
            tabs: const [
              Tab(text: "LINE SHEETS"),
              Tab(text: "MATRIX"),
              Tab(text: "RFQ"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLineSheets(context, sw),
            _buildMatrixOrder(context, sw),
            _buildRFQForm(context, sw),
          ],
        ),
      ),
    );
  }

  Widget _buildLineSheets(BuildContext context, double sw) {
    return Obx(
      () => GridView.builder(
        padding: .only(
          left: sw * 0.05,
          right: sw * 0.05,
          top: sw * 0.05,
          bottom: sw * 0.12,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: sw * 0.04,
          mainAxisSpacing: sw * 0.04,
        ),
        itemCount: controller.lineSheets.length,
        itemBuilder: (context, index) {
          return LineSheetCard(
            item: controller.lineSheets[index],
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildMatrixOrder(BuildContext context, double sw) {
    return SingleChildScrollView(
      padding: .only(
        left: sw * 0.05,
        right: sw * 0.05,
        top: sw * 0.06,
        bottom: sw * 0.12,
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            "Matrix Ordering",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: sw * 0.08,
              height: 1.0,
            ),
          ),
          SizedBox(height: sw * 0.015),
          Text(
            "Input quantities across size & color for bulk procurement.",
            style: TextStyle(
              color: AppColors.grey,
              fontSize: sw * 0.032,
              height: 1.4,
            ),
          ),
          SizedBox(height: sw * 0.06),
          const MatrixOrderWidget(),
          SizedBox(height: sw * 0.08),
          CustomButton(text: "ADD TO BULK CART", onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildRFQForm(BuildContext context, double sw) {
    return SingleChildScrollView(
      padding: .only(
        left: sw * 0.04,
        right: sw * 0.04,
        top: sw * 0.02,
        bottom: sw * 0.06,
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            "Request for Quote",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: sw * 0.08,
              height: 1.0,
            ),
          ),
          SizedBox(height: sw * 0.015),
          Text(
            "Fill details for private label or customized corporate uniform orders.",
            style: TextStyle(
              color: AppColors.grey,
              fontSize: sw * 0.032,
              height: 1.4,
            ),
          ),
          SizedBox(height: sw * 0.04),
          CustomTextField(
            label: "Company Name",
            hinttext: "e.g. Acme Corp Int.",
            controller: controller.companyNameController,
            icon: Icons.business_rounded,
          ),
          SizedBox(height: sw * 0.02),
          CustomTextField(
            label: "Expected Total Volume",
            hinttext: "e.g. 5000",
            keyboardType: .number,
            controller: controller.rfqQuantityController,
            icon: Icons.production_quantity_limits_rounded,
          ),
          SizedBox(height: sw * 0.02),
          CustomTextField(
            label: "Customization Requirements",
            hinttext: "Specify branding, logo placement, fabric preferences...",
            maxLines: 4,
            controller: controller.rfqNotesController,
            icon: Icons.edit_note_rounded,
          ),
          SizedBox(height: sw * 0.06),
          CustomButton(text: "SUBMIT RFQ", onPressed: controller.submitRFQ),
          SizedBox(height: sw * 0.02),
          Center(
            child: Text(
              "Our B2B team typically responds within 24 hours.",
              style: TextStyle(color: AppColors.grey, fontSize: sw * 0.025),
            ),
          ),
        ],
      ),
    );
  }
}
