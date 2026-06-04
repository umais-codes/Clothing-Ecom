import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/vendor_order.dart';
import 'vendor_order_controller.dart';

class FulfillmentChecklistItem {
  final String id;
  final String name;
  final String size;
  final String color;
  final int quantity;
  final String imageUrl;

  FulfillmentChecklistItem({
    required this.id,
    required this.name,
    required this.size,
    required this.color,
    required this.quantity,
    required this.imageUrl,
  });
}

class FulfillmentController extends GetxController {
  final VendorOrder order;
  
  // Checklist states
  final RxMap<String, bool> packedStates = <String, bool>{}.obs;
  
  // Checklist items
  final List<FulfillmentChecklistItem> checklistItems = [];

  // Courier inputs
  final RxString selectedCourier = 'Trax Logistics'.obs;
  final weightController = TextEditingController();
  final trackingController = TextEditingController();

  final List<String> couriers = [
    'Trax Logistics',
    'PostEx Express',
    'Leopards Courier',
    'Custom/Other'
  ];

  FulfillmentController({required this.order});

  @override
  void onInit() {
    super.onInit();
    _generateChecklist();
  }

  @override
  void onClose() {
    weightController.dispose();
    trackingController.dispose();
    super.onClose();
  }

  void _generateChecklist() {
    checklistItems.clear();
    
    if (order.isB2B) {
      // B2B: extract flat items from the size/color matrix
      final matrix = order.b2bMatrix ?? {};
      final baseItemName = order.items.isNotEmpty ? order.items.first.name : "Bulk Apparel";
      final baseImageUrl = order.items.isNotEmpty 
          ? order.items.first.imageUrl 
          : "https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=300&auto=format&fit=crop";
      
      int index = 0;
      matrix.forEach((color, sizeMap) {
        sizeMap.forEach((size, qty) {
          if (qty > 0) {
            final key = "b2b_item_${index++}";
            checklistItems.add(
              FulfillmentChecklistItem(
                id: key,
                name: baseItemName,
                size: size,
                color: color,
                quantity: qty,
                imageUrl: baseImageUrl,
              ),
            );
            packedStates[key] = false;
          }
        });
      });
    } else {
      // B2C: map direct order items
      for (final item in order.items) {
        checklistItems.add(
          FulfillmentChecklistItem(
            id: item.id,
            name: item.name,
            size: item.size ?? 'N/A',
            color: item.color ?? 'N/A',
            quantity: item.quantity,
            imageUrl: item.imageUrl,
          ),
        );
        packedStates[item.id] = false;
      }
    }
  }

  void togglePacked(String itemId) {
    if (packedStates.containsKey(itemId)) {
      packedStates[itemId] = !(packedStates[itemId] ?? false);
    }
  }

  void markAllPacked(bool packed) {
    for (final key in packedStates.keys) {
      packedStates[key] = packed;
    }
  }

  bool get isAllPacked {
    return !packedStates.values.contains(false);
  }

  bool get isFormValid {
    final weightText = weightController.text.trim();
    final trackingText = trackingController.text.trim();

    if (weightText.isEmpty || trackingText.isEmpty) {
      return false;
    }
    final double? weight = double.tryParse(weightText);
    if (weight == null || weight <= 0) {
      return false;
    }
    return true;
  }

  void confirmShipment() {
    if (!isFormValid) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid weight (kg) and tracking number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC0392B).withValues(alpha: 0.1),
        colorText: const Color(0xFFC0392B),
      );
      return;
    }

    final tracking = trackingController.text.trim();
    final weight = double.parse(weightController.text.trim());
    final courier = selectedCourier.value;

    // Trigger update in main VendorOrderController
    final orderController = Get.find<VendorOrderController>();
    
    // Find index of old order
    final idx = orderController.orders.indexWhere((o) => o.id == order.id);
    if (idx != -1) {
      final old = orderController.orders[idx];
      final updatedTimeline = List<OrderTimelineStep>.from(old.timeline)
        ..add(OrderTimelineStep(
          title: 'Shipped',
          description: 'Dispatched via $courier. Tracking: $tracking. Weight: ${weight}kg',
          timestamp: DateTime.now(),
          isCompleted: true,
        ));
      
      orderController.orders[idx] = old.copyWith(
        status: 'Shipped',
        trackingNumber: tracking,
        courierPartner: courier,
        packageWeight: weight,
        timeline: updatedTimeline,
      );

      Get.snackbar(
        'Shipment Confirmed',
        'Order ${order.id} has been shipped successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4A7C59).withValues(alpha: 0.1),
        colorText: const Color(0xFF4A7C59),
      );
    }
    
    // Navigate back to orders list workspace
    Get.until((route) => Get.currentRoute == '/vendor-orders' || Get.currentRoute == '/main-navigation');
  }
}
