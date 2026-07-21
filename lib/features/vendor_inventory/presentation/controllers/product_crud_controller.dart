import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/constants.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
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
  final RxBool isB2B = false.obs;
  late final TextEditingController moqController;

  final RxList<ProductVariant> variants = <ProductVariant>[].obs;
  final RxList<String> imageUrls = <String>[].obs;

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
      isB2B.value = draft.isB2B;
      moqController.text = draft.moq.toString();
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
      isB2B: isB2B.value,
      moq: int.tryParse(moqController.text) ?? 1,
      sourcingType: isB2B.value ? 'Private Label' : 'Ready to Ship',
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

  final RxBool isUploadingImage = false.obs;

  Future<void> pickAndUploadProductImage() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        isUploadingImage.value = true;
        final supabase = Get.find<SupabaseService>().client;
        final user = supabase.auth.currentUser;
        final vendorId = user?.id ?? 'guest_vendor';

        for (var pickedFile in result.files) {
          if (pickedFile.path != null && File(pickedFile.path!).existsSync()) {
            final file = File(pickedFile.path!);
            final ext = pickedFile.extension ?? 'jpg';
            final fileName =
                'product_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 6)}.$ext';
            final storagePath = 'products/$vendorId/$fileName';

            String uploadedUrl = '';
            try {
              await supabase.storage.from('product-images').upload(storagePath, file);
              uploadedUrl = supabase.storage.from('product-images').getPublicUrl(storagePath);
            } catch (e1) {
              debugPrint('Uploading to product-images failed, trying rma-evidence: $e1');
              try {
                await supabase.storage.from('rma-evidence').upload(storagePath, file);
                uploadedUrl = supabase.storage.from('rma-evidence').getPublicUrl(storagePath);
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
        isB2B: isB2B.value,
        moq: int.tryParse(moqController.text) ?? 1,
        sourcingType: isB2B.value ? 'Private Label' : 'Ready to Ship',
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
    isB2B.value = false;
    moqController.text = '1';
    variants.clear();
    imageUrls.clear();
    await _repository.clearDraft();
  }
}
