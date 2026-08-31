import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class TrackingController extends GetxController {
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;
  RealtimeChannel? _trackingSubscriptionChannel;

  final RxBool isLoading = true.obs;
  final RxBool hasNoOrders = false.obs;
  final RxString orderId = ''.obs;
  final RxString status = 'Paid'.obs;
  final RxString customerName = ''.obs;
  final RxString customerEmail = ''.obs;
  final RxString customerPhone = ''.obs;
  final RxString shippingAddress = ''.obs;
  final RxDouble amount = 0.0.obs;
  final RxString paymentMethod = 'Safepay'.obs;
  final RxString courierName = 'Trax Logistics'.obs;
  final RxString trackingId = 'AWB-PENDING'.obs;
  final RxString expectedDelivery = 'Calculating...'.obs;
  final RxString createdAtFormatted = ''.obs;
  final RxList<Map<String, dynamic>> orderItems = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userOrders = <Map<String, dynamic>>[].obs;

  final RxInt activeStepIndex = 0.obs;
  final RxBool isCancelling = false.obs;

  bool get canCancel {
    final s = status.value.toLowerCase();
    return s == 'pending' || s == 'paid' || s == 'processing';
  }

  final List<Map<String, String>> steps = [
    {
      'title': 'Order Placed',
      'subtitle': 'Order successfully authorized and paid.',
    },
    {
      'title': 'Processing',
      'subtitle': 'Vendor accepted order and reserved inventory.',
    },
    {
      'title': 'Packed',
      'subtitle': 'Garments packaged with bespoke dust bags.',
    },
    {
      'title': 'Dispatched',
      'subtitle': 'Handed to courier. Tracking code activated.',
    },
    {
      'title': 'Delivered',
      'subtitle': 'Package delivered to your shipping address.',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    String? initialOrderId;
    if (args is Map && args['orderId'] != null) {
      initialOrderId = args['orderId'].toString();
    } else if (args is String) {
      initialOrderId = args;
    }

    loadOrderData(initialOrderId);
  }

  @override
  void onClose() {
    _trackingSubscriptionChannel?.unsubscribe();
    super.onClose();
  }

  Future<void> loadOrderData(String? targetOrderId) async {
    try {
      isLoading.value = true;
      hasNoOrders.value = false;
      final user = _supabase.auth.currentUser;

      // 1. Fetch user's orders list from Supabase
      if (user != null) {
        try {
          final res = await _supabase
              .from('orders')
              .select(
                'id, amount, status, created_at, tracking_number, courier_partner',
              )
              .eq('customer_id', user.id)
              .order('created_at', ascending: false)
              .limit(10);

          userOrders.value = List<Map<String, dynamic>>.from(res);
        } catch (oe) {
          debugPrint('Error fetching user orders: $oe');
        }
      }

      // 2. Determine target order ID
      String selectedId = targetOrderId ?? '';
      if (selectedId.isEmpty && userOrders.isNotEmpty) {
        selectedId = userOrders.first['id'].toString();
      }

      if (selectedId.isEmpty) {
        hasNoOrders.value = true;
        isLoading.value = false;
        return;
      }

      // 3. Fetch real order record from Supabase
      final orderRes = await _supabase
          .from('orders')
          .select('*')
          .eq('id', selectedId)
          .maybeSingle();

      if (orderRes == null) {
        hasNoOrders.value = true;
        isLoading.value = false;
        return;
      }

      _populateOrderDetails(orderRes);

      // 4. Fetch real Order Items from Supabase
      try {
        final itemsRes = await _supabase
            .from('order_items')
            .select('*')
            .eq('order_id', selectedId);

        orderItems.value = List<Map<String, dynamic>>.from(itemsRes);
      } catch (ie) {
        debugPrint('Error fetching order items: $ie');
      }

      // 5. Connect Realtime live sync
      _subscribeToRealtime(selectedId);
    } catch (e) {
      debugPrint('Error in loadOrderData: $e');
      hasNoOrders.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void switchOrder(String newOrderId) {
    if (newOrderId == orderId.value) return;
    _trackingSubscriptionChannel?.unsubscribe();
    loadOrderData(newOrderId);
  }

  void _populateOrderDetails(Map<String, dynamic> row) {
    orderId.value = row['id']?.toString() ?? '';
    final st = row['status']?.toString() ?? 'Pending';
    status.value = st;
    customerName.value = row['customer_name']?.toString() ?? 'Valued Customer';
    customerEmail.value = row['customer_email']?.toString() ?? '';
    customerPhone.value = row['customer_phone']?.toString() ?? '';
    shippingAddress.value =
        row['shipping_address']?.toString() ?? 'Standard Delivery';
    amount.value = (row['amount'] as num?)?.toDouble() ?? 0.0;
    paymentMethod.value = row['payment_method']?.toString() ?? 'Safepay';
    courierName.value = row['courier_partner']?.toString() ?? 'Trax Logistics';

    final awb = row['tracking_number']?.toString();
    trackingId.value = (awb != null && awb.isNotEmpty)
        ? awb
        : (row['safepay_tracker']?.toString() ?? 'AWB-PENDING');

    final createdStr = row['created_at']?.toString();
    if (createdStr != null) {
      final dt = DateTime.tryParse(createdStr);
      if (dt != null) {
        createdAtFormatted.value = DateFormat(
          'MMM dd, yyyy • hh:mm a',
        ).format(dt.toLocal());
        final estDelivery = dt.add(const Duration(days: 3));
        expectedDelivery.value = DateFormat(
          'EEEE, MMM dd, yyyy',
        ).format(estDelivery);
      }
    } else {
      createdAtFormatted.value = DateFormat(
        'MMM dd, yyyy',
      ).format(DateTime.now());
      expectedDelivery.value = DateFormat(
        'EEEE, MMM dd, yyyy',
      ).format(DateTime.now().add(const Duration(days: 3)));
    }

    _updateStepperIndexFromStatus(st);
  }

  void _subscribeToRealtime(String currentId) {
    if (SupabaseService.supabaseUrl.contains('placeholder')) return;

    _trackingSubscriptionChannel = _supabase
        .channel('public:customer_order_tracking_$currentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: currentId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            final updatedStatus = record['status']?.toString();
            final updatedTracking = record['tracking_number']?.toString();
            final updatedCourier = record['courier_partner']?.toString();

            if (updatedStatus != null) {
              status.value = updatedStatus;
              _updateStepperIndexFromStatus(updatedStatus);
            }
            if (updatedTracking != null && updatedTracking.isNotEmpty) {
              trackingId.value = updatedTracking;
            }
            if (updatedCourier != null && updatedCourier.isNotEmpty) {
              courierName.value = updatedCourier;
            }

            Get.snackbar(
              'Live Order Update',
              'Status updated to: $updatedStatus',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.camelLight,
              colorText: AppColors.charcoal,
              duration: const Duration(seconds: 3),
            );
          },
        );
    _trackingSubscriptionChannel?.subscribe();
  }

  void _updateStepperIndexFromStatus(String currentStatus) {
    final s = currentStatus.toLowerCase();
    int index = 0;
    if (s == 'pending' || s == 'paid' || s == 'authorized') {
      index = 0;
    } else if (s == 'processing') {
      index = 1;
    } else if (s == 'packed' || s == 'quality_checked') {
      index = 2;
    } else if (s == 'shipped' || s == 'dispatched' || s == 'in_transit') {
      index = 3;
    } else if (s == 'delivered' || s == 'completed') {
      index = 4;
    }
    activeStepIndex.value = index;
  }

  Future<bool> cancelOrder(String reason) async {
    if (!canCancel || orderId.value.isEmpty) return false;

    try {
      isCancelling.value = true;
      final orderToCancel = orderId.value;

      try {
        await _supabase.from('orders').update({
          'status': 'Cancelled',
          'cancellation_reason': reason,
          'cancelled_at': DateTime.now().toIso8601String(),
        }).eq('id', orderToCancel);
      } catch (colErr) {
        debugPrint(
          'Detailed cancellation metadata update failed ($colErr). Falling back to basic status update.',
        );
        await _supabase.from('orders').update({
          'status': 'Cancelled',
        }).eq('id', orderToCancel);
      }

      status.value = 'Cancelled';

      // Update in local user orders list
      final idx =
          userOrders.indexWhere((o) => o['id']?.toString() == orderToCancel);
      if (idx != -1) {
        userOrders[idx]['status'] = 'Cancelled';
        userOrders.refresh();
      }

      Get.snackbar(
        'Order Cancelled',
        'Order $orderToCancel has been cancelled. Any authorized charges will be refunded automatically.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
        duration: const Duration(seconds: 4),
      );

      return true;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      final errorMsg = e.toString().contains('column')
          ? 'Database schema error. Please retry.'
          : 'Unable to cancel order at this time. Please contact support.';

      Get.snackbar(
        'Cancellation Failed',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  void copyTrackingId() {
    Clipboard.setData(ClipboardData(text: trackingId.value));
    Get.snackbar(
      'AWB Copied',
      'Tracking Code ${trackingId.value} copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successBg,
      colorText: AppColors.success,
      duration: const Duration(seconds: 2),
    );
  }
}
