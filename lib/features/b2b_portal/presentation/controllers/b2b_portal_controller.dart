import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/cart/domain/models/cart_item_model.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2b_cart_controller.dart';
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

  void addMatrixToCart() {
    if (totalMatrixQuantity <= 0) {
      Get.snackbar(
        'Empty Matrix',
        'Please enter quantities for at least one size/color in the matrix.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withValues(alpha: 0.1),
        colorText: AppColors.charcoal,
      );
      return;
    }

    final b2bCart = Get.find<B2BCartController>();
    final List<CartItem> itemsToAdd = [];

    matrixQuantities.forEach((key, qty) {
      if (qty > 0) {
        final parts = key.split('-');
        final color = parts[0];
        final size = parts.length > 1 ? parts[1] : 'M';
        final id = "LS-001_${size}_$color";

        itemsToAdd.add(
          CartItem(
            id: id,
            name: "PREMIUM COTTON POLO",
            vendorName: "Corporate Sourcing Direct",
            price: 35.0,
            imageUrl:
                "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&q=80&w=800",
            quantity: qty,
            isB2B: true,
            size: size,
            color: color,
          ),
        );
      }
    });

    final addedCount = totalMatrixQuantity;
    b2bCart.addBatchItems(itemsToAdd);
    matrixQuantities.clear();

    Get.toNamed('/b2b-cart');
    Get.snackbar(
      'Bulk Matrix Added',
      'Added $addedCount units to Corporate Procurement Cart.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.camel,
      colorText: AppColors.white,
    );
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
      );
      return;
    }
    Get.snackbar(
      'Quote Requested',
      'Our team will contact ${companyNameController.text} shortly.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.secondary.withValues(alpha: 0.1),
    );
  }
}
