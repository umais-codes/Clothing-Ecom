import 'package:get/get.dart';

class PdpController extends GetxController {
  final product = Get.arguments as Map<String, dynamic>;

  final RxString selectedSize = 'M'.obs;
  final RxString selectedColor = 'Sand'.obs;
  final RxBool isSizePredictorExpanded = false.obs;
  final RxDouble predictedSize = 0.0.obs;

  final List<String> sizes = ['S', 'M', 'L', 'XL'];
  final List<String> colors = ['Sand', 'Charcoal', 'Ivory'];

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
}
