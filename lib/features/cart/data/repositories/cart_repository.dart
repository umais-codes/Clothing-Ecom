import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
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
    _syncWithSupabase(item, isDelete: false);
  }

  Future<void> updateItem(CartItem item) async {
    await _box.put(item.id, item);
    _syncWithSupabase(item, isDelete: false);
  }

  Future<void> removeItem(String id) async {
    final item = _box.get(id);
    await _box.delete(id);
    if (item != null) {
      _syncWithSupabase(item, isDelete: true);
    }
  }

  Future<void> clearCart() async {
    await _box.clear();
  }

  void _syncWithSupabase(CartItem item, {required bool isDelete}) async {
    try {
      if (!Get.isRegistered<SupabaseService>()) return;
      final supabase = Get.find<SupabaseService>().client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      if (isDelete) {
        await supabase
            .from('cart_items')
            .delete()
            .eq('user_id', user.id)
            .eq('item_id', item.id);
      } else {
        await supabase.from('cart_items').upsert({
          'user_id': user.id,
          'item_id': item.id,
          'product_id': item.baseProductId,
          'product_name': item.name,
          'vendor_name': item.vendorName,
          'price': item.price,
          'image_url': item.imageUrl,
          'quantity': item.quantity,
          'is_b2b': item.isB2B,
          'size': item.size,
          'color': item.color,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Cart Supabase background sync (non-fatal): $e');
    }
  }
}
