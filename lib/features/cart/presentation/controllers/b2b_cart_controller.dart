import 'package:get/get.dart';
import '../../domain/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

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

  void updateMatrixQuantity(String baseProductId, String size, int quantity) {
    final variantId = "${baseProductId}_$size";
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
      // Logic to create new variant - in a real app, you'd fetch product details
      // For this demo, we'll assume we have a way to get the base product info
      // Or we can just update existing ones.
    }
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

  void removeItem(String id) {
    cartItems.removeWhere((item) => item.id == id);
    _repository.removeItem(id);
  }

  void clearCart() {
    for (var item in cartItems) {
      _repository.removeItem(item.id);
    }
    cartItems.clear();
  }

  double get subtotal {
    double sum = 0;
    for (var item in cartItems) {
      sum += (getTieredPrice(item.price, item.quantity) * item.quantity);
    }
    return sum;
  }

  double getTieredPrice(double basePrice, int totalQuantity) {
    if (totalQuantity >= 500) return basePrice * 0.70; // 30% off
    if (totalQuantity >= 100) return basePrice * 0.85; // 15% off
    if (totalQuantity >= 50) return basePrice * 0.90; // 10% off
    return basePrice;
  }

  int get totalQuantity =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get bulkSavings => cartItems.fold(0.0, (sum, item) {
    final originalTotal = item.price * item.quantity;
    final tieredTotal =
        getTieredPrice(item.price, item.quantity) * item.quantity;
    return sum + (originalTotal - tieredTotal);
  });

  void uploadCsv() {
    // Mock CSV Upload logic
    Get.snackbar(
      "CSV Upload",
      "Bulk order imported successfully from CSV.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void submitPurchaseOrder() {
    Get.snackbar(
      "Purchase Order",
      "PO submitted successfully. Our procurement team will contact you.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void requestQuote() {
    Get.snackbar(
      "Quote Requested",
      "Your request for a custom quote has been sent.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
