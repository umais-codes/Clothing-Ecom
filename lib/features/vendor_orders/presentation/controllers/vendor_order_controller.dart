import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import '../../domain/entities/vendor_order.dart';

class VendorOrderController extends GetxController {
  final RxList<VendorOrder> orders = <VendorOrder>[].obs;
  final RxString selectedTab = 'All'.obs;

  // Controllers for bottom sheet input
  final trackingController = TextEditingController();

  final List<String> tabs = [
    'All',
    'New Orders',
    'Processing',
    'Shipped',
    'Returns (RMA)',
  ];

  RealtimeChannel? _ordersSubscriptionChannel;
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

  @override
  void onInit() {
    super.onInit();
    fetchOrdersFromSupabase();
    subscribeToOrders();
  }

  Future<void> fetchOrdersFromSupabase() async {
    if (SupabaseService.supabaseUrl.contains('placeholder')) return;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        orders.clear();
        return;
      }

      // 1. Resolve vendor ID for current user
      final profileRes = await _supabase
          .from('profiles')
          .select('vendor_id')
          .eq('id', user.id)
          .maybeSingle();
      String? vendorId = profileRes?['vendor_id']?.toString();

      if (vendorId == null) {
        final vendorRes = await _supabase
            .from('vendors')
            .select('id')
            .eq('owner_id', user.id)
            .maybeSingle();
        vendorId = vendorRes?['id']?.toString();
      }

      if (vendorId == null) {
        orders.clear();
        return;
      }

      // 2. Fetch products owned by this vendor
      final productsRes = await _supabase
          .from('products')
          .select('id')
          .eq('vendor_id', vendorId);

      final List<String> myProductIds = (productsRes as List)
          .map((p) => p['id'].toString())
          .toList();

      if (myProductIds.isEmpty) {
        orders.clear();
        return;
      }

      // 3. Query order items strictly matching vendor products
      final itemsResponse = await _supabase
          .from('order_items')
          .select('*, orders(*)')
          .filter('product_id', 'in', myProductIds)
          .order('created_at', ascending: false);

      if (itemsResponse.isEmpty) {
        orders.clear();
        return;
      }

      // 4. Group items by parent order ID
      final Map<String, List<dynamic>> groupedItems = {};
      final Map<String, dynamic> ordersMap = {};

      for (var item in (itemsResponse as List<dynamic>)) {
        final orderData = item['orders'];
        if (orderData != null) {
          final String orderId = orderData['id']?.toString() ?? '';
          if (orderId.isNotEmpty) {
            ordersMap[orderId] = orderData;
            groupedItems.putIfAbsent(orderId, () => []).add(item);
          }
        }
      }

      final List<VendorOrder> scopedOrders = [];

      for (var entry in ordersMap.entries) {
        final row = entry.value;
        final orderItemsRaw = groupedItems[entry.key] ?? [];

        final itemsList = orderItemsRaw.map((item) {
          return VendorOrderItem(
            id: item['id']?.toString() ?? '',
            name: item['product_name']?.toString() ?? 'Product',
            quantity: (item['quantity'] as num?)?.toInt() ?? 1,
            unitPrice: (item['unit_price'] as num?)?.toDouble() ?? 0.0,
            size: item['size']?.toString(),
            color: item['color']?.toString(),
            imageUrl: item['image_url']?.toString() ??
                'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=300&auto=format&fit=crop',
          );
        }).toList();

        final timelineList = (row['timeline'] as List<dynamic>? ?? []).map((t) {
          return OrderTimelineStep(
            title: t['title']?.toString() ?? 'Update',
            description: t['description']?.toString() ?? '',
            timestamp: t['timestamp'] != null
                ? DateTime.tryParse(t['timestamp'])
                : null,
            isCompleted: t['isCompleted'] == true,
          );
        }).toList();

        scopedOrders.add(
          VendorOrder(
            id: row['id']?.toString() ?? '',
            customerName:
                row['customer_name']?.toString() ?? 'Valued Customer',
            amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
            status: row['status']?.toString() ?? 'Pending',
            orderDate: row['created_at'] != null
                ? (DateTime.tryParse(row['created_at']) ?? DateTime.now())
                : DateTime.now(),
            isB2B: row['is_b2b'] == true,
            shippingAddress: row['shipping_address']?.toString(),
            customerPhone: row['customer_phone']?.toString(),
            trackingNumber: row['tracking_number']?.toString(),
            courierPartner: row['courier_partner']?.toString(),
            packageWeight: (row['package_weight'] as num?)?.toDouble(),
            items: itemsList,
            timeline: timelineList.isNotEmpty
                ? timelineList
                : [
                    OrderTimelineStep(
                      title: 'Order Placed',
                      description:
                          'Order placed via ${row['payment_method'] ?? 'Checkout'}.',
                      timestamp: row['created_at'] != null
                          ? DateTime.tryParse(row['created_at'])
                          : DateTime.now(),
                      isCompleted: true,
                    ),
                  ],
          ),
        );
      }

      orders.assignAll(scopedOrders);
    } catch (e) {
      debugPrint('Error fetching vendor scoped orders from Supabase: $e');
    }
  }

  @override
  void onClose() {
    _ordersSubscriptionChannel?.unsubscribe();
    trackingController.dispose();
    super.onClose();
  }

  List<VendorOrder> get filteredOrders {
    final filter = selectedTab.value;
    if (filter == 'All') {
      return orders;
    } else if (filter == 'New Orders') {
      return orders.where((o) => o.status == 'Pending').toList();
    } else if (filter == 'Processing') {
      return orders.where((o) => o.status == 'Processing').toList();
    } else if (filter == 'Shipped') {
      return orders.where((o) => o.status == 'Shipped').toList();
    } else if (filter == 'Returns (RMA)') {
      return orders.where((o) => o.status == 'Returned').toList();
    }
    return [];
  }

  void acceptOrder(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      final updatedTimeline = List<OrderTimelineStep>.from(oldOrder.timeline)
        ..add(OrderTimelineStep(
          title: 'Order Accepted',
          description: 'Confirmed by vendor. Moving to fulfillment.',
          timestamp: DateTime.now(),
          isCompleted: true,
        ));
      
      final updatedOrder = oldOrder.copyWith(
        status: 'Processing',
        timeline: updatedTimeline,
      );
      orders[index] = updatedOrder;
      
      if (!SupabaseService.supabaseUrl.contains('placeholder')) {
        _supabase.from('orders').update({
          'status': 'Processing',
          'timeline': updatedTimeline.map((t) => {
            'title': t.title,
            'description': t.description,
            'timestamp': t.timestamp?.toIso8601String(),
            'isCompleted': t.isCompleted,
          }).toList(),
        }).eq('id', orderId).catchError((e) {
          debugPrint('Error updating order in Supabase: $e');
        });
      }
      
      Get.snackbar(
        'Order Accepted',
        'Order $orderId has been moved to Processing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.camelLight,
        colorText: AppColors.charcoal,
      );

      // Close the bottom sheet modal if it is currently open
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // Automatically navigate to the packing checklist workspace
      Get.toNamed('/fulfillment-checklist', arguments: updatedOrder);
    }
  }

  void markAsShipped(String orderId, String trackingNumber) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      final updatedTimeline = List<OrderTimelineStep>.from(oldOrder.timeline)
        ..add(OrderTimelineStep(
          title: 'Shipped',
          description: 'Dispatched via carrier. Tracking: $trackingNumber',
          timestamp: DateTime.now(),
          isCompleted: true,
        ));

      orders[index] = oldOrder.copyWith(
        status: 'Shipped',
        trackingNumber: trackingNumber,
        timeline: updatedTimeline,
      );

      if (!SupabaseService.supabaseUrl.contains('placeholder')) {
        _supabase.from('orders').update({
          'status': 'Shipped',
          'tracking_number': trackingNumber,
          'timeline': updatedTimeline.map((t) => {
            'title': t.title,
            'description': t.description,
            'timestamp': t.timestamp?.toIso8601String(),
            'isCompleted': t.isCompleted,
          }).toList(),
        }).eq('id', orderId).catchError((e) {
          debugPrint('Error marking order as shipped in Supabase: $e');
        });
      }

      Get.snackbar(
        'Order Shipped',
        'Order $orderId marked as Shipped. Tracking ID added.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
    }
  }

  void processReturn(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      // Simulate completing the refund
      orders.removeAt(index);

      if (!SupabaseService.supabaseUrl.contains('placeholder')) {
        _supabase.from('orders').update({
          'status': 'Returned',
        }).eq('id', orderId).catchError((e) {
          debugPrint('Error updating return status in Supabase: $e');
        });
      }
      
      Get.snackbar(
        'Refund Completed',
        'RMA for order $orderId completed successfully. Refund initiated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    }
  }

  void subscribeToOrders() {
    if (SupabaseService.supabaseUrl.contains('placeholder')) {
      debugPrint('Supabase placeholder URL detected; skipping realtime orders subscription.');
      return;
    }
    _ordersSubscriptionChannel = _supabase
        .channel('public:orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            _handleRealtimeOrderChange(payload);
          },
        );
    _ordersSubscriptionChannel?.subscribe();
  }

  void _handleRealtimeOrderChange(dynamic payload) {
    final record = payload.newRecord;
    if (record == null || record.isEmpty) return;

    final orderId = record['id']?.toString() ?? '';
    final status = record['status']?.toString() ?? 'Pending';
    final trackingNum = record['tracking_number']?.toString();
    final courier = record['courier_partner']?.toString();

    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      orders[index] = oldOrder.copyWith(
        status: status,
        trackingNumber: trackingNum,
        courierPartner: courier,
      );

      Get.snackbar(
        'Database Sync (Real-time)',
        'Order $orderId status updated to: $status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
      );
    }
  }
}
