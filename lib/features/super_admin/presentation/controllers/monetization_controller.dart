import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/subscription_plan.dart';
import '../../domain/models/commission_rule.dart';
import '../../domain/models/vendor_billing.dart';

class MonetizationController extends GetxController {
  // === Plan Builder State ===
  final RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;
  final Rx<SubscriptionPlan?> selectedPlan = Rx<SubscriptionPlan?>(null);

  // Form Controllers
  final planNameController = TextEditingController();
  final priceMonthlyController = TextEditingController();
  final priceYearlyController = TextEditingController();
  final maxProductsController = TextEditingController();
  final maxStaffController = TextEditingController();

  final enableAiSizePredictor = false.obs;
  final enableB2bBulkQuoting = false.obs;
  final enableCustomStorefront = false.obs;

  // === Commission Rules State ===
  final globalCommission = 5.0.obs;
  final RxList<CommissionRule> commissionRules = <CommissionRule>[].obs;

  // === Vendor Billing State ===
  final RxList<VendorBilling> vendorBillings = <VendorBilling>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    plans.assignAll([
      SubscriptionPlan(
        id: '1',
        name: 'Free',
        priceMonthly: 0,
        priceYearly: 0,
        maxProducts: 50,
        maxStaffAccounts: 1,
        mrr: 0,
      ),
      SubscriptionPlan(
        id: '2',
        name: 'Pro',
        priceMonthly: 49.99,
        priceYearly: 499.99,
        maxProducts: 500,
        maxStaffAccounts: 5,
        enableAiSizePredictor: true,
        mrr: 12500,
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
        mrr: 45000,
      ),
    ]);

    commissionRules.assignAll([
      CommissionRule(
        id: '1',
        type: 'Category',
        targetName: 'Electronics',
        percentage: 7.5,
      ),
      CommissionRule(
        id: '2',
        type: 'Vendor',
        targetName: 'Luxury Bags Co.',
        percentage: 3.0,
      ),
    ]);

    vendorBillings.assignAll([
      VendorBilling(
        vendorId: 'v1',
        vendorName: 'Apparel Hub',
        activePlanName: 'Pro',
        billingStatus: 'Active',
        nextBillingDate: DateTime.now().add(const Duration(days: 14)),
      ),
      VendorBilling(
        vendorId: 'v2',
        vendorName: 'Sneaker World',
        activePlanName: 'Enterprise',
        billingStatus: 'Past Due',
        nextBillingDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
    planNameController.text = plan.name;
    priceMonthlyController.text = plan.priceMonthly.toString();
    priceYearlyController.text = plan.priceYearly.toString();
    maxProductsController.text = plan.maxProducts.toString();
    maxStaffController.text = plan.maxStaffAccounts.toString();
    enableAiSizePredictor.value = plan.enableAiSizePredictor;
    enableB2bBulkQuoting.value = plan.enableB2bBulkQuoting;
    enableCustomStorefront.value = plan.enableCustomStorefront;
  }

  void createNewPlan() {
    selectedPlan.value = null;
    planNameController.clear();
    priceMonthlyController.clear();
    priceYearlyController.clear();
    maxProductsController.clear();
    maxStaffController.clear();
    enableAiSizePredictor.value = false;
    enableB2bBulkQuoting.value = false;
    enableCustomStorefront.value = false;
  }

  void savePlan() {
    // In a real app, send to API. Here we just update or add to local list.
    final plan = SubscriptionPlan(
      id: selectedPlan.value?.id ?? DateTime.now().toString(),
      name: planNameController.text,
      priceMonthly: double.tryParse(priceMonthlyController.text) ?? 0.0,
      priceYearly: double.tryParse(priceYearlyController.text) ?? 0.0,
      maxProducts: int.tryParse(maxProductsController.text) ?? 0,
      maxStaffAccounts: int.tryParse(maxStaffController.text) ?? 0,
      enableAiSizePredictor: enableAiSizePredictor.value,
      enableB2bBulkQuoting: enableB2bBulkQuoting.value,
      enableCustomStorefront: enableCustomStorefront.value,
      mrr: selectedPlan.value?.mrr ?? 0.0,
    );

    if (selectedPlan.value != null) {
      final index = plans.indexWhere((p) => p.id == plan.id);
      if (index != -1) plans[index] = plan;
    } else {
      plans.add(plan);
    }
    
    Get.snackbar('Success', 'Plan saved successfully',
      snackPosition: SnackPosition.BOTTOM);
  }

  void updateGlobalCommission(double value) {
    globalCommission.value = value;
  }

  void changeVendorBillingAction(String vendorId, String action) {
    // Handle action: Upgrade, Downgrade, Extend
    Get.snackbar('Action', '\$action applied to Vendor \$vendorId',
      snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    planNameController.dispose();
    priceMonthlyController.dispose();
    priceYearlyController.dispose();
    maxProductsController.dispose();
    maxStaffController.dispose();
    super.onClose();
  }
}
