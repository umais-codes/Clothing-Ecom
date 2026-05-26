class VendorBilling {
  String vendorId;
  String vendorName;
  String activePlanName;
  String billingStatus;
  DateTime nextBillingDate;

  VendorBilling({
    required this.vendorId,
    required this.vendorName,
    required this.activePlanName,
    required this.billingStatus,
    required this.nextBillingDate,
  });
}
