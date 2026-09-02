import 'package:ecom_app/features/cart/domain/models/cart_item_model.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2b_cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';
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
      name: 'OXFORD BUTTON-DOWN SHIRT',
      price: 32.00,
      minQty: 30,
      composition: '80% Cotton, 20% Linen',
      imageUrl:
          'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&q=80&w=800',
    ),
    const LineSheetEntity(
      id: 'LS-003',
      name: 'TAILORED CHINO TROUSERS',
      price: 45.00,
      minQty: 25,
      composition: '98% Cotton, 2% Elastane',
      imageUrl:
          'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&q=80&w=800',
    ),
    const LineSheetEntity(
      id: 'LS-004',
      name: 'MERINO WOOL CREWNECK',
      price: 58.00,
      minQty: 20,
      composition: '100% Extra-fine Merino',
      imageUrl:
          'https://images.unsplash.com/photo-1614975058789-41316d0e2e9c?auto=format&fit=crop&q=80&w=800',
    ),
  ].obs;

  // Active Category Selection
  final RxString selectedCategory = 'All Categories'.obs;

  // Matrix Ordering State
  final List<String> sizes = ['S', 'M', 'L', 'XL', '2XL'];
  final List<Map<String, dynamic>> colors = [
    {'name': 'White', 'hex': 0xFFFFFFFF},
    {'name': 'Navy', 'hex': 0xFF001F3F},
    {'name': 'Camel', 'hex': 0xFFC19A6B},
    {'name': 'Black', 'hex': 0xFF1A1A1A},
  ];
  List<String> get matrixSizes => sizes;
  List<String> get matrixColors => colors.map((c) => c['name'] as String).toList();
  final RxMap<String, int> matrixQuantities = <String, int>{}.obs;

  void updateMatrixQuantity(String color, String size, int qty) {
    final key = '$color-$size';
    if (qty <= 0) {
      matrixQuantities.remove(key);
    } else {
      matrixQuantities[key] = qty;
    }
  }

  int get totalMatrixQuantity {
    return matrixQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  double get totalMatrixPrice {
    return totalMatrixQuantity * 35.0;
  }

  void addMatrixToCart() {
    if (totalMatrixQuantity <= 0) {
      AppSnackbar.warning(
        title: 'Empty Matrix',
        message: 'Please enter quantities for at least one size/color in the matrix.',
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
    AppSnackbar.success(
      title: 'Bulk Matrix Added',
      message: 'Added $addedCount units to Corporate Procurement Cart.',
    );
  }

  // RFQ Form State
  final companyNameController = TextEditingController();
  final rfqQuantityController = TextEditingController();
  final rfqNotesController = TextEditingController();

  void submitRFQ() {
    if (companyNameController.text.isEmpty ||
        rfqQuantityController.text.isEmpty) {
      AppSnackbar.error(
        title: 'Form Incomplete',
        message: 'Please fill in all required RFQ fields.',
      );
      return;
    }
    AppSnackbar.success(
      title: 'Quote Requested',
      message: 'Our corporate team will contact ${companyNameController.text} shortly.',
    );
  }
}
