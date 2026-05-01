import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../cart/domain/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/models/product_model.dart';

class WishlistController extends GetxController {
  static const String _boxName = 'wishlist_box';
  final RxList<Product> wishlistItems = <Product>[].obs;
  late Box<Product> _box;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProductAdapter());
    }
    _box = await Hive.openBox<Product>(_boxName);
    _loadWishlist();
  }

  void _loadWishlist() {
    wishlistItems.assignAll(_box.values.toList());
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }

  void addToWishlist(Product product) {
    if (!isInWishlist(product.id)) {
      wishlistItems.add(product);
      _box.put(product.id, product);
      Get.snackbar(
        'Added to Wishlist',
        '${product.name} has been saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeFromWishlist(String productId) {
    wishlistItems.removeWhere((item) => item.id == productId);
    _box.delete(productId);
  }

  bool isInWishlist(String productId) {
    return wishlistItems.any((item) => item.id == productId);
  }

  void moveToCart(Product product) {
    final cartController = Get.find<CartController>();

    // Convert Product to CartItem
    final cartItem = CartItem(
      id: product.id,
      name: product.name,
      vendorName: product.vendorName,
      price: product.price,
      imageUrl: product.imageUrl,
      quantity: 1,
    );

    cartController.addItem(cartItem);
    removeFromWishlist(product.id);

    Get.snackbar(
      'Moved to Cart',
      '${product.name} is now in your shopping bag.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void clearWishlist() {
    wishlistItems.clear();
    _box.clear();
  }
}
