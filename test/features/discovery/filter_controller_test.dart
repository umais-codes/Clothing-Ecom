// import 'package:flutter_test/flutter_test.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
// import 'package:ecom_app/features/discovery/presentation/controllers/filter_controller.dart';
// import 'package:ecom_app/features/discovery/data/repositories/discovery_repository_impl.dart';
// import 'package:ecom_app/features/discovery/domain/repositories/discovery_repository.dart';

// void main() {
//   // Ensure Flutter binding is initialized
//   TestWidgetsFlutterBinding.ensureInitialized();

//   late FilterController filterController;
//   late AuthController authController;

//   setUp(() {
//     // Put controllers and dependencies into GetX dependency injection container
//     Get.put(AuthController());
//     Get.put<DiscoveryRepository>(DiscoveryRepositoryImpl());
//     Get.put(FilterController(Get.find<DiscoveryRepository>()));

//     filterController = Get.find<FilterController>();
//     authController = Get.find<AuthController>();
//   });

//   tearDown(() {
//     // Clean up GetX container after each test
//     Get.reset();
//   });

//   test('Initial state loads B2C shopper products by default', () async {
//     expect(authController.selectedRole.value, AuthRole.shopper);
    
//     // Trigger products loading
//     await filterController.loadProducts();
    
//     expect(filterController.allProducts.isNotEmpty, true);
//     for (final product in filterController.allProducts) {
//       expect(product.isB2B, false);
//     }
//   });

//   test('Universal category filter narrows down items correctly', () async {
//     await filterController.loadProducts();
    
//     filterController.selectCategory("Women's");
//     expect(filterController.selectedCategory.value, "Women's");
    
//     final filtered = filterController.filteredProducts;
//     expect(filtered.isNotEmpty, true);
//     for (final product in filtered) {
//       expect(product.category, "Women's");
//     }
//   });

//   test('Universal size and color swatches combine correctly', () async {
//     await filterController.loadProducts();
    
//     filterController.toggleSize('M');
//     filterController.toggleColor('Camel');
    
//     expect(filterController.selectedSizes.contains('M'), true);
//     expect(filterController.selectedColors.contains('Camel'), true);
    
//     final filtered = filterController.filteredProducts;
//     for (final product in filtered) {
//       expect(product.sizes.contains('M'), true);
//       expect(product.colors.contains('Camel'), true);
//     }
//   });

//   test('Debounce worker coordinates price range slider state updates', () async {
//     await filterController.loadProducts();
    
//     // Change slider values (simulates user actively dragging range slider)
//     filterController.sliderPriceRange.value = const RangeValues(100.0, 200.0);
    
//     // Instantly updating in-memory UI bounds
//     expect(filterController.sliderPriceRange.value.start, 100.0);
    
//     // The filter target must still be the previous values (0.0, 500.0) due to 300ms debounce
//     expect(filterController.filterPriceRange.value.start, 0.0);
    
//     // Wait for the 300ms debounce duration
//     await Future.delayed(const Duration(milliseconds: 350));
    
//     // The filter range should now be updated to match the slider state
//     expect(filterController.filterPriceRange.value.start, 100.0);
//     expect(filterController.filterPriceRange.value.end, 200.0);
//   });

//   test('Switching AuthRole to B2B corporate dynamically swaps dataset and applies B2B filters', () async {
//     // Switch authentication role to corporate
//     authController.selectedRole.value = AuthRole.corporate;
    
//     // Wait for the GetX reactive worker to swap datasets and reset filters
//     await Future.delayed(const Duration(milliseconds: 200));
    
//     // Verify B2B product profiles loaded
//     expect(filterController.allProducts.isNotEmpty, true);
//     for (final product in filterController.allProducts) {
//       expect(product.isB2B, true);
//     }

//     // Apply B2B specific filter states
//     filterController.toggleSourcingType('Private Label');
//     filterController.toggleLocation('Pakistan');
//     filterController.setMoqOption('< 50 pieces');
    
//     final filtered = filterController.filteredProducts;
//     expect(filtered.isNotEmpty, true);
//     for (final product in filtered) {
//       expect(product.sourcingType, 'Private Label');
//       expect(product.location, 'Pakistan');
//       expect(product.moq < 50, true);
//     }
//   });

//   test('Live text search returns matching apparel products', () async {
//     await filterController.loadProducts();
    
//     // Set query value via text controller
//     filterController.searchController.text = 'Linen';
//     expect(filterController.searchQuery.value, 'Linen');
    
//     final filtered = filterController.filteredProducts;
//     expect(filtered.isNotEmpty, true);
//     for (final product in filtered) {
//       final nameMatch = product.name.toLowerCase().contains('linen');
//       final vendorMatch = product.vendorName.toLowerCase().contains('linen');
//       final descMatch = product.description.to().contains('linen');
//       expect(nameMatch || vendorMatch || descMatch, true);
//     }
//   });
// }
