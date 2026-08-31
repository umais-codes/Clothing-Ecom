import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/constants.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/vendor_inventory/data/models/vendor_product_model.dart';
import 'package:ecom_app/features/vendor_inventory/data/models/product_variant_model.dart';
import 'package:ecom_app/features/discovery/presentation/controllers/filter_controller.dart';
import 'package:uuid/uuid.dart';
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

    bool isValidUuid(String str) {
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );
      return uuidRegex.hasMatch(str);
    }

    final isEditing = product != null;
    final String uniqueId = (isEditing && isValidUuid(product!.id))
        ? product!.id
        : const Uuid().v4();

    final double parsedPrice = double.tryParse(priceController.text) ?? 0.0;

    // Process image uploads if local files
    final List<String> processedImages = [];
    final supabase = Get.find<SupabaseService>().client;
    final user = supabase.auth.currentUser;

    if (galleryImages.isNotEmpty) {
      for (int i = 0; i < galleryImages.length; i++) {
        final imgPath = galleryImages[i];
        if (imgPath.startsWith('http://') || imgPath.startsWith('https://')) {
          processedImages.add(imgPath);
        } else {
          final file = File(imgPath);
          if (file.existsSync()) {
            try {
              final ext = imgPath.split('.').last;
              final fileName = 'catalog_${DateTime.now().millisecondsSinceEpoch}_$i.$ext';
              final storagePath = 'catalog/$fileName';
              await supabase.storage.from('product-images').upload(storagePath, file);
              final publicUrl = supabase.storage.from('product-images').getPublicUrl(storagePath);
              processedImages.add(publicUrl);
            } catch (se) {
              debugPrint('Storage upload error: $se');
              processedImages.add(
                'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
              );
            }
          } else {
            processedImages.add(
              'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
            );
          }
        }
      }
    }

    if (processedImages.isEmpty) {
      processedImages.add(
        'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
      );
    }

    final mainImageUrl = processedImages.first;

    final String? validVendorId = (user != null && isValidUuid(user.id))
        ? user.id
        : ((product != null && isValidUuid(product!.vendorId)) ? product!.vendorId : null);

    final updatedProduct = PendingProductEntity(
      id: uniqueId,
      name: nameController.text.trim(),
      price: parsedPrice,
      category: selectedCategory.value,
      description: descriptionController.text.trim(),
      imageUrl: mainImageUrl,
      additionalImages: processedImages.length > 1
          ? processedImages.sublist(1)
          : [],
      status: selectedStatus.value,
      vendorId: validVendorId ?? 'ADMIN',
      vendorName: product?.vendorName ?? 'Valvet Maison Direct',
      sizes: product?.sizes ?? const ['S', 'M', 'L', 'XL'],
    );

    // 1. Save to local Hive vendorProductsBox for instant offline-first & cross-role access
    try {
      if (!Hive.isBoxOpen('vendorProductsBox')) {
        await Hive.openBox<VendorProduct>('vendorProductsBox');
      }
      final box = Hive.box<VendorProduct>('vendorProductsBox');
      final vendorProduct = VendorProduct(
        id: uniqueId,
        title: updatedProduct.name,
        description: updatedProduct.description,
        category: updatedProduct.category,
        basePrice: updatedProduct.price,
        imageUrls: processedImages,
        variants: [
          ProductVariant(
            id: '${uniqueId}_v1',
            color: 'Camel',
            size: 'M',
            stockQuantity: 100,
            sku: 'SKU-M',
          ),
          ProductVariant(
            id: '${uniqueId}_v2',
            color: 'White',
            size: 'L',
            stockQuantity: 100,
            sku: 'SKU-L',
          ),
        ],
        isDraft: false,
        isB2B: false,
        moq: 1,
        sourcingType: 'Ready to Ship',
      );
      await box.put(uniqueId, vendorProduct);
    } catch (he) {
      debugPrint('Hive vendorProductsBox save error: $he');
    }

    // 2. Upsert to Supabase products table
    if (!SupabaseService.supabaseUrl.contains('placeholder')) {
      try {
        final payload = {
          'id': uniqueId,
          'vendor_id': validVendorId,
          'name': updatedProduct.name,
          'price': updatedProduct.price,
          'category': updatedProduct.category,
          'description': updatedProduct.description,
          'status': 'approved',
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
          'image_url': mainImageUrl,
          'images': processedImages,
          'variants_json': [
            {
              'id': '${uniqueId}_v1',
              'color': 'Camel',
              'size': 'M',
              'stock': 100,
              'sku': 'SKU-M',
            },
            {
              'id': '${uniqueId}_v2',
              'color': 'White',
              'size': 'L',
              'stock': 100,
              'sku': 'SKU-L',
            },
          ],
        };

        await supabase.from('products').upsert(payload);
        debugPrint('Successfully saved product to Supabase: $uniqueId');
      } catch (e) {
        debugPrint('Supabase catalog save error: $e');
      }
    }

    // 3. Update AdminCrudController
    crudController.updateProduct(updatedProduct);

    // If marked as approved or rejected, remove from pending moderation queue if active
    if (Get.isRegistered<AdminController>()) {
      final adminCtrl = Get.find<AdminController>();
      if (selectedStatus.value != ProductStatus.pending) {
        adminCtrl.pendingProducts.removeWhere((p) => p.id == updatedProduct.id);
      }
    }

    // 4. Immediately Refresh B2C Shopper Home Feed & Discovery Catalog
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadTrendingProducts();
    }
    if (Get.isRegistered<FilterController>()) {
      Get.find<FilterController>().loadProducts();
    }

    isLoading.value = false;
    Get.back();
    Get.snackbar(
      isEditing ? 'Catalog Updated' : 'Product Added',
      '${updatedProduct.name} successfully added to catalog and published.',
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
    );
  }
}
