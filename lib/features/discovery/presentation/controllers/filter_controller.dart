import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../wishlist/domain/models/product_model.dart';
import '../../domain/repositories/discovery_repository.dart';

class FilterController extends GetxController {
  final DiscoveryRepository _repository;

  FilterController(this._repository);

  // --- Real-time Search Text Controller ---
  late final TextEditingController searchController;
  final RxString searchQuery = ''.obs;
  Worker? _roleWorker;

  final RxString selectedCategory = ''.obs; // e.g. "Men's", "Women's"

  // sliderPriceRange updates in real-time (for smooth slider thumb and labels)
  final Rx<RangeValues> sliderPriceRange = const RangeValues(0.0, 500.0).obs;

  // filterPriceRange updates with debounce (used for actual grid filtering)
  final Rx<RangeValues> filterPriceRange = const RangeValues(0.0, 500.0).obs;

  final RxList<String> selectedSizes = <String>[].obs;
  final RxList<String> selectedColors = <String>[].obs;

  // --- B2B Specific Filter States ---
  final RxString selectedMoqOption = 'Any MOQ'
      .obs; // "Any MOQ", "< 50 pieces", "50 - 200 pieces", "> 200 pieces"
  final RxList<String> selectedSourcingTypes =
      <String>[].obs; // "Ready to Ship", "Private Label"
  final RxList<String> selectedLocations =
      <String>[].obs; // "Pakistan", "International"

  // --- Sorting State ---
  final RxString sortBy = 'Popularity'
      .obs; // "Popularity", "Price: Low to High", "Price: High to Low"

  // --- Data States ---
  final RxList<Product> allProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();

    // Bind search text controller to observable
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    // Debounce price slider updates to prevent lagging/jank during active drags
    debounce<RangeValues>(sliderPriceRange, (RangeValues values) {
      filterPriceRange.value = values;
    }, time: const Duration(milliseconds: 300));

    // Initial load
    loadProducts();

    // Re-load and clear filters when user toggles B2C shopper <-> B2B corporate roles
    final authController = Get.find<AuthController>();
    _roleWorker = ever(authController.selectedRole, (_) {
      clearAll();
      loadProducts();
    });
  }

  @override
  void onClose() {
    _roleWorker?.dispose();
    searchController.dispose();
    super.onClose();
  }

  // --- Load Products ---
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final bool isB2B =
          Get.find<AuthController>().selectedRole.value == AuthRole.corporate;
      final products = await _repository.getProducts(isB2B: isB2B);
      allProducts.assignAll(products);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load apparel products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Universal Filter Actions ---
  void selectCategory(String category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = ''; // Toggle off
    } else {
      selectedCategory.value = category;
    }
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

  // --- B2B Actions ---
  void setMoqOption(String option) {
    selectedMoqOption.value = option;
  }

  void toggleSourcingType(String type) {
    if (selectedSourcingTypes.contains(type)) {
      selectedSourcingTypes.remove(type);
    } else {
      selectedSourcingTypes.add(type);
    }
  }

  void toggleLocation(String location) {
    if (selectedLocations.contains(location)) {
      selectedLocations.remove(location);
    } else {
      selectedLocations.add(location);
    }
  }

  // --- Clearing Methods ---
  void clearAll() {
    searchController.clear();
    searchQuery.value = '';
    selectedCategory.value = '';
    sliderPriceRange.value = const RangeValues(0.0, 500.0);
    filterPriceRange.value = const RangeValues(0.0, 500.0);
    selectedSizes.clear();
    selectedColors.clear();
    selectedMoqOption.value = 'Any MOQ';
    selectedSourcingTypes.clear();
    selectedLocations.clear();
    sortBy.value = 'Popularity';
  }

  // --- Reactive Filtered Products List ---
  List<Product> get filteredProducts {
    var list = allProducts.toList();

    // 1. Search Query Filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.vendorName.toLowerCase().contains(query) ||
            p.description!.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Department Category Filter
    if (selectedCategory.value.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.category.toLowerCase() ==
                selectedCategory.value.toLowerCase(),
          )
          .toList();
    }

    // 3. Debounced Price Filter
    list = list.where((p) {
      return p.price >= filterPriceRange.value.start &&
          p.price <= filterPriceRange.value.end;
    }).toList();

    // 4. Sizes Swatch Filter
    if (selectedSizes.isNotEmpty) {
      list = list.where((p) {
        return p.sizes.any((size) => selectedSizes.contains(size));
      }).toList();
    }

    // 5. Colors Swatch Filter
    if (selectedColors.isNotEmpty) {
      list = list.where((p) {
        return p.colors.any((color) => selectedColors.contains(color));
      }).toList();
    }

    // 6. B2B Contextual Filters (applied only when AuthRole is corporate B2B)
    final bool isB2B =
        Get.find<AuthController>().selectedRole.value == AuthRole.corporate;
    if (isB2B) {
      // MOQ Filter
      if (selectedMoqOption.value != 'Any MOQ') {
        if (selectedMoqOption.value == '< 50 pieces') {
          list = list.where((p) => p.moq < 50).toList();
        } else if (selectedMoqOption.value == '50 - 200 pieces') {
          list = list.where((p) => p.moq >= 50 && p.moq <= 200).toList();
        } else if (selectedMoqOption.value == '> 200 pieces') {
          list = list.where((p) => p.moq > 200).toList();
        }
      }

      // Sourcing Type Filter (Ready to Ship vs Private Label)
      if (selectedSourcingTypes.isNotEmpty) {
        list = list
            .where((p) => selectedSourcingTypes.contains(p.sourcingType))
            .toList();
      }

      // Vendor Location Filter (Local vs International)
      if (selectedLocations.isNotEmpty) {
        list = list
            .where((p) => selectedLocations.contains(p.location))
            .toList();
      }
    }

    // 7. Sort Options
    if (sortBy.value == 'Price: Low to High') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy.value == 'Price: High to Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    }

    return list;
  }

  // --- Active Filter Representation List ---
  // Helper to compile a flat list of active filters for chip display
  List<ActiveFilterItem> get activeFiltersList {
    final List<ActiveFilterItem> items = [];

    if (selectedCategory.value.isNotEmpty) {
      items.add(
        ActiveFilterItem(type: 'category', label: selectedCategory.value),
      );
    }

    if (sliderPriceRange.value.start > 0.0 ||
        sliderPriceRange.value.end < 500.0) {
      final min = sliderPriceRange.value.start.toStringAsFixed(0);
      final max = sliderPriceRange.value.end.toStringAsFixed(0);
      items.add(ActiveFilterItem(type: 'price', label: '\$$min - \$$max'));
    }

    for (final size in selectedSizes) {
      items.add(
        ActiveFilterItem(type: 'size', value: size, label: 'Size: $size'),
      );
    }

    for (final color in selectedColors) {
      items.add(ActiveFilterItem(type: 'color', value: color, label: color));
    }

    final bool isB2B =
        Get.find<AuthController>().selectedRole.value == AuthRole.corporate;
    if (isB2B) {
      if (selectedMoqOption.value != 'Any MOQ') {
        items.add(
          ActiveFilterItem(
            type: 'moq',
            label: 'MOQ: ${selectedMoqOption.value}',
          ),
        );
      }

      for (final sourcing in selectedSourcingTypes) {
        items.add(
          ActiveFilterItem(type: 'sourcing', value: sourcing, label: sourcing),
        );
      }

      for (final loc in selectedLocations) {
        items.add(
          ActiveFilterItem(type: 'location', value: loc, label: 'Loc: $loc'),
        );
      }
    }

    return items;
  }

  void removeActiveFilter(ActiveFilterItem item) {
    switch (item.type) {
      case 'category':
        selectedCategory.value = '';
        break;
      case 'price':
        sliderPriceRange.value = const RangeValues(0.0, 500.0);
        break;
      case 'size':
        if (item.value != null) selectedSizes.remove(item.value);
        break;
      case 'color':
        if (item.value != null) selectedColors.remove(item.value);
        break;
      case 'moq':
        selectedMoqOption.value = 'Any MOQ';
        break;
      case 'sourcing':
        if (item.value != null) selectedSourcingTypes.remove(item.value);
        break;
      case 'location':
        if (item.value != null) selectedLocations.remove(item.value);
        break;
    }
  }
}

class ActiveFilterItem {
  final String type;
  final String? value;
  final String label;

  ActiveFilterItem({required this.type, this.value, required this.label});
}
