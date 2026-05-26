import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/super_admin/domain/models/subscription_plan.dart';
import '../../domain/entities/order_entity.dart';

class VendorDashboardController extends GetxController {
  final RxBool isYearlyBilling = false.obs;

  final List<SubscriptionPlan> availablePlans = [
    SubscriptionPlan(
      id: '1',
      name: 'Free',
      priceMonthly: 0,
      priceYearly: 0,
      maxProducts: 50,
      maxStaffAccounts: 1,
    ),
    SubscriptionPlan(
      id: '2',
      name: 'Pro',
      priceMonthly: 49.99,
      priceYearly: 499.99,
      maxProducts: 500,
      maxStaffAccounts: 5,
      enableAiSizePredictor: true,
    ),
    SubscriptionPlan(
      id: '3',
      name: 'Enterprise',
      priceMonthly: 199.99,
      priceYearly: 1999.99,
      maxProducts: 999999, // unlimited
      maxStaffAccounts: 25,
      enableAiSizePredictor: true,
      enableB2bBulkQuoting: true,
      enableCustomStorefront: true,
    ),
  ];

  void selectNewPlan(SubscriptionPlan plan) {
    if (activePlanName.value == plan.name) {
      Get.snackbar(
        'Info',
        'You are already on the ${plan.name} plan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    activePlanName.value = plan.name;
    final price = isYearlyBilling.value ? plan.priceYearly : plan.priceMonthly;
    final period = isYearlyBilling.value ? 'year' : 'month';
    planFee.value = "\$$price / $period";
    maxProducts.value = plan.maxProducts;

    Get.snackbar(
      'Plan Updated',
      'Successfully subscribed to the ${plan.name} plan!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success.withValues(alpha: 0.1),
      colorText: AppColors.success,
    );

    Get.back();
  }

  final RxDouble gmv = 125430.50.obs;
  final RxInt totalSales = 1240.obs;
  final RxDouble conversionRate = 3.8.obs;

  // Financial Overview
  final RxDouble availableBalance = 12400.00.obs;
  final RxDouble pendingPayouts = 4500.00.obs;
  final RxString nextPayoutDate = "May 5, 2026".obs;

  // Active Subscription Plan details
  final RxString activePlanName = "Pro Plan".obs;
  final RxString planFee = "\$49.99 / month".obs;
  final RxString commissionRate = "5.0% flat platform fee".obs;
  final RxInt currentProducts = 142.obs;
  final RxInt maxProducts = 500.obs;
  final RxString nextPlanBillingDate = "June 9, 2026".obs;
  final RxString activePlanBillingStatus = "Active".obs;

  // Operational SLA Metrics
  final RxDouble slaFulfillmentRate = 98.2.obs;
  final RxInt pendingReturns = 5.obs;

  // Operational Tracking
  final RxList<OrderEntity> recentOrders = <OrderEntity>[
    const OrderEntity(
      id: '#ORD-9921',
      customerName: 'Sarah Al-Fayed',
      amount: 250.00,
      status: 'Processing',
      itemsCount: 3,
      isUrgent: true,
      time: '10 mins ago',
    ),
    const OrderEntity(
      id: '#ORD-9920',
      customerName: 'James Wilson',
      amount: 120.00,
      status: 'Pending',
      itemsCount: 1,
      isUrgent: false,
      time: '45 mins ago',
    ),
    const OrderEntity(
      id: '#ORD-9919',
      customerName: 'Elena Rossi',
      amount: 850.00,
      status: 'Shipped',
      itemsCount: 5,
      isUrgent: false,
      time: '2 hours ago',
    ),
    const OrderEntity(
      id: '#ORD-9918',
      customerName: 'Ahmed Khan',
      amount: 340.00,
      status: 'Processing',
      itemsCount: 2,
      isUrgent: true,
      time: '3 hours ago',
    ),
  ].obs;

  void refreshDashboard() {
    gmv.value += 150.0;
  }
}
