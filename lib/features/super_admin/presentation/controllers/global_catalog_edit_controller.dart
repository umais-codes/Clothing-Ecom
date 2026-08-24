import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/constants.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import '../../domain/entities/admin_entities.dart';
import 'admin_crud_controller.dart';
import 'admin_controller.dart';
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class GlobalCatalogEditController extends GetxController {
  final PendingProductEntity? product;
  final AdminCrudController crudController = Get.find<AdminCrudController>();

  GlobalCatalogEditController({this.product});

  late TextEditingController nameController;
  late TextEditingController priceController;
  final RxString selectedCategory = "Men's".obs;
  final Rx<ProductStatus> selectedStatus = ProductStatus.approved.obs;
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
    selectedStatus.value = product?.status ?? ProductStatus.approved;
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

  Future<void> addImage() async {
    if (isPickingImage.value) return;

    if (galleryImages.length >= 5) {
      Get.snackbar(
        'Limit Reached',
        'You can only add up to 5 images.',
        backgroundColor: AppColors.warning,
        colorText: AppColors.white,
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
    final context = Get.context;
    if (context == null) {
      _initializeFields();
      return;
    }

    CustomPermissionDialog.show(
      context: context,
      icon: Icons.restore_rounded,
      title: 'Discard Changes?',
      description: 'Are you sure you want to revert all changes?',
      grantText: 'Discard',
      denyText: 'Cancel',
      onGrant: () {
        _initializeFields();
      },
    );
  }

  Future<void> saveProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Required fields are missing.',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    isLoading.value = true;

    final isEditing = product != null;
    final String uniqueId = skuController.text.trim().isNotEmpty
        ? skuController.text.trim()
        : (isEditing
              ? product!.id
              : 'PRD-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}');

    final updatedProduct = PendingProductEntity(
      id: uniqueId,
      name: nameController.text.trim(),
      price: double.tryParse(priceController.text) ?? 0.0,
      category: selectedCategory.value,
      description: descriptionController.text.trim(),
      imageUrl: galleryImages.isNotEmpty ? galleryImages.first : '',
      additionalImages: galleryImages.length > 1
          ? galleryImages.sublist(1)
          : [],
      status: selectedStatus.value,
      vendorId: product?.vendorId ?? 'ADMIN',
      vendorName: product?.vendorName ?? 'Internal Brand',
      sizes: product?.sizes ?? const ['Standard'],
    );

    if (!SupabaseService.supabaseUrl.contains('placeholder')) {
      try {
        final supabase = Get.find<SupabaseService>().client;
        final payload = {
          'id': updatedProduct.id,
          'name': updatedProduct.name,
          'price': updatedProduct.price,
          'category': updatedProduct.category,
          'description': updatedProduct.description,
          'status': selectedStatus.value.name,
          'vendor_name': updatedProduct.vendorName,
          'in_stock': true,
          'is_b2b': false,
          'is_new': true,
          'moq': 1,
          'sourcing_type': 'Ready to Ship',
          'location': 'Pakistan',
          'sizes': updatedProduct.sizes.isNotEmpty
              ? updatedProduct.sizes
              : const ['S', 'M', 'L', 'XL'],
          'colors': const ['Camel', 'Ink', 'White'],
          if (updatedProduct.imageUrl.isNotEmpty)
            'image_url': updatedProduct.imageUrl,
          'images': galleryImages,
        };

        if (isEditing) {
          await supabase
              .from('products')
              .update(payload)
              .eq('id', updatedProduct.id);
        } else {
          await supabase.from('products').insert(payload);
        }
      } catch (e) {
        debugPrint('Supabase catalog save error: $e');
      }
    }

    crudController.updateProduct(updatedProduct);

    // If marked as approved or rejected, remove from pending moderation queue if active
    if (Get.isRegistered<AdminController>()) {
      final adminCtrl = Get.find<AdminController>();
      if (selectedStatus.value != ProductStatus.pending) {
        adminCtrl.pendingProducts.removeWhere((p) => p.id == updatedProduct.id);
      }
    }

    // Refresh B2C Shopper Home Feed
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadTrendingProducts();
    }

    isLoading.value = false;
    Get.back();
    Get.snackbar(
      isEditing ? 'Catalog Updated' : 'Product Added',
      '${updatedProduct.name} successfully ${isEditing ? 'updated' : 'added to catalog'}.',
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
    );
  }
}
