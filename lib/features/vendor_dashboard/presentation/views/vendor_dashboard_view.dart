import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/vendor_dashboard_controller.dart';
import '../widgets/metric_card.dart';
import '../widgets/subscription_plan_details_card.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class VendorDashboardView extends GetView<VendorDashboardController> {
  const VendorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;
    final double sh = context.screenHeight;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: .symmetric(horizontal: sw * 0.045, vertical: sw * 0.015),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              _buildHeader(context, sw),
              SizedBox(height: sh * 0.015),
              _buildBentoGrid(context, sw),
              SizedBox(height: sh * 0.02),
              _buildInventoryAction(context, sw),
              SizedBox(height: sh * 0.02),
              _buildFinancialOverview(context, sw),
              SizedBox(height: sh * 0.02),
              _buildSubscriptionPlanDetails(context, sw),
              SizedBox(height: sh * 0.02),
              _buildOperationalHealth(context, sw),
              SizedBox(height: sh * 0.02),
              _buildOperationalTracking(context, sw),
              SizedBox(height: sh * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double sw) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              "VENDOR PORTAL",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.camel,
                letterSpacing: 2.0,
                fontSize: sw * 0.025,
              ),
            ),
            Text(
              "Performance Hub",
              style: GoogleFonts.outfit(
                fontSize: sw * 0.05,
                height: 1.0,
                fontWeight: .w600,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
        Container(
          padding: .symmetric(horizontal: sw * 0.03, vertical: sw * 0.01),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: .circle,
            border: .all(
              color: AppColors.greyLight.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.notifications_none_sharp,
            size: sw * 0.06,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context, double sw) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Obx(
                () => MetricCard(
                  title: "TOTAL GMV",
                  value: "\$${controller.gmv.value.toStringAsFixed(2)}",
                  trend: "+12.5%",
                  icon: Icons.trending_up_rounded,
                  isLarge: true,
                ),
              ),
            ),
            SizedBox(width: sw * 0.02),
            Expanded(
              flex: 1,
              child: Obx(
                () => MetricCard(
                  title: "SALES",
                  value: controller.totalSales.value.toString(),
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sw * 0.02),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => MetricCard(
                  title: "CONVERSION",
                  value: "${controller.conversionRate.value}%",
                  icon: Icons.bar_chart_rounded,
                ),
              ),
            ),
            SizedBox(width: sw * 0.02),
            Expanded(
              child: const MetricCard(
                title: "AVG. ORDER",
                value: "\$101.20",
                icon: Icons.attach_money_rounded,
                accentColor: AppColors.sage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryAction(BuildContext context, double sw) {
    return GestureDetector(
      onTap: () => Get.toNamed('/vendor-inventory'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: AppColors.camelLight,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(color: AppColors.camel.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.camel.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: AppColors.camel, size: sw * 0.06),
                ),
                SizedBox(width: sw * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Inventory',
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'Add, edit, and track your products',
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.03,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.camel, size: sw * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context, double sw) {
    return Container(
      width: .infinity,
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: .circular(sw * 0.06),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                "Overview",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  letterSpacing: 0.5,
                  fontWeight: .w700,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.camel,
                size: sw * 0.05,
              ),
            ],
          ),
          SizedBox(height: sw * 0.03),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      "Available Balance",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                        fontSize: sw * 0.025,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "\$${controller.availableBalance.value.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AppColors.white,
                              fontWeight: .w800,
                              fontSize: sw * 0.05,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: sw * 0.08,
                width: 1,
                color: AppColors.grey.withValues(alpha: 0.2),
              ),
              SizedBox(width: sw * 0.06),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pending Payouts",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                        fontSize: sw * 0.025,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "\$${controller.pendingPayouts.value.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontSize: sw * 0.04,
                          fontWeight: .w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.04),
          Container(
            padding: EdgeInsets.all(sw * 0.03),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(sw * 0.04),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.camel,
                  size: sw * 0.035,
                ),
                SizedBox(width: sw * 0.02),
                Obx(
                  () => Text(
                    "Next payout scheduled for ${controller.nextPayoutDate.value}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: sw * 0.025,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalHealth(BuildContext context, double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          color: AppColors.greyLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.success,
                      size: sw * 0.035,
                    ),
                    SizedBox(width: sw * 0.01),
                    Text(
                      "SLA HEALTH",
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: sw * 0.022,
                        fontWeight: .w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.005),
                Obx(
                  () => Text(
                    "${controller.slaFulfillmentRate.value}%",
                    style: TextStyle(
                      color: AppColors.charcoal,
                      fontSize: sw * 0.04,
                      fontWeight: .w800,
                    ),
                  ),
                ),
                Text(
                  "On-time fulfillment",
                  style: TextStyle(color: AppColors.grey, fontSize: sw * 0.022),
                ),
              ],
            ),
          ),
          Container(height: sw * 0.08, width: 1, color: AppColors.greyLight),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: sw * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_return_outlined,
                        color: AppColors.error,
                        size: sw * 0.035,
                      ),
                      SizedBox(width: sw * 0.01),
                      Text(
                        "RETURNS",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: sw * 0.022,
                          fontWeight: .w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.005),
                  Obx(
                    () => Text(
                      "${controller.pendingReturns.value}",
                      style: TextStyle(
                        color: AppColors.charcoal,
                        fontSize: sw * 0.04,
                        fontWeight: .w800,
                      ),
                    ),
                  ),
                  Text(
                    "Awaiting processing",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: sw * 0.022,
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

  Widget _buildOperationalTracking(BuildContext context, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Orders",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            CustomButton(
              text: "See All",
              onPressed: () => Get.toNamed('/vendor-orders'),
              variant: ButtonVariant.ghost,
              textColor: AppColors.camel,
              height: 30,
              fontSize: sw * 0.035,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        SizedBox(height: sw * 0.02),
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentOrders.length,
            itemBuilder: (context, index) {
              final order = controller.recentOrders[index];
              return Container(
                margin: EdgeInsets.only(bottom: sw * 0.02),
                padding: EdgeInsets.all(sw * 0.03),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(sw * 0.04),
                  border: Border.all(
                    color: AppColors.greyLight.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: sw * 0.1,
                      height: sw * 0.1,
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: order.isUrgent
                              ? AppColors.error
                              : AppColors.camel,
                          size: sw * 0.05,
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            order.customerName,
                            style: TextStyle(
                              fontWeight: .w700,
                              color: AppColors.charcoal,
                              fontSize: sw * 0.034,
                            ),
                          ),
                          Text(
                            "${order.id} • ${order.time}",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: sw * 0.028,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: .end,
                      children: [
                        Text(
                          "\$${order.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: .w800,
                            color: AppColors.charcoal,
                            fontSize: sw * 0.035,
                          ),
                        ),
                        SizedBox(height: sw * 0.005),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.015,
                            vertical: sw * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              order.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(sw * 0.01),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontSize: sw * 0.02,
                              fontWeight: .w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return AppColors.camel;
      case 'Pending':
        return AppColors.warning;
      case 'Shipped':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  Widget _buildSubscriptionPlanDetails(BuildContext context, double sw) {
    return Obx(() => SubscriptionPlanDetailsCard(
          planName: controller.activePlanName.value,
          planFee: controller.planFee.value,
          commissionRate: controller.commissionRate.value,
          currentProducts: controller.currentProducts.value,
          maxProducts: controller.maxProducts.value,
          nextBillingDate: controller.nextPlanBillingDate.value,
          billingStatus: controller.activePlanBillingStatus.value,
          onUpgradePressed: () => Get.toNamed('/vendor-plans'),
        ));
  }
}
