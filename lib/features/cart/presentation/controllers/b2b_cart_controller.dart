import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';
import '../../domain/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

class B2BProductGroup {
  final String baseProductId;
  final String name;
  final String vendorName;
  final String imageUrl;
  final double unitBasePrice;
  final int moq;
  final List<CartItem> variants;

  B2BProductGroup({
    required this.baseProductId,
    required this.name,
    required this.vendorName,
    required this.imageUrl,
    required this.unitBasePrice,
    this.moq = 25,
    required this.variants,
  });

  int get totalQuantity => variants.fold(0, (sum, item) => sum + item.quantity);
  double get totalOriginalPrice => variants.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  bool get isMoqMet => totalQuantity >= moq;
}

class B2BCartController extends GetxController {
  final CartRepository _repository;

  B2BCartController(this._repository);

  final RxList<CartItem> cartItems = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  void _loadCart() {
    final allItems = _repository.getCartItems();
    cartItems.assignAll(allItems.where((item) => item.isB2B).toList());
  }

  void addItem(CartItem item) {
    if (!item.isB2B) return;

    final index = cartItems.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      final updatedItem = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + item.quantity,
      );
      cartItems[index] = updatedItem;
      _repository.updateItem(updatedItem);
    } else {
      cartItems.add(item);
      _repository.addItem(item);
    }
  }

  void addBatchItems(List<CartItem> newItems) {
    for (var item in newItems) {
      if (!item.isB2B) continue;
      final index = cartItems.indexWhere((element) => element.id == item.id);
      if (index >= 0) {
        final updatedItem = cartItems[index].copyWith(
          quantity: cartItems[index].quantity + item.quantity,
        );
        cartItems[index] = updatedItem;
        _repository.updateItem(updatedItem);
      } else {
        cartItems.add(item);
        _repository.addItem(item);
      }
    }
  }

  void updateQuantity(String id, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(id);
      return;
    }
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      final updatedItem = cartItems[index].copyWith(quantity: newQuantity);
      cartItems[index] = updatedItem;
      _repository.updateItem(updatedItem);
    }
  }

  void updateMatrixCell({
    required String baseProductId,
    required String name,
    required String vendorName,
    required double price,
    required String imageUrl,
    required String size,
    required String color,
    required int quantity,
  }) {
    final variantId = "${baseProductId}_${size}_$color";
    final index = cartItems.indexWhere((item) => item.id == variantId);

    if (quantity <= 0) {
      if (index != -1) {
        removeItem(variantId);
      }
      return;
    }

    if (index != -1) {
      final updatedItem = cartItems[index].copyWith(quantity: quantity);
      cartItems[index] = updatedItem;
      _repository.updateItem(updatedItem);
    } else {
      final newItem = CartItem(
        id: variantId,
        name: name,
        vendorName: vendorName,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity,
        isB2B: true,
        size: size,
        color: color,
      );
      cartItems.add(newItem);
      _repository.addItem(newItem);
    }
  }

  void removeItem(String id) {
    cartItems.removeWhere((item) => item.id == id);
    _repository.removeItem(id);
  }

  void removeProductFamily(String baseProductId) {
    final toRemove = cartItems.where((i) => i.baseProductId == baseProductId).toList();
    for (var item in toRemove) {
      removeItem(item.id);
    }
  }

  void clearCart() {
    for (var item in cartItems) {
      _repository.removeItem(item.id);
    }
    cartItems.clear();
  }

  // --- Volume Pricing Engine ---
  double getTierDiscountRate(int totalQty) {
    if (totalQty >= 500) return 0.30; // 30% off
    if (totalQty >= 100) return 0.15; // 15% off
    if (totalQty >= 50) return 0.10;  // 10% off
    return 0.0;
  }

  double getTieredPrice(double basePrice, int totalQty) {
    final discount = getTierDiscountRate(totalQty);
    return basePrice * (1.0 - discount);
  }

  int get totalQuantity =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get activeDiscountRate => getTierDiscountRate(totalQuantity);

  String get activeTierName {
    if (totalQuantity >= 500) return "Platinum Bulk Tier (30% OFF)";
    if (totalQuantity >= 100) return "Gold Wholesale Tier (15% OFF)";
    if (totalQuantity >= 50) return "Silver Volume Tier (10% OFF)";
    return "Standard Wholesale Tier";
  }

  Map<String, dynamic> get nextTierInfo {
    if (totalQuantity >= 500) {
      return {'nextTier': 'Max Tier Reached', 'unitsNeeded': 0, 'discount': 0.30};
    } else if (totalQuantity >= 100) {
      return {'nextTier': 'Platinum Tier (30% OFF)', 'unitsNeeded': 500 - totalQuantity, 'discount': 0.30};
    } else if (totalQuantity >= 50) {
      return {'nextTier': 'Gold Tier (15% OFF)', 'unitsNeeded': 100 - totalQuantity, 'discount': 0.15};
    } else {
      return {'nextTier': 'Silver Tier (10% OFF)', 'unitsNeeded': 50 - totalQuantity, 'discount': 0.10};
    }
  }

  double get rawSubtotal {
    return cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get subtotal {
    double sum = 0;
    for (var item in cartItems) {
      sum += (getTieredPrice(item.price, totalQuantity) * item.quantity);
    }
    return sum;
  }

  double get bulkSavings {
    final savings = rawSubtotal - subtotal;
    return savings > 0 ? savings : 0.0;
  }

  // --- Grouping by Product Family ---
  List<B2BProductGroup> get groupedProducts {
    final Map<String, List<CartItem>> map = {};
    for (var item in cartItems) {
      final baseId = item.baseProductId;
      if (!map.containsKey(baseId)) {
        map[baseId] = [];
      }
      map[baseId]!.add(item);
    }

    return map.entries.map((entry) {
      final items = entry.value;
      final first = items.first;
      return B2BProductGroup(
        baseProductId: entry.key,
        name: first.name,
        vendorName: first.vendorName,
        imageUrl: first.imageUrl,
        unitBasePrice: first.price,
        moq: 25,
        variants: items,
      );
    }).toList();
  }

  // --- Functional CSV Import / Export ---
  bool importCsvData(String csvContent) {
    try {
      final lines = csvContent.split('\n');
      final List<CartItem> parsedItems = [];

      for (var rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#') || line.toLowerCase().startsWith('sku')) {
          continue;
        }

        final parts = line.split(',');
        if (parts.length >= 4) {
          final skuOrName = parts[0].trim();
          final size = parts[1].trim();
          final color = parts[2].trim();
          final qty = int.tryParse(parts[3].trim()) ?? 10;
          final price = (parts.length >= 5) ? (double.tryParse(parts[4].trim()) ?? 25.0) : 25.0;

          final id = "${skuOrName.replaceAll(' ', '_')}_${size}_$color";

          parsedItems.add(
            CartItem(
              id: id,
              name: skuOrName,
              vendorName: 'Corporate Sourcing Direct',
              price: price,
              imageUrl: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=600&h=600&fit=crop',
              quantity: qty,
              isB2B: true,
              size: size,
              color: color,
            ),
          );
        }
      }

      if (parsedItems.isNotEmpty) {
        addBatchItems(parsedItems);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error parsing CSV: $e');
      return false;
    }
  }

  void loadSampleB2BOrder() {
    final sampleItems = [
      CartItem(
        id: 'b2b_1_M_Navy',
        name: 'Bulk Cotton Uniform Polos',
        vendorName: 'National Apparel Group',
        price: 12.50,
        imageUrl: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=600&h=600&fit=crop',
        quantity: 30,
        isB2B: true,
        size: 'M',
        color: 'Navy',
      ),
      CartItem(
        id: 'b2b_1_L_Navy',
        name: 'Bulk Cotton Uniform Polos',
        vendorName: 'National Apparel Group',
        price: 12.50,
        imageUrl: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=600&h=600&fit=crop',
        quantity: 25,
        isB2B: true,
        size: 'L',
        color: 'Navy',
      ),
      CartItem(
        id: 'b2b_1_XL_Black',
        name: 'Bulk Cotton Uniform Polos',
        vendorName: 'National Apparel Group',
        price: 12.50,
        imageUrl: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=600&h=600&fit=crop',
        quantity: 20,
        isB2B: true,
        size: 'XL',
        color: 'Black',
      ),
      CartItem(
        id: 'b2b_5_M_White',
        name: 'Wholesale Linen Shirts (Batch)',
        vendorName: 'Karachi Textiles Ltd',
        price: 14.90,
        imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600&h=600&fit=crop',
        quantity: 35,
        isB2B: true,
        size: 'M',
        color: 'White',
      ),
      CartItem(
        id: 'b2b_5_L_White',
        name: 'Wholesale Linen Shirts (Batch)',
        vendorName: 'Karachi Textiles Ltd',
        price: 14.90,
        imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600&h=600&fit=crop',
        quantity: 25,
        isB2B: true,
        size: 'L',
        color: 'White',
      ),
    ];

    addBatchItems(sampleItems);
    AppSnackbar.info(
      title: 'Bulk Sample Loaded',
      message: 'Loaded 135 units across 2 corporate apparel lines.',
    );
  }
}
