import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';

class TrackingController extends GetxController {
  final RxInt activeStepIndex = 0.obs;

  RealtimeChannel? _trackingSubscriptionChannel;
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

  // Mock Order Details for tracking view
  final String orderId = '#ORD-8829';
  final String expectedDelivery = 'June 9, 2026';
  final String itemName = 'Cashmere Wool Blazer';
  final String itemImageUrl =
      'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=300&auto=format&fit=crop';
  final String courierName = 'Trax Logistics';
  final String trackingId = 'AWB9928172';

  final List<Map<String, String>> steps = [
    {
      'title': 'Order Placed',
      'subtitle': 'Order successfully authorized and paid.',
    },
    {
      'title': 'Processing',
      'subtitle': 'Vendor accepted and locked inventory.',
    },
    {
      'title': 'Packed',
      'subtitle': 'Garment sorted and placed in premium bags.',
    },
    {
      'title': 'Dispatched/On the Way',
      'subtitle': 'AWB generated. Trax courier is delivering.',
    },
    {'title': 'Delivered', 'subtitle': 'Package received at customer address.'},
  ];

  void simulateStatusUpdate() {
    if (activeStepIndex.value < steps.length - 1) {
      activeStepIndex.value++;
      Get.snackbar(
        'Logistics Webhook Triggered',
        'Status updated: "${steps[activeStepIndex.value]['title']}"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC19A6B).withValues(alpha: 0.15),
        colorText: const Color(0xFF1A1A1A),
      );
    } else {
      // Reset back to Placed for infinite testing simulation
      activeStepIndex.value = 0;
      Get.snackbar(
        'Webhook Reset',
        'Fulfillment lifecycle reset to Order Placed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A1A1A).withValues(alpha: 0.1),
        colorText: const Color(0xFF1A1A1A),
      );
    }
  }

  void copyTrackingId() {
    Clipboard.setData(ClipboardData(text: trackingId));
    Get.snackbar(
      'AWB Copied',
      'Tracking ID $trackingId copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4A7C59).withValues(alpha: 0.15),
      colorText: const Color(0xFF4A7C59),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onInit() {
    super.onInit();
    subscribeToTrackingChanges();
  }

  @override
  void onClose() {
    _trackingSubscriptionChannel?.unsubscribe();
    super.onClose();
  }

  void subscribeToTrackingChanges() {
    _trackingSubscriptionChannel = _supabase
        .channel('public:orders_tracking')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            final record = payload.newRecord;
            if (record.containsKey('id') && record['id']?.toString() == orderId) {
              final status = record['status']?.toString() ?? 'Pending';
              _updateStepperIndexFromStatus(status);
            }
          },
        );
    _trackingSubscriptionChannel?.subscribe();
  }

  void _updateStepperIndexFromStatus(String status) {
    int index = 0;
    if (status == 'Processing') {
      index = 1;
    } else if (status == 'Packed') {
      index = 2;
    } else if (status == 'Shipped') {
      index = 3;
    } else if (status == 'Delivered') {
      index = 4;
    }
    activeStepIndex.value = index;

    Get.snackbar(
      'Fulfillment Status Update',
      'Your order progress updated to: $status',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFC19A6B).withValues(alpha: 0.15),
      colorText: const Color(0xFF1A1A1A),
    );
  }
}
