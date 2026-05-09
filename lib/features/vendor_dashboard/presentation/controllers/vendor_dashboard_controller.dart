import 'package:get/get.dart';
import '../../domain/entities/order_entity.dart';

class VendorDashboardController extends GetxController {
  final RxDouble gmv = 125430.50.obs;
  final RxInt totalSales = 1240.obs;
  final RxDouble conversionRate = 3.8.obs;

  // Financial Overview
  final RxDouble availableBalance = 12400.00.obs;
  final RxDouble pendingPayouts = 4500.00.obs;
  final RxString nextPayoutDate = "May 5, 2026".obs;

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
