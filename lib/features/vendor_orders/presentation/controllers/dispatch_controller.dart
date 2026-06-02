import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DispatchController extends GetxController {
  // Input Controllers
  final weightController = TextEditingController(text: '1.2');
  final lengthController = TextEditingController(text: '30');
  final widthController = TextEditingController(text: '20');
  final heightController = TextEditingController(text: '10');
  final addressController = TextEditingController(
    text: 'Apt 4B, Beverly Hills Tower, Marina, Dubai, UAE',
  );

  // States
  final RxString selectedCourier = 'Trax'.obs;
  final RxBool isBooked = false.obs;
  final RxBool notifyCustomer = true.obs;
  final RxString generatedAwb = ''.obs;

  final List<String> couriers = ['Trax', 'PostEx', 'Leopards'];

  @override
  void onClose() {
    weightController.dispose();
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    addressController.dispose();
    super.onClose();
  }

  bool get isFormValid {
    final weightVal = double.tryParse(weightController.text.trim());
    final lengthVal = int.tryParse(lengthController.text.trim());
    final widthVal = int.tryParse(widthController.text.trim());
    final heightVal = int.tryParse(heightController.text.trim());
    final addressText = addressController.text.trim();

    if (weightVal == null || weightVal <= 0) return false;
    if (lengthVal == null || lengthVal <= 0) return false;
    if (widthVal == null || widthVal <= 0) return false;
    if (heightVal == null || heightVal <= 0) return false;
    if (addressText.isEmpty) return false;

    return true;
  }

  void bookShipment() {
    if (!isFormValid) {
      Get.snackbar(
        'Validation Failure',
        'Please enter correct packaging specifications and address.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC0392B).withValues(alpha: 0.15),
        colorText: const Color(0xFFC0392B),
      );
      return;
    }

    // Simulate booking with courier
    final prefix = selectedCourier.value.toUpperCase();
    final randomNum = Random().nextInt(900000) + 100000;
    generatedAwb.value = '$prefix-$randomNum';
    isBooked.value = true;

    Get.snackbar(
      'Shipment Booked',
      'Air Waybill generated: ${generatedAwb.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4A7C59).withValues(alpha: 0.15),
      colorText: const Color(0xFF4A7C59),
    );
  }

  void resetBooking() {
    isBooked.value = false;
    generatedAwb.value = '';
  }
}
