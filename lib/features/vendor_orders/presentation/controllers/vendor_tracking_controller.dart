import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VendorTrackingController extends GetxController {
  final RxInt activeStepIndex = 1.obs;

  // Mock Order details for vendor logistics panel
  final String orderId = '#ORD-9920';
  final String consigneeName = 'Luxe Apparel Retail Corp';
  final String expectedDelivery = 'June 10, 2026';
  final String courierName = 'Trax Logistics';
  final String trackingId = 'AWB-TRX-773821';
  final double packageWeight = 12.5;
  final String dimensions = '50 x 40 x 30 cm';
  final String shippingAddress =
      'Warehouse 12, Logistics Park South, Karachi, Pakistan';

  final List<Map<String, String>> steps = [
    {
      'title': 'Shipment Label Generated',
      'subtitle': 'AWB generated and registered with Trax.',
    },
    {
      'title': 'Manifest Closed',
      'subtitle': 'Package weighed and ready in vendor dispatch bay.',
    },
    {
      'title': 'Picked Up',
      'subtitle': 'Courier picked up package and left facility.',
    },
    {
      'title': 'In Transit (Marina Hub)',
      'subtitle': 'Arrived at Trax primary sorting hub.',
    },
    {
      'title': 'Out for Delivery',
      'subtitle': 'Shipment is on van for final delivery.',
    },
    {
      'title': 'Delivered & Signed',
      'subtitle': 'Delivered. Received by Luxe Warehouse Lead.',
    },
  ];

  final RxBool isCopied = false.obs;

  void simulateWebhookUpdate() {
    if (activeStepIndex.value < steps.length - 1) {
      activeStepIndex.value++;
      Get.snackbar(
        'Webhook Simulation Triggered',
        'Status updated to: "${steps[activeStepIndex.value]['title']}"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC19A6B).withValues(alpha: 0.15),
        colorText: const Color(0xFF1A1A1A),
      );
    } else {
      activeStepIndex.value = 0;
      Get.snackbar(
        'Webhook Reset',
        'Logistics timeline reset to label generation.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A1A1A).withValues(alpha: 0.1),
        colorText: const Color(0xFF1A1A1A),
      );
    }
  }

  void copyAwb() {
    Clipboard.setData(ClipboardData(text: trackingId));
    isCopied.value = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      isCopied.value = false;
    });
  }
}
