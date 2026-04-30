class OrderEntity {
  final String id;
  final String customerName;
  final double amount;
  final String status;
  final int itemsCount;
  final bool isUrgent;
  final String time;

  const OrderEntity({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.itemsCount,
    required this.isUrgent,
    required this.time,
  });
}
