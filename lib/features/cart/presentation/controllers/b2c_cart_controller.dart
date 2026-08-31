import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/wishlist/domain/models/product_model.dart';
import 'package:ecom_app/features/wishlist/presentation/controllers/wishlist_controller.dart';
import '../../domain/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

class B2CCartController extends GetxController {
  final CartRepository _repository;

  B2CCartController(this._repository);

  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final double baseDeliveryFee = 15.0;
  final double freeDeliveryThreshold = 150.0;

  // Promo Code Engine
  final RxString appliedPromoCode = ''.obs;
  final RxDouble discountPercent = 0.0.obs;
  final RxBool isFreeShippingPromo = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  void _loadCart() {
    final allItems = _repository.getCartItems();
    cartItems.assignAll(allItems.where((item) => !item.isB2B).toList());
  }

  void addItem(CartItem item) {
    if (item.isB2B) return;

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

  void removeItem(String id) {
    cartItems.removeWhere((item) => item.id == id);
    _repository.removeItem(id);
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

  void moveToWishlist(CartItem item) {
    try {
      if (Get.isRegistered<WishlistController>()) {
        final wishlistCtrl = Get.find<WishlistController>();
        final product = Product(
          id: item.baseProductId,
          name: item.name,
          vendorName: item.vendorName,
          price: item.price,
          imageUrl: item.imageUrl,
          isB2B: false,
          sizes: item.size != null ? [item.size!] : const ['S', 'M', 'L'],
          colors: item.color != null ? [item.color!] : const ['Camel', 'White'],
        );
        wishlistCtrl.addToWishlist(product);
      }
      removeItem(item.id);
      Get.snackbar(
        'Moved to Wishlist',
        '${item.name} has been moved to your wishlist.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.charcoal,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error moving item to wishlist: $e');
    }
  }

  void clearCart() {
    for (var item in cartItems) {
      _repository.removeItem(item.id);
    }
    cartItems.clear();
    removePromoCode();
  }

  // --- Promo Code Actions ---
  bool applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    if (cleanCode == 'VELVET10') {
      appliedPromoCode.value = cleanCode;
      discountPercent.value = 0.10;
      isFreeShippingPromo.value = false;
      return true;
    } else if (cleanCode == 'VIP20') {
      appliedPromoCode.value = cleanCode;
      discountPercent.value = 0.20;
      isFreeShippingPromo.value = false;
      return true;
    } else if (cleanCode == 'SUMMER15') {
      appliedPromoCode.value = cleanCode;
      discountPercent.value = 0.15;
      isFreeShippingPromo.value = false;
      return true;
    } else if (cleanCode == 'FREESHIP') {
      appliedPromoCode.value = cleanCode;
      discountPercent.value = 0.0;
      isFreeShippingPromo.value = true;
      return true;
    }
    return false;
  }

  void removePromoCode() {
    appliedPromoCode.value = '';
    discountPercent.value = 0.0;
    isFreeShippingPromo.value = false;
  }

  // --- Financial Computations ---
  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  int get totalItemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get discountAmount => subtotal * discountPercent.value;

  double get deliveryFee {
    if (subtotal == 0) return 0.0;
    if (isFreeShippingPromo.value) return 0.0;
    if (subtotal >= freeDeliveryThreshold) return 0.0;
    return baseDeliveryFee;
  }

  double get total {
    if (subtotal == 0) return 0.0;
    final discounted = subtotal - discountAmount;
    return (discounted + deliveryFee).clamp(0.0, double.infinity);
  }

  double get amountNeededForFreeShipping {
    if (subtotal >= freeDeliveryThreshold) return 0.0;
    return freeDeliveryThreshold - subtotal;
  }

  Map<String, List<CartItem>> get groupedCartItems {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in cartItems) {
      final vendor = item.vendorName.isNotEmpty ? item.vendorName : 'Boutique Apparel';
      if (!grouped.containsKey(vendor)) {
        grouped[vendor] = [];
      }
      grouped[vendor]!.add(item);
    }
    return grouped;
  }
}
