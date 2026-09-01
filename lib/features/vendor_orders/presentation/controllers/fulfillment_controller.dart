import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
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
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;
  
  // Checklist states
  final RxMap<String, bool> packedStates = <String, bool>{}.obs;
  final RxBool isSubmitting = false.obs;
  
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
    'TCS Express',
    'M&P Logistics',
    'Custom/Other'
  ];

  FulfillmentController({required this.order});

  @override
  void onInit() {
    super.onInit();
    _generateChecklist();
    autoGenerateAwb();
  }

  void autoGenerateAwb() {
    final carrier = selectedCourier.value;
    String prefix = "TRX";
    if (carrier.contains("TCS")) {
      prefix = "TCS";
    } else if (carrier.contains("Leopard")) {
      prefix = "LEO";
    } else if (carrier.contains("PostEx")) {
      prefix = "PEX";
    } else if (carrier.contains("M&P")) {
      prefix = "MNP";
    }
    final randomNum = (DateTime.now().millisecondsSinceEpoch % 900000) + 100000;
    trackingController.text = "$prefix-$randomNum-PK";
    if (weightController.text.isEmpty) {
      weightController.text = "1.2";
    }
  }

  void _generateChecklist() {
    checklistItems.clear();
    
    if (order.isB2B) {
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
    if (checklistItems.isEmpty) return true;
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

  Future<void> confirmShipment() async {
    if (!isFormValid) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid weight (kg) and tracking number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
      return;
    }

    final tracking = trackingController.text.trim();
    final weight = double.parse(weightController.text.trim());
    final courier = selectedCourier.value;

    try {
      isSubmitting.value = true;

      // 1. Update Supabase orders table with real courier tracking
      try {
        await _supabase.from('orders').update({
          'status': 'Shipped',
          'tracking_number': tracking,
          'courier_partner': courier,
          'package_weight': weight,
          'shipped_at': DateTime.now().toIso8601String(),
        }).eq('id', order.id);
      } catch (colErr) {
        debugPrint('Detailed shipment metadata update failed ($colErr), falling back to core fields');
        await _supabase.from('orders').update({
          'status': 'Shipped',
          'tracking_number': tracking,
          'courier_partner': courier,
        }).eq('id', order.id);
      }

      // 2. Trigger update in main VendorOrderController
      if (Get.isRegistered<VendorOrderController>()) {
        final orderController = Get.find<VendorOrderController>();
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
        }
      }

      Get.snackbar(
        'Shipment Confirmed',
        'Order ${order.id} has been dispatched via $courier (AWB: $tracking).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.success,
        duration: const Duration(seconds: 4),
      );

      // Close sheets and navigate back
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
      
      Get.until((route) => Get.currentRoute == '/vendor-orders' || Get.currentRoute == '/main-navigation');
    } catch (e) {
      debugPrint('Error confirming shipment: $e');
      Get.snackbar(
        'Dispatch Error',
        'Failed to confirm shipment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
