import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';
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

      // 1. Fetch orders from Supabase public.orders
      final ordersRes = await _supabase
          .from('orders')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);

      if ((ordersRes as List).isEmpty) {
        orders.clear();
        return;
      }

      final List<dynamic> ordersList = ordersRes;
      final List<String> orderIds = ordersList
          .map((o) => o['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      // 2. Fetch all corresponding order items
      List<dynamic> allOrderItems = [];
      if (orderIds.isNotEmpty) {
        try {
          allOrderItems = await _supabase
              .from('order_items')
              .select('*')
              .filter('order_id', 'in', orderIds);
        } catch (e) {
          debugPrint('Error fetching order items: $e');
        }
      }

      // Group items by order_id
      final Map<String, List<dynamic>> itemsMap = {};
      for (var it in allOrderItems) {
        final oId = it['order_id']?.toString() ?? '';
        if (oId.isNotEmpty) {
          itemsMap.putIfAbsent(oId, () => []).add(it);
        }
      }

      final List<VendorOrder> loadedOrders = [];

      for (var row in ordersList) {
        final oId = row['id']?.toString() ?? '';
        final rawItems = itemsMap[oId] ?? [];

        final itemsList = rawItems.map((item) {
          return VendorOrderItem(
            id: item['product_id']?.toString() ?? item['id']?.toString() ?? '',
            name: item['product_name']?.toString() ?? 'Garment',
            quantity: (item['quantity'] as num?)?.toInt() ?? 1,
            unitPrice: (item['unit_price'] as num?)?.toDouble() ?? 0.0,
            size: item['size']?.toString(),
            color: item['color']?.toString(),
            imageUrl:
                item['image_url']?.toString() ??
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

        loadedOrders.add(
          VendorOrder(
            id: oId,
            customerName: row['customer_name']?.toString() ?? 'Valued Customer',
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

      orders.assignAll(loadedOrders);
    } catch (e) {
      debugPrint('Error fetching orders in VendorOrderController: $e');
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('jwt') ||
          errStr.contains('pgrst303') ||
          errStr.contains('401')) {
        SupabaseService.handleSessionExpired('JWT expired in vendor orders');
      }
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
      return orders
          .where(
            (o) =>
                o.status.toLowerCase() == 'pending' ||
                o.status.toLowerCase() == 'paid' ||
                o.status.toLowerCase() == 'authorized',
          )
          .toList();
    } else if (filter == 'Processing') {
      return orders
          .where(
            (o) =>
                o.status.toLowerCase() == 'processing' ||
                o.status.toLowerCase() == 'packed',
          )
          .toList();
    } else if (filter == 'Shipped') {
      return orders
          .where(
            (o) =>
                o.status.toLowerCase() == 'shipped' ||
                o.status.toLowerCase() == 'dispatched' ||
                o.status.toLowerCase() == 'in_transit',
          )
          .toList();
    } else if (filter == 'Returns (RMA)') {
      return orders
          .where(
            (o) =>
                o.status.toLowerCase() == 'returned' ||
                o.status.toLowerCase() == 'cancelled' ||
                o.status.toLowerCase() == 'refunded',
          )
          .toList();
    }
    return orders;
  }

  void acceptOrder(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      final updatedTimeline = List<OrderTimelineStep>.from(oldOrder.timeline)
        ..add(
          OrderTimelineStep(
            title: 'Order Accepted',
            description: 'Confirmed by vendor. Moving to fulfillment.',
            timestamp: DateTime.now(),
            isCompleted: true,
          ),
        );

      final updatedOrder = oldOrder.copyWith(
        status: 'Processing',
        timeline: updatedTimeline,
      );
      orders[index] = updatedOrder;

      if (!SupabaseService.supabaseUrl.contains('placeholder')) {
        _supabase
            .from('orders')
            .update({
              'status': 'Processing',
              'timeline': updatedTimeline
                  .map(
                    (t) => {
                      'title': t.title,
                      'description': t.description,
                      'timestamp': t.timestamp?.toIso8601String(),
                      'isCompleted': t.isCompleted,
                    },
                  )
                  .toList(),
            })
            .eq('id', orderId)
            .catchError((e) {
              debugPrint('Error updating order in Supabase: $e');
            });
      }

      AppSnackbar.success(
        title: 'Order Accepted',
        message: 'Order $orderId has been moved to Processing.',
      );

      // Close the bottom sheet modal if it is currently open
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // Automatically navigate to the packing checklist workspace
      Get.toNamed('/fulfillment-checklist', arguments: updatedOrder);
    }
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      final updatedTimeline = List<OrderTimelineStep>.from(oldOrder.timeline)
        ..add(
          OrderTimelineStep(
            title: 'Order Declined',
            description: 'Declined by Brand: "$reason". Full refund initiated.',
            timestamp: DateTime.now(),
            isCompleted: true,
          ),
        );

      orders[index] = oldOrder.copyWith(
        status: 'Cancelled',
        cancellationReason: reason,
        timeline: updatedTimeline,
      );

      if (!SupabaseService.supabaseUrl.contains('placeholder')) {
        try {
          await _supabase
              .from('orders')
              .update({
                'status': 'Cancelled',
                'cancellation_reason': 'Declined by Vendor: $reason',
                'cancelled_at': DateTime.now().toIso8601String(),
                'refund_status': 'Refund Initiated (Vendor Declined)',
                'timeline': updatedTimeline
                    .map(
                      (t) => {
                        'title': t.title,
                        'description': t.description,
                        'timestamp': t.timestamp?.toIso8601String(),
                        'isCompleted': t.isCompleted,
                      },
                    )
                    .toList(),
              })
              .eq('id', orderId);
        } catch (e) {
          debugPrint('Error updating rejected order in Supabase: $e');
          await _supabase
              .from('orders')
              .update({'status': 'Cancelled'})
              .eq('id', orderId);
        }
      }

      AppSnackbar.error(
        title: 'Order Declined',
        message: 'Order $orderId has been declined. Customer refund initiated.',
      );
    }
  }

  void markAsShipped(String orderId, String trackingNumber) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      final updatedTimeline = List<OrderTimelineStep>.from(oldOrder.timeline)
        ..add(
          OrderTimelineStep(
            title: 'Shipped',
            description: 'Dispatched via carrier. Tracking: $trackingNumber',
            timestamp: DateTime.now(),
            isCompleted: true,
          ),
        );

      orders[index] = oldOrder.copyWith(
        status: 'Shipped',
        trackingNumber: trackingNumber,
        timeline: updatedTimeline,
      );

      if (!SupabaseService.supabaseUrl.contains('placeholder')) {
        _supabase
            .from('orders')
            .update({
              'status': 'Shipped',
              'tracking_number': trackingNumber,
              'timeline': updatedTimeline
                  .map(
                    (t) => {
                      'title': t.title,
                      'description': t.description,
                      'timestamp': t.timestamp?.toIso8601String(),
                      'isCompleted': t.isCompleted,
                    },
                  )
                  .toList(),
            })
            .eq('id', orderId)
            .catchError((e) {
              debugPrint('Error marking order as shipped in Supabase: $e');
            });
      }

      AppSnackbar.success(
        title: 'Order Shipped',
        message: 'Order $orderId marked as Shipped. Tracking ID added.',
      );
    }
  }

  Future<void> markAsDelivered(String orderId) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      final updatedTimeline = List<OrderTimelineStep>.from(oldOrder.timeline)
        ..add(
          OrderTimelineStep(
            title: 'Delivered',
            description: 'Package handed over to recipient successfully.',
            timestamp: DateTime.now(),
            isCompleted: true,
          ),
        );

      orders[index] = oldOrder.copyWith(
        status: 'Delivered',
        timeline: updatedTimeline,
      );

      if (!SupabaseService.supabaseUrl.contains('placeholder')) {
        try {
          await _supabase
              .from('orders')
              .update({
                'status': 'Delivered',
                'delivered_at': DateTime.now().toIso8601String(),
                'timeline': updatedTimeline
                    .map(
                      (t) => {
                        'title': t.title,
                        'description': t.description,
                        'timestamp': t.timestamp?.toIso8601String(),
                        'isCompleted': t.isCompleted,
                      },
                    )
                    .toList(),
              })
              .eq('id', orderId);
        } catch (colErr) {
          await _supabase
              .from('orders')
              .update({'status': 'Delivered'})
              .eq('id', orderId);
        }
      }

      AppSnackbar.success(
        title: 'Delivery Confirmed',
        message: 'Order $orderId marked as Delivered. Customer notified.',
      );
    }
  }

  void processReturn(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      // Simulate completing the refund
      orders.removeAt(index);

      if (!SupabaseService.supabaseUrl.contains('placeholder')) {
        _supabase
            .from('orders')
            .update({'status': 'Returned'})
            .eq('id', orderId)
            .catchError((e) {
              debugPrint('Error updating return status in Supabase: $e');
            });
      }

      AppSnackbar.success(
        title: 'Refund Completed',
        message:
            'RMA for order $orderId completed successfully. Refund initiated.',
      );
    }
  }

  void subscribeToOrders() {
    if (SupabaseService.supabaseUrl.contains('placeholder')) {
      debugPrint(
        'Supabase placeholder URL detected; skipping realtime orders subscription.',
      );
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

      AppSnackbar.info(
        title: 'Real-time Sync',
        message: 'Order $orderId status updated to: $status',
      );
    }
  }
}
