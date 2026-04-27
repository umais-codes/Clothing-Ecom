import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/cart_item_model.dart';

class CartRepository {
  static const String _boxName = 'cartBox';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CartItemAdapter());
    }
    await Hive.openBox<CartItem>(_boxName);
  }

  Box<CartItem> get _box => Hive.box<CartItem>(_boxName);

  List<CartItem> getCartItems() {
    return _box.values.toList();
  }

  Future<void> addItem(CartItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> updateItem(CartItem item) async {
    await _box.put(item.id, item);
  }

  Future<void> removeItem(String id) async {
    await _box.delete(id);
  }

  Future<void> clearCart() async {
    await _box.clear();
  }
}
