class SubscriptionPlan {
  String id;
  String name;
  double priceMonthly;
  double priceYearly;
  int maxProducts;
  int maxStaffAccounts;
  bool enableAiSizePredictor;
  bool enableB2bBulkQuoting;
  bool enableCustomStorefront;
  double mrr;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    required this.maxProducts,
    required this.maxStaffAccounts,
    this.enableAiSizePredictor = false,
    this.enableB2bBulkQuoting = false,
    this.enableCustomStorefront = false,
    this.mrr = 0.0,
  });

  factory SubscriptionPlan.empty() {
    return SubscriptionPlan(
      id: '',
      name: '',
      priceMonthly: 0.0,
      priceYearly: 0.0,
      maxProducts: 0,
      maxStaffAccounts: 0,
    );
  }
}
