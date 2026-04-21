import 'package:get/get.dart';

class DashboardController extends GetxController {
  final stats = [
    {'title': 'Total Sales', 'value': '\$42,850.00', 'color': 'charcoal'},
    {'title': 'Pending Orders', 'value': '18', 'color': 'camel'},
    {'title': 'Available Payouts', 'value': '\$12,400.00', 'color': 'charcoal'},
  ].obs;

  final recentActivity = [
    {'title': 'New Order #ORD-8821', 'time': '2 mins ago', 'amount': '+\$1,250.00'},
    {'title': 'Payout Request Processed', 'time': '1 hour ago', 'amount': '-\$4,500.00'},
    {'title': 'New Order #ORD-8820', 'time': '3 hours ago', 'amount': '+\$850.00'},
    {'title': 'Inventory Alert: Silk Abaya', 'time': '5 hours ago', 'amount': '5 left'},
  ].obs;
}
