import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/line_sheet_entity.dart';

class B2BPortalController extends GetxController {
  // Line Sheets Data
  final RxList<LineSheetEntity> lineSheets = <LineSheetEntity>[
    const LineSheetEntity(
      id: 'LS-001',
      name: 'PREMIUM COTTON POLO',
      price: 24.50,
      minQty: 50,
      composition: '100% Pima Cotton',
      imageUrl:
          'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&q=80&w=800',
    ),
    const LineSheetEntity(
      id: 'LS-002',
      name: 'EXECUTIVE OXFORD SHIRT',
      price: 38.00,
      minQty: 25,
      composition: 'Egyptian Cotton Blend',
      imageUrl:
          'https://images.unsplash.com/photo-1594932224828-b4b059b6f6f9?auto=format&fit=crop&q=80&w=800',
    ),
    const LineSheetEntity(
      id: 'LS-003',
      name: 'STRETCH CHINO TROUSER',
      price: 42.00,
      minQty: 30,
      composition: '98% Cotton, 2% Elastane',
      imageUrl:
          'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?auto=format&fit=crop&q=80&w=800',
    ),
    const LineSheetEntity(
      id: 'LS-004',
      name: 'TAILORED CORPORATE BLAZER',
      price: 85.00,
      minQty: 10,
      composition: 'Wool Silk Blend',
      imageUrl:
          'https://images.unsplash.com/photo-1591369822096-ffd140ec948f?auto=format&fit=crop&q=80&w=800',
    ),
  ].obs;

  // Matrix Ordering State
  final sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final colors = [
    {'name': 'Navy Blue', 'hex': 0xFF000080},
    {'name': 'Charcoal', 'hex': 0xFF36454F},
    {'name': 'Stone', 'hex': 0xFF87794E},
  ];

  final RxMap<String, int> matrixQuantities = <String, int>{}.obs;

  void updateMatrixQuantity(String size, String color, int qty) {
    final key = '$color-$size';
    matrixQuantities[key] = qty;
  }

  int get totalMatrixQuantity {
    return matrixQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  double get totalMatrixPrice {
    return totalMatrixQuantity * 35.0;
  }

  // RFQ Form State
  final companyNameController = TextEditingController();
  final rfqQuantityController = TextEditingController();
  final rfqNotesController = TextEditingController();

  void submitRFQ() {
    if (companyNameController.text.isEmpty ||
        rfqQuantityController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in required fields',
        snackPosition: .TOP,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
      );
      return;
    }
    Get.snackbar(
      'Quote Requested',
      'Our team will contact ${companyNameController.text} shortly.',
      snackPosition: .TOP,
      backgroundColor: Get.theme.colorScheme.secondary.withValues(alpha: 0.1),
    );
  }

  @override
  void onClose() {
    companyNameController.dispose();
    rfqQuantityController.dispose();
    rfqNotesController.dispose();
    super.onClose();
  }
}
