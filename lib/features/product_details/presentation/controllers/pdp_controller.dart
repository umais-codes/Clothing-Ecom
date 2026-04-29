import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/cart/domain/models/cart_item_model.dart';
import 'package:ecom_app/features/cart/presentation/controllers/cart_controller.dart';
import 'package:ecom_app/features/wishlist/domain/models/product_model.dart';
import 'package:get/get.dart';

class PdpController extends GetxController {
  late final Map<String, dynamic> product;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      product = args;
    } else if (args is Product) {
      product = args.toMap();
    } else {
      product = {};
    }
  }

  final RxString selectedSize = 'M'.obs;
  final RxString selectedColor = 'Sand'.obs;
  final RxBool isSizePredictorExpanded = false.obs;
  final RxDouble predictedSize = 0.0.obs;
  final RxInt quantity = 1.obs;

  final List<String> sizes = ['S', 'M', 'L', 'XL'];
  final List<String> colors = ['Sand', 'Charcoal', 'Ivory'];

  String get description => product['description'] ?? 
    "Experience pure luxury with this meticulously crafted piece. Designed for the modern individual who values both style and substance, this garment features premium fabrics and a silhouette that effortlessly transitions from day to night. Each detail has been carefully considered to ensure a perfect fit and unparalleled comfort.";

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void selectColor(String color) {
    selectedColor.value = color;
  }

  void toggleSizePredictor() {
    isSizePredictorExpanded.value = !isSizePredictorExpanded.value;
  }

  void runAIPrediction() {
    Future.delayed(const Duration(seconds: 1), () {
      predictedSize.value = 1.0;
    });
  }

  void updateQuantity(int val) {
    if (val < 1) return;
    quantity.value = val;
  }

  void addToCart() {
    final CartController cartController = Get.find<CartController>();

    final cartItem = CartItem(
      id: product['id'],
      name: product['name'],
      vendorName: product['vendor'] ?? 'Unknown Vendor',
      price: product['price'].toDouble(),
      imageUrl: product['image'],
      quantity: quantity.value,
      isB2B: product['isB2B'] ?? false,
      size: selectedSize.value,
      color: selectedColor.value,
      isAiSizeMatched: predictedSize.value > 0,
    );

    cartController.addItem(cartItem);

    Get.toNamed('/cart');
    
    Get.snackbar(
      'Added to Cart',
      '${product['name']} has been added to your cart.',
      backgroundColor: AppColors.camel,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
