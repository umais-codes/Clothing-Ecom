import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/constants.dart';
import '../../domain/entities/admin_entities.dart';
import 'admin_crud_controller.dart';

class GlobalCatalogEditController extends GetxController {
  final PendingProductEntity? product;
  final AdminCrudController crudController = Get.find<AdminCrudController>();

  GlobalCatalogEditController({this.product});

  late TextEditingController nameController;
  late TextEditingController priceController;
  final RxString selectedCategory = "Men's".obs;
  late TextEditingController descriptionController;
  late TextEditingController skuController;

  final RxList<String> galleryImages = <String>[].obs;
  final RxBool isPickingImage = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFields();
  }

  void _initializeFields() {
    nameController = TextEditingController(text: product?.name ?? '');
    priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final String initialCat = product?.category ?? '';
    selectedCategory.value = AppConstants.categories.contains(initialCat)
        ? initialCat
        : AppConstants.categories.first;
    descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    skuController = TextEditingController(text: product?.id ?? '');

    galleryImages.clear();
    if (product?.imageUrl != null && product!.imageUrl.isNotEmpty) {
      galleryImages.add(product!.imageUrl);
    }
    if (product?.additionalImages != null) {
      galleryImages.addAll(product!.additionalImages);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    skuController.dispose();
    super.onClose();
  }

  Future<void> addImage() async {
    if (isPickingImage.value) return;

    if (galleryImages.length >= 5) {
      Get.snackbar(
        'Limit Reached',
        'You can only add up to 5 images.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isPickingImage.value = true;
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        galleryImages.add(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      isPickingImage.value = false;
    }
  }

  void removeImage(int index) {
    galleryImages.removeAt(index);
  }

  void discardChanges() {
    Get.dialog(
      AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to revert all changes?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              _initializeFields();
              Get.back();
            },
            child: const Text(
              'DISCARD',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void saveProduct() {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Required fields are missing.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final updatedProduct = PendingProductEntity(
      id: skuController.text.isEmpty ? 'AUTO-GEN' : skuController.text,
      name: nameController.text,
      price: double.tryParse(priceController.text) ?? 0.0,
      category: selectedCategory.value,
      description: descriptionController.text,
      imageUrl: galleryImages.isNotEmpty ? galleryImages.first : '',
      additionalImages: galleryImages.length > 1
          ? galleryImages.sublist(1)
          : [],
      status: product?.status ?? ProductStatus.pending,
      vendorId: product?.vendorId ?? 'ADMIN',
      vendorName: product?.vendorName ?? 'Internal',
      sizes: product?.sizes ?? [],
    );

    crudController.updateProduct(updatedProduct);
    Get.back();
    Get.snackbar(
      'Success',
      'Catalog audit updated successfully.',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }
}
