import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';
import 'package:ecom_app/features/super_admin/domain/models/subscription_plan.dart';
import '../../domain/entities/order_entity.dart';

class VendorDashboardController extends GetxController {
  final RxBool isYearlyBilling = false.obs;
  final RxBool isLoading = false.obs;

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
      priceMonthly: 29,
      priceYearly: 290,
      maxProducts: 500,
      maxStaffAccounts: 5,
      enableAiSizePredictor: true,
      enableCustomStorefront: true,
    ),
    SubscriptionPlan(
      id: '3',
      name: 'Enterprise',
      priceMonthly: 99,
      priceYearly: 990,
      maxProducts: 999999, // unlimited
      maxStaffAccounts: 25,
      enableAiSizePredictor: true,
      enableB2bBulkQuoting: true,
      enableCustomStorefront: true,
    ),
  ];

  void selectNewPlan(SubscriptionPlan plan) {
    if (activePlanName.value == plan.name) {
      AppSnackbar.info(
        title: 'Subscription',
        message: 'You are already on the ${plan.name} plan.',
      );
      return;
    }

    activePlanName.value = plan.name;
    final price = isYearlyBilling.value ? plan.priceYearly : plan.priceMonthly;
    final period = isYearlyBilling.value ? 'year' : 'month';
    planFee.value = "\$$price / $period";
    maxProducts.value = plan.maxProducts;

    AppSnackbar.success(
      title: 'Plan Updated',
      message: 'Successfully subscribed to the ${plan.name} plan!',
    );

    Get.back();
  }

  final RxDouble gmv = 0.0.obs;
  final RxInt totalSales = 0.obs;
  final RxDouble conversionRate = 4.2.obs;

  // Financial Overview
  final RxDouble availableBalance = 0.0.obs;
  final RxDouble pendingPayouts = 0.0.obs;
  final RxString nextPayoutDate = "15th of month".obs;

  // Active Subscription Plan details
  final RxString activePlanName = "Pro Plan".obs;
  final RxString planFee = "\$49.99 / month".obs;
  final RxString commissionRate = "5.0% flat platform fee".obs;
  final RxInt currentProducts = 0.obs;
  final RxInt maxProducts = 500.obs;
  final RxString nextPlanBillingDate = "Auto-renew".obs;
  final RxString activePlanBillingStatus = "Active".obs;

  // Operational SLA Metrics
  final RxDouble slaFulfillmentRate = 99.1.obs;
  final RxInt pendingReturns = 0.obs;

  // Operational Tracking
  final RxList<OrderEntity> recentOrders = <OrderEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLiveVendorMetrics();
  }

  Future<void> loadLiveVendorMetrics() async {
    isLoading.value = true;
    try {
      final supabase = Get.find<SupabaseService>().client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        _resetMetrics();
        return;
      }

      // 1. Resolve vendor ID
      final profileRes = await supabase
          .from('profiles')
          .select('vendor_id')
          .eq('id', user.id)
          .maybeSingle();
      String? vendorId = profileRes?['vendor_id']?.toString();

      if (vendorId == null) {
        final vendorRes = await supabase
            .from('vendors')
            .select('id')
            .eq('owner_id', user.id)
            .maybeSingle();
        vendorId = vendorRes?['id']?.toString();
      }

      if (vendorId == null) {
        _resetMetrics();
        return;
      }

      // 2. Count products owned by this vendor
      final productsRes = await supabase
          .from('products')
          .select('id')
          .eq('vendor_id', vendorId);

      final List<String> myProductIds = (productsRes as List)
          .map((p) => p['id'].toString())
          .toList();

      currentProducts.value = myProductIds.length;

      if (myProductIds.isEmpty) {
        _resetOrderMetrics();
        return;
      }

      // 3. Query order items for this vendor
      final itemsRes = await supabase
          .from('order_items')
          .select('quantity, unit_price, order_id, orders!inner(id, status, created_at, customer_name, amount)')
          .filter('product_id', 'in', myProductIds);

      double gmvSum = 0.0;
      int salesCount = 0;
      int returnsCount = 0;
      final Map<String, OrderEntity> ordersMap = {};

      for (var item in (itemsRes as List<dynamic>)) {
        final order = item['orders'];
        if (order != null) {
          final String status =
              order['status']?.toString().toLowerCase() ?? '';
          final double qty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
          final double price =
              (item['unit_price'] as num?)?.toDouble() ?? 0.0;

          if (status != 'cancelled') {
            gmvSum += (qty * price);
            salesCount++;
          }
          if (status == 'returned') {
            returnsCount++;
          }

          final String orderId = order['id']?.toString() ?? '';
          if (orderId.isNotEmpty && !ordersMap.containsKey(orderId)) {
            final double ordAmount =
                (order['amount'] as num?)?.toDouble() ?? (qty * price);
            final String rawStatus = order['status']?.toString() ?? 'Pending';
            final String custName =
                order['customer_name']?.toString() ?? 'Valued Customer';

            ordersMap[orderId] = OrderEntity(
              id: orderId,
              customerName: custName,
              amount: ordAmount,
              status: rawStatus,
              itemsCount: (qty).toInt(),
              isUrgent: rawStatus.toLowerCase() == 'pending',
              time: 'Recent',
            );
          }
        }
      }

      gmv.value = gmvSum;
      totalSales.value = salesCount;
      availableBalance.value = gmvSum * 0.95; // after 5% platform commission
      pendingPayouts.value = gmvSum * 0.20;
      pendingReturns.value = returnsCount;

      recentOrders.assignAll(ordersMap.values.take(10).toList());
    } catch (e) {
      debugPrint('Error loading live vendor metrics: $e');
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('jwt') || errStr.contains('pgrst303') || errStr.contains('401')) {
        SupabaseService.handleSessionExpired('JWT expired in vendor dashboard');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _resetMetrics() {
    gmv.value = 0.0;
    totalSales.value = 0;
    availableBalance.value = 0.0;
    pendingPayouts.value = 0.0;
    currentProducts.value = 0;
    pendingReturns.value = 0;
    recentOrders.clear();
  }

  void _resetOrderMetrics() {
    gmv.value = 0.0;
    totalSales.value = 0;
    availableBalance.value = 0.0;
    pendingPayouts.value = 0.0;
    pendingReturns.value = 0;
    recentOrders.clear();
  }

  void refreshDashboard() {
    loadLiveVendorMetrics();
  }
}
