import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/constants.dart';

class HomeController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
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

  final List<Map<String, dynamic>> trendingProducts = [
    {
      'id': '1',
      'name': 'Silk Abaya with Gold Embroidery',
      'price': 1250.00,
      'category': 'Modest Wear',
      'image':
          'https://images.unsplash.com/photo-1583391733956-6c78276477e2?q=80&w=1000&auto=format&fit=crop',
      'isNew': true,
    },
    {
      'id': '2',
      'name': 'Bespoke Executive Suit',
      'price': 4500.00,
      'category': "Men's",
      'image':
          'https://images.unsplash.com/photo-1594932224011-042041c6f9fa?q=80&w=1000&auto=format&fit=crop',
      'isNew': false,
    },
    {
      'id': '3',
      'name': 'Corporate Aviation Uniform',
      'price': 850.00,
      'category': 'Workwear',
      'image':
          'https://images.unsplash.com/photo-1562147138-b193f538562d?q=80&w=1000&auto=format&fit=crop',
      'isNew': true,
    },
    {
      'id': '4',
      'name': 'Premium Cashmere Scarf',
      'price': 220.00,
      'category': 'Accessories',
      'image':
          'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?q=80&w=1000&auto=format&fit=crop',
      'isNew': false,
    },
  ];

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
