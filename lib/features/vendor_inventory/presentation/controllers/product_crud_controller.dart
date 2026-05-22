import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/constants.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../data/models/vendor_product_model.dart';
import '../../data/models/product_variant_model.dart';
import 'package:uuid/uuid.dart';

class ProductCrudController extends GetxController {
  final InventoryRepository _repository;

  ProductCrudController(this._repository);

  final RxList<VendorProduct> products = <VendorProduct>[].obs;
  final RxBool isLoading = false.obs;

  // Form State
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final RxString selectedCategory = "Men's".obs;
  late final TextEditingController basePriceController;

  final RxList<ProductVariant> variants = <ProductVariant>[].obs;
  final RxList<String> imageUrls = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    basePriceController = TextEditingController();

    _loadProducts();
    _loadDraft();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    basePriceController.dispose();
    super.onClose();
  }

  Future<void> refreshProducts() async {
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    isLoading.value = true;
    try {
      final items = await _repository.getProducts();
      products.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDraft() async {
    final draft = await _repository.getDraft();
    if (draft != null) {
      if (titleController.text.isEmpty) titleController.text = draft.title;
      if (descriptionController.text.isEmpty) {
        descriptionController.text = draft.description;
      }
      if (draft.category.isNotEmpty) {
        selectedCategory.value = AppConstants.categories.contains(draft.category)
            ? draft.category
            : AppConstants.categories.first;
      }
      if (basePriceController.text.isEmpty) {
        basePriceController.text =
            draft.basePrice > 0 ? draft.basePrice.toString() : '';
      }
      variants.assignAll(draft.variants);
      imageUrls.assignAll(draft.imageUrls);
    }
  }

  void saveDraft() {
    final draft = VendorProduct(
      id: 'draft',
      title: titleController.text,
      description: descriptionController.text,
      category: selectedCategory.value,
      basePrice: double.tryParse(basePriceController.text) ?? 0.0,
      variants: variants.toList(),
      imageUrls: imageUrls.toList(),
      isDraft: true,
    );
    _repository.saveDraft(draft);
  }

  void addVariant(String color, String size, int stockQuantity) {
    variants.add(
      ProductVariant(
        id: const Uuid().v4(),
        color: color,
        size: size,
        stockQuantity: stockQuantity,
        sku:
            '${titleController.text.replaceAll(' ', '').toUpperCase()}-$color-$size',
      ),
    );
    saveDraft();
  }

  void removeVariant(String id) {
    variants.removeWhere((v) => v.id == id);
    saveDraft();
  }

  void addImage(String url) {
    imageUrls.add(url);
    saveDraft();
  }

  void removeImage(String url) {
    imageUrls.remove(url);
    saveDraft();
  }

  Future<bool> saveProduct() async {
    if (titleController.text.isEmpty || basePriceController.text.isEmpty) {
      Get.snackbar('Error', 'Title and Base Price are required');
      return false;
    }

    final price = double.tryParse(basePriceController.text);
    if (price == null || price <= 0) {
      Get.snackbar('Error', 'Invalid price format');
      return false;
    }

    isLoading.value = true;
    try {
      final product = VendorProduct(
        id: const Uuid().v4(),
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory.value,
        basePrice: price,
        variants: variants.toList(),
        imageUrls: imageUrls.toList(),
        isDraft: false,
      );

      await _repository.saveProduct(product);
      products.add(product);

      // Clear form and draft
      await clearForm();

      Get.back();
      Get.snackbar('Success', 'Product saved successfully');
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    products.removeWhere((p) => p.id == id);
  }

  Future<void> clearForm() async {
    titleController.clear();
    descriptionController.clear();
    selectedCategory.value = AppConstants.categories.first;
    basePriceController.clear();
    variants.clear();
    imageUrls.clear();
    await _repository.clearDraft();
  }
}
