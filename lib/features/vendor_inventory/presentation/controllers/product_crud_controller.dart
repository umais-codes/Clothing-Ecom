import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/constants.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/discovery/presentation/controllers/filter_controller.dart';
import 'package:ecom_app/features/home/presentation/controllers/home_controller.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../data/models/vendor_product_model.dart';
import '../../data/models/product_variant_model.dart';
import 'package:uuid/uuid.dart';

class ProductCrudController extends GetxController {
  final InventoryRepository _repository;

  ProductCrudController(this._repository);

  final RxList<VendorProduct> products = <VendorProduct>[].obs;
  final RxBool isLoading = false.obs;

  // Edit Mode & Search/Filter State
  final RxnString editingProductId = RxnString();
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryFilter = 'All'.obs;

  List<VendorProduct> get filteredProducts {
    return products.where((product) {
      final matchesSearch =
          searchQuery.value.isEmpty ||
          product.title.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          product.description.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );
      final matchesCategory =
          selectedCategoryFilter.value == 'All' ||
          product.category.toLowerCase() ==
              selectedCategoryFilter.value.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Form State
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  final RxString selectedCategory = "Men's".obs;
  late final TextEditingController basePriceController;
  final RxBool isB2B = false.obs;
  late final TextEditingController moqController;

  final RxList<ProductVariant> variants = <ProductVariant>[].obs;
  final RxList<String> imageUrls = <String>[].obs;

  // Form Size & Color Chips State
  final RxList<String> formSelectedColors = <String>[].obs;
  final RxList<String> formSelectedSizes = <String>[].obs;

  void toggleFormColor(String color) {
    if (formSelectedColors.contains(color)) {
      formSelectedColors.remove(color);
    } else {
      formSelectedColors.add(color);
    }
    generateVariantsFromSelection();
  }

  void addCustomColor(String color) {
    final trimmed = color.trim();
    if (trimmed.isNotEmpty && !formSelectedColors.contains(trimmed)) {
      formSelectedColors.add(trimmed);
      generateVariantsFromSelection();
    }
  }

  void toggleFormSize(String size) {
    if (formSelectedSizes.contains(size)) {
      formSelectedSizes.remove(size);
    } else {
      formSelectedSizes.add(size);
    }
    generateVariantsFromSelection();
  }

  void addCustomSize(String size) {
    final trimmed = size.trim().toUpperCase();
    if (trimmed.isNotEmpty && !formSelectedSizes.contains(trimmed)) {
      formSelectedSizes.add(trimmed);
      generateVariantsFromSelection();
    }
  }

  void generateVariantsFromSelection({int defaultStock = 50}) {
    if (formSelectedColors.isEmpty || formSelectedSizes.isEmpty) return;

    final titlePrefix = titleController.text.replaceAll(' ', '').toUpperCase();
    final prefix = titlePrefix.isNotEmpty ? titlePrefix : 'PROD';

    for (var c in formSelectedColors) {
      for (var s in formSelectedSizes) {
        final exists = variants.any(
          (v) =>
              v.color.toLowerCase() == c.toLowerCase() &&
              v.size.toLowerCase() == s.toLowerCase(),
        );
        if (!exists) {
          variants.add(
            ProductVariant(
              id: const Uuid().v4(),
              color: c,
              size: s,
              stockQuantity: defaultStock,
              sku: '$prefix-$c-$s',
            ),
          );
        }
      }
    }
    saveDraft();
  }

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    basePriceController = TextEditingController();
    moqController = TextEditingController(text: '1');

    _loadProducts();
    _loadDraft();
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
    if (draft != null && editingProductId.value == null) {
      if (titleController.text.isEmpty) titleController.text = draft.title;
      if (descriptionController.text.isEmpty) {
        descriptionController.text = draft.description;
      }
      if (draft.category.isNotEmpty) {
        selectedCategory.value =
            AppConstants.categories.contains(draft.category)
            ? draft.category
            : AppConstants.categories.first;
      }
      if (basePriceController.text.isEmpty) {
        basePriceController.text = draft.basePrice > 0
            ? draft.basePrice.toString()
            : '';
      }
      isB2B.value = draft.isB2B;
      moqController.text = draft.moq.toString();
      variants.assignAll(draft.variants);
      imageUrls.assignAll(draft.imageUrls);

      final colors = draft.variants
          .map((v) => v.color)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      final sizes = draft.variants
          .map((v) => v.size)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      if (colors.isNotEmpty) formSelectedColors.assignAll(colors);
      if (sizes.isNotEmpty) formSelectedSizes.assignAll(sizes);
    }
  }

  void editProduct(VendorProduct product) {
    editingProductId.value = product.id;
    titleController.text = product.title;
    descriptionController.text = product.description;
    selectedCategory.value = AppConstants.categories.contains(product.category)
        ? product.category
        : AppConstants.categories.first;
    basePriceController.text = product.basePrice.toString();
    isB2B.value = product.isB2B;
    moqController.text = product.moq.toString();
    variants.assignAll(product.variants);
    imageUrls.assignAll(product.imageUrls);

    final colors = product.variants
        .map((v) => v.color)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    final sizes = product.variants
        .map((v) => v.size)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    formSelectedColors.assignAll(colors);
    formSelectedSizes.assignAll(sizes);
  }

  void saveDraft() {
    if (editingProductId.value != null) return;
    final draft = VendorProduct(
      id: 'draft',
      title: titleController.text,
      description: descriptionController.text,
      category: selectedCategory.value,
      basePrice: double.tryParse(basePriceController.text) ?? 0.0,
      variants: variants.toList(),
      imageUrls: imageUrls.toList(),
      isDraft: true,
      isB2B: isB2B.value,
      moq: int.tryParse(moqController.text) ?? 1,
      sourcingType: isB2B.value ? 'Private Label' : 'Ready to Ship',
    );
    _repository.saveDraft(draft);
  }

  int get totalStockUnits =>
      variants.fold(0, (sum, v) => sum + v.stockQuantity);

  void updateVariantStock(String id, int newQty) {
    final idx = variants.indexWhere((v) => v.id == id);
    if (idx != -1) {
      variants[idx] = variants[idx].copyWith(
        stockQuantity: newQty.clamp(0, 99999),
      );
      variants.refresh();
      saveDraft();
    }
  }

  void bulkSetAllStock(int qty) {
    for (int i = 0; i < variants.length; i++) {
      variants[i] = variants[i].copyWith(stockQuantity: qty);
    }
    variants.refresh();
    saveDraft();
  }

  void updateVariantPrice(String id, double? newPrice) {
    final idx = variants.indexWhere((v) => v.id == id);
    if (idx != -1) {
      variants[idx] = variants[idx].copyWith(
        price: newPrice != null && newPrice > 0 ? newPrice : null,
      );
      variants.refresh();
      saveDraft();
    }
  }

  void addVariant(
    String color,
    String size,
    int stockQuantity, [
    double? price,
  ]) {
    final titlePrefix = titleController.text.replaceAll(' ', '').toUpperCase();
    final prefix = titlePrefix.isNotEmpty ? titlePrefix : 'PROD';
    variants.add(
      ProductVariant(
        id: const Uuid().v4(),
        color: color,
        size: size,
        stockQuantity: stockQuantity,
        sku: '$prefix-$color-$size',
        price: price,
      ),
    );
    saveDraft();
  }

  void removeVariant(String id) {
    variants.removeWhere((v) => v.id == id);
    saveDraft();
  }

  final RxBool isUploadingImage = false.obs;

  Future<void> pickAndUploadProductImage() async {
    try {
      final picker = ImagePicker();
      final List<XFile> result = await picker.pickMultiImage();

      if (result.isNotEmpty) {
        isUploadingImage.value = true;
        final supabase = Get.find<SupabaseService>().client;
        final user = supabase.auth.currentUser;
        final vendorId = user?.id ?? 'guest_vendor';

        for (var pickedFile in result) {
          final file = File(pickedFile.path);
          if (file.existsSync()) {
            final ext = pickedFile.path.split('.').last;
            final fileName =
                'product_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 6)}.$ext';
            final storagePath = 'products/$vendorId/$fileName';

            String uploadedUrl = '';
            try {
              await supabase.storage
                  .from('product-images')
                  .upload(storagePath, file);
              uploadedUrl = supabase.storage
                  .from('product-images')
                  .getPublicUrl(storagePath);
            } catch (e1) {
              debugPrint(
                'Uploading to product-images failed, trying rma-evidence: $e1',
              );
              try {
                await supabase.storage
                    .from('rma-evidence')
                    .upload(storagePath, file);
                uploadedUrl = supabase.storage
                    .from('rma-evidence')
                    .getPublicUrl(storagePath);
              } catch (e2) {
                debugPrint('Secondary storage upload failed: $e2');
              }
            }

            if (uploadedUrl.isNotEmpty) {
              imageUrls.add(uploadedUrl);
            }
          }
        }
        saveDraft();
      }
    } catch (e) {
      Get.snackbar('Upload Error', 'Failed to pick or upload image: $e');
    } finally {
      isUploadingImage.value = false;
    }
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
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Product Title is required');
      return false;
    }

    double? price = double.tryParse(basePriceController.text.trim());
    if (price == null || price <= 0) {
      // Auto-compute from lowest variant price
      final variantPrices = variants
          .map((v) => v.price)
          .whereType<double>()
          .where((p) => p > 0)
          .toList();
      if (variantPrices.isNotEmpty) {
        price = variantPrices.reduce((a, b) => a < b ? a : b);
      }
    }

    if (price == null || price <= 0) {
      Get.snackbar(
        'Pricing Required',
        'Please enter a Base Price or set price on at least one size variant.',
      );
      return false;
    }

    isLoading.value = true;
    try {
      final isEditing = editingProductId.value != null;
      final productId = editingProductId.value ?? const Uuid().v4();

      final product = VendorProduct(
        id: productId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory.value,
        basePrice: price,
        variants: variants.toList(),
        imageUrls: imageUrls.toList(),
        isDraft: false,
        isB2B: isB2B.value,
        moq: int.tryParse(moqController.text) ?? 1,
        sourcingType: isB2B.value ? 'Private Label' : 'Ready to Ship',
      );

      await _repository.saveProduct(product);

      if (isEditing) {
        final index = products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          products[index] = product;
        } else {
          products.add(product);
        }
      } else {
        products.add(product);
      }

      await clearForm();
      _notifyShopperViews();

      Get.back();
      Get.snackbar(
        'Success',
        isEditing
            ? 'Product updated successfully'
            : 'Product published successfully',
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
      _notifyShopperViews();
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }

  void _notifyShopperViews() {
    try {
      if (Get.isRegistered<FilterController>()) {
        Get.find<FilterController>().loadProducts();
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadTrendingProducts();
      }
    } catch (_) {}
  }

  Future<void> clearForm() async {
    editingProductId.value = null;
    titleController.clear();
    descriptionController.clear();
    selectedCategory.value = AppConstants.categories.first;
    basePriceController.clear();
    isB2B.value = false;
    moqController.text = '1';
    variants.clear();
    imageUrls.clear();
    await _repository.clearDraft();
  }
}
