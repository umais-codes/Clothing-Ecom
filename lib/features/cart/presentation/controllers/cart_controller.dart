import 'package:get/get.dart';
import '../../domain/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _repository;

  CartController(this._repository);

  final RxList<CartItem> cartItems = <CartItem>[].obs;

  final double deliveryFee = 15.0;
  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  void _loadCart() {
    cartItems.assignAll(_repository.getCartItems());
  }

  void clearCart() {
    cartItems.clear();
  }

  void addItem(CartItem item) {
    final existingIndex = cartItems.indexWhere(
      (element) => element.id == item.id,
    );
    if (existingIndex >= 0) {
      final existingItem = cartItems[existingIndex];
      final newQuantity = existingItem.quantity + item.quantity;
      updateQuantity(existingItem.id, newQuantity);
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

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get total => subtotal > 0 ? subtotal + deliveryFee : 0;

  double get platformCommission =>
      subtotal * 0.05; // 5% commission hidden from user

  // Grouped by vendor
  Map<String, List<CartItem>> get groupedCartItems {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in cartItems) {
      if (!grouped.containsKey(item.vendorName)) {
        grouped[item.vendorName] = [];
      }
      grouped[item.vendorName]!.add(item);
    }
    return grouped;
  }
}
