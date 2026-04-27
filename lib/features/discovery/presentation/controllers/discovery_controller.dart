import 'package:get/get.dart';

class DiscoveryController extends GetxController {
  final List<String> departments = [
    "WOMEN'S FASHION",
    "MEN'S WEAR",
    "MODEST WEAR",
    "B2B UNIFORMS"
  ];

  final RxInt selectedDepartmentIndex = 0.obs;

  void selectDepartment(int index) {
    selectedDepartmentIndex.value = index;
    // Handle loading new data based on selected category...
  }

  // Filter state
  final RxDouble priceMin = 0.0.obs;
  final RxDouble priceMax = 500.0.obs;
  final RxList<String> selectedSizes = <String>[].obs;
  final RxList<String> selectedColors = <String>[].obs;

  void updatePriceRange(double min, double max) {
    priceMin.value = min;
    priceMax.value = max;
  }

  void toggleSize(String size) {
    if (selectedSizes.contains(size)) {
      selectedSizes.remove(size);
    } else {
      selectedSizes.add(size);
    }
  }

  void toggleColor(String color) {
    if (selectedColors.contains(color)) {
      selectedColors.remove(color);
    } else {
      selectedColors.add(color);
    }
  }
}
