import 'package:get/get.dart';
import '../../domain/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

class B2CCartController extends GetxController {
  final CartRepository _repository;

  B2CCartController(this._repository);

  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final double deliveryFee = 15.0;

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

  void clearCart() {
    for (var item in cartItems) {
      _repository.removeItem(item.id);
    }
    cartItems.clear();
  }

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get total => subtotal > 0 ? subtotal + deliveryFee : 0;

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
