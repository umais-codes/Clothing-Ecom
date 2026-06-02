import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TrackingController extends GetxController {
  final RxInt activeStepIndex = 0.obs;

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
}
