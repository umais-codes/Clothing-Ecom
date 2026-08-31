import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_app_bar.dart';
import '../controllers/tracking_controller.dart';
import '../widgets/tracking/order_tracking_empty_state.dart';
import '../widgets/tracking/order_package_pill_bar.dart';
import '../widgets/tracking/order_status_banner.dart';
import '../widgets/tracking/order_delivery_timeline.dart';
import '../widgets/tracking/order_logistics_card.dart';
import '../widgets/tracking/order_items_card.dart';
import '../widgets/tracking/order_shipping_destination_card.dart';
import '../widgets/tracking/order_cancellation_card.dart';
import '../widgets/tracking/order_delivered_action_card.dart';
import '../widgets/tracking/order_refund_receipt_card.dart';
import '../widgets/tracking/order_picker_modal.dart';

class CustomerTrackingView extends GetView<TrackingController> {
  const CustomerTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: "ORDER TRACKING",
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.userOrders.length > 1) {
              return IconButton(
                tooltip: "Switch Order",
                icon: const Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.charcoal,
                ),
                onPressed: () => OrderPickerModal.show(context),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.camel),
            ),
          );
        }

        if (controller.hasNoOrders.value || controller.orderId.value.isEmpty) {
          return const OrderTrackingEmptyState();
        }

        final bool isCancelled =
            controller.status.value.toLowerCase() == 'cancelled';

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sw * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OrderPackagePillBar(),
                SizedBox(height: sw * 0.035),
                const OrderStatusBanner(),
                SizedBox(height: sw * 0.035),
                if (isCancelled) ...[
                  const OrderRefundReceiptCard(),
                  SizedBox(height: sw * 0.035),
                ],
                if (!isCancelled) ...[
                  const OrderDeliveryTimeline(),
                  SizedBox(height: sw * 0.035),
                  const OrderLogisticsCard(),
                  SizedBox(height: sw * 0.035),
                ],
                const OrderItemsCard(),
                SizedBox(height: sw * 0.035),
                const OrderShippingDestinationCard(),
                SizedBox(height: sw * 0.035),
                const OrderCancellationCard(),
                const OrderDeliveredActionCard(),
                SizedBox(height: sw * 0.06),
              ],
            ),
          ),
        );
      }),
    );
  }
}
