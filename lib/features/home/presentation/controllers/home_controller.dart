import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/constants.dart';
import 'package:ecom_app/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:ecom_app/features/wishlist/domain/models/product_model.dart';

class HomeController extends GetxController {
  final DiscoveryRepository _discoveryRepository = Get.find<DiscoveryRepository>();

  final RxString selectedCategory = 'All'.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxList<Map<String, dynamic>> trendingProducts = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    loadTrendingProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  final List<String> categories = [
    'All',
    ...AppConstants.categories,
  ];

  Future<void> loadTrendingProducts() async {
    isLoading.value = true;
    try {
      final List<Product> list = await _discoveryRepository.getProducts(isB2B: false);
      final maps = list.map((p) => p.toMap()).toList();
      trendingProducts.assignAll(maps);
    } catch (e) {
      debugPrint('Error loading trending products on home screen: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> list = trendingProducts;

    // 1. Filter by category
    if (selectedCategory.value != 'All') {
      list = list
          .where((p) => p['category'].toString().toLowerCase() == selectedCategory.value.toLowerCase())
          .toList();
    }

    // 2. Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((p) {
        final name = p['name'].toString().toLowerCase();
        final category = p['category'].toString().toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
    }

    return list;
  }
}
