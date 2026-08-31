import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/cart/domain/models/cart_item_model.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2c_cart_controller.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2b_cart_controller.dart';
import 'package:ecom_app/features/wishlist/domain/models/product_model.dart';
import 'package:get/get.dart';
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';

class PdpController extends GetxController {
  late final Map<String, dynamic> product;

  // Reviews states
  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingReviews = false.obs;
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      product = args;
    } else if (args is Product) {
      product = args.toMap();
    } else {
      product = {};
    }

    if (sizes.isNotEmpty) selectedSize.value = sizes.first;
    if (colors.isNotEmpty) selectedColor.value = colors.first;

    fetchReviews();
  }

  Future<void> fetchReviews() async {
    isLoadingReviews.value = true;
    try {
      final String? pid = product['id'];
      if (pid != null && pid.isNotEmpty) {
        final response = await _supabase
            .from('reviews')
            .select()
            .eq('product_id', pid)
            .order('created_at', ascending: false);
        reviews.assignAll(List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      debugPrint('Error fetching reviews from Supabase: $e');
    } finally {
      // Fallback/enrich with mock reviews ONLY for sample catalog items (b2c_1..b2c_10)
      if (reviews.isEmpty &&
          (product['id']?.toString().startsWith('b2c_') ?? false)) {
        reviews.assignAll(_getMockReviewsForProduct(product['id'] ?? ''));
      }
      isLoadingReviews.value = false;
    }
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    double sum = 0;
    for (var r in reviews) {
      final val = r['rating'];
      if (val is num) {
        sum += val.toDouble();
      }
    }
    return sum / reviews.length;
  }

  String get fitSummary {
    if (reviews.isEmpty) return 'No Fit Data';
    int trueToSize = 0;
    int runsSmall = 0;
    int runsLarge = 0;
    for (var r in reviews) {
      final f = r['fit_rating'];
      if (f is num) {
        final val = f.toDouble();
        if (val < 0.5) {
          runsSmall++;
        } else if (val > 1.5) {
          runsLarge++;
        } else {
          trueToSize++;
        }
      }
    }
    final total = reviews.length;
    if (total == 0) return 'No Fit Data';

    final pctTrue = ((trueToSize / total) * 100).round();
    final pctSmall = ((runsSmall / total) * 100).round();
    final pctLarge = ((runsLarge / total) * 100).round();

    if (pctTrue >= pctSmall && pctTrue >= pctLarge) {
      return '$pctTrue% say True to Size';
    } else if (pctSmall >= pctLarge) {
      return '$pctSmall% say Runs Small';
    } else {
      return '$pctLarge% say Runs Large';
    }
  }

  List<Map<String, dynamic>> _getMockReviewsForProduct(String id) {
    if (product['isB2B'] == true || !id.startsWith('b2c_')) {
      return []; // No fake reviews for vendor products or B2B items
    }

    final List<Map<String, dynamic>> baseReviews = [
      {
        'id': 'rev_1',
        'rating': 5.0,
        'fit_rating': 1.0,
        'review_text':
            'Exquisite quality fabric! The color is rich, and the detailing along the seams shows true craftsmanship. Fits exactly true to size, highly recommended.',
        'images': [
          'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
        ],
        'customer_name': 'Sophia L.',
        'variant_info': 'Size: M | Color: Sand',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
      {
        'id': 'rev_2',
        'rating': 4.0,
        'fit_rating': 1.0,
        'review_text':
            'Incredibly soft and comfortable to wear all day. Stretches nicely. Will definitely buy in other colors.',
        'images': [],
        'customer_name': 'Amara K.',
        'variant_info': 'Size: S | Color: Charcoal',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
      },
      {
        'id': 'rev_3',
        'rating': 5.0,
        'fit_rating': 2.0,
        'review_text':
            'Beautiful minimalist silhouette. Material feels heavy and drape is elegant. A classic piece for the wardrobe.',
        'images': [],
        'customer_name': 'James H.',
        'variant_info': 'Size: L | Color: Ivory',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 12))
            .toIso8601String(),
      },
    ];

    // Customize reviews content dynamically based on product IDs
    if (id == 'b2c_1') {
      baseReviews[0]['review_text'] =
          'This Tailored Linen Blazer is a masterpiece! Light enough for warm summer evenings but holds its structured shape beautifully. The camel color is stunning.';
      baseReviews[0]['variant_info'] = 'Size: M | Color: Camel';
      baseReviews[1]['review_text'] =
          'Amazing linen quality. It has a beautiful texture and relaxed vibe without looking sloppy. Perfect for upscale events.';
      baseReviews[1]['variant_info'] = 'Size: S | Color: Beige';
    } else if (id == 'b2c_2') {
      baseReviews[0]['review_text'] =
          'Absolutely beautiful silk abaya! The fabric is incredibly luxurious and light, draping perfectly. The embroidery on the cuffs is extremely fine.';
      baseReviews[0]['variant_info'] = 'Size: L | Color: Black';
      baseReviews[1]['review_text'] =
          'Highly recommend this abaya. Fabric quality is amazing and looks very elegant.';
      baseReviews[1]['variant_info'] = 'Size: M | Color: Navy';
    } else if (id == 'b2c_3') {
      baseReviews[0]['review_text'] =
          'These tailored cotton chinos are perfect. Super comfortable waist with just enough stretch for a full day of movement. Holds their crease well.';
      baseReviews[0]['variant_info'] = 'Size: M | Color: Beige';
    } else if (id == 'b2c_6') {
      baseReviews[0]['review_text'] =
          'This modest kurta is exceptionally crafted. The thread embroidery is beautiful and doesn\'t itch at all. Very breathable fabric.';
      baseReviews[0]['variant_info'] = 'Size: M | Color: White';
    } else if (id == 'b2c_8') {
      baseReviews[0]['review_text'] =
          'I love this ribbed knit dress! The organic wool is so soft on the skin and hugs the silhouette beautifully. Very warm and sophisticated.';
      baseReviews[0]['variant_info'] = 'Size: S | Color: Black';
    }

    return baseReviews;
  }

  final RxString selectedSize = 'M'.obs;
  final RxString selectedColor = 'Sand'.obs;
  final RxBool isSizePredictorExpanded = false.obs;
  final RxDouble predictedSize = 0.0.obs;
  final RxInt quantity = 1.obs;

  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final RxString recommendedSize = ''.obs;
  final RxBool isPredicting = false.obs;
  final RxString predictionDetails = ''.obs;
  List<String> get productImages {
    final List<String> imgs = [];
    if (product['images'] is List && (product['images'] as List).isNotEmpty) {
      for (var img in (product['images'] as List)) {
        if (img != null && img.toString().isNotEmpty) {
          imgs.add(img.toString());
        }
      }
    }
    if (imgs.isEmpty &&
        product['image_url'] != null &&
        product['image_url'].toString().isNotEmpty) {
      imgs.add(product['image_url'].toString());
    }
    if (imgs.isEmpty &&
        product['image'] != null &&
        product['image'].toString().isNotEmpty) {
      imgs.add(product['image'].toString());
    }
    if (imgs.isEmpty &&
        product['imageUrl'] != null &&
        product['imageUrl'].toString().isNotEmpty) {
      imgs.add(product['imageUrl'].toString());
    }
    if (imgs.isEmpty) {
      imgs.add(
        'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop',
      );
    }
    return imgs;
  }

  List<String> get sizes {
    final List<String> sList = List<String>.from(product['sizes'] ?? []);
    if (sList.isNotEmpty) return sList;

    final rawVariants = product['variants_json'];
    if (rawVariants is List && rawVariants.isNotEmpty) {
      final set = rawVariants
          .map((v) => v['size']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      if (set.isNotEmpty) return set;
    }
    return ['S', 'M', 'L', 'XL'];
  }

  List<String> get colors {
    final List<String> cList = List<String>.from(product['colors'] ?? []);
    if (cList.isNotEmpty) return cList;

    final rawVariants = product['variants_json'];
    if (rawVariants is List && rawVariants.isNotEmpty) {
      final set = rawVariants
          .map((v) => v['color']?.toString() ?? '')
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      if (set.isNotEmpty) return set;
    }
    return ['Camel', 'Beige', 'White', 'Black'];
  }

  String get description =>
      product['description'] ??
      "Experience pure luxury with this meticulously crafted piece. Designed for the modern individual who values both style and substance, this garment features premium fabrics and a silhouette that effortlessly transitions from day to night. Each detail has been carefully considered to ensure a perfect fit and unparalleled comfort.";

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void selectColor(String color) {
    selectedColor.value = color;
  }

  void toggleSizePredictor() {
    isSizePredictorExpanded.value = !isSizePredictorExpanded.value;
  }

  Future<void> runAIPrediction() async {
    isPredicting.value = true;
    predictionDetails.value = '';

    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        await Future.delayed(const Duration(milliseconds: 600));
        isPredicting.value = false;
        predictionDetails.value = 'Please log in to run AI size prediction.';
        return;
      }

      final profile = await _authRepository.getProfile(user.id);
      double? heightVal;
      double? weightVal;
      String? fitPref;

      if (profile != null) {
        if (profile['height'] != null) {
          heightVal = (profile['height'] as num).toDouble();
        }
        if (profile['weight'] != null) {
          weightVal = (profile['weight'] as num).toDouble();
        }
        fitPref = profile['fit_preference']?.toString();
      }

      final metadata = user.userMetadata;
      if (metadata != null) {
        if (heightVal == null && metadata['height'] != null) {
          heightVal = (metadata['height'] as num).toDouble();
        }
        if (weightVal == null && metadata['weight'] != null) {
          weightVal = (metadata['weight'] as num).toDouble();
        }
        if (fitPref == null && metadata['fit_preference'] != null) {
          fitPref = metadata['fit_preference'].toString();
        }
      }

      if (heightVal == null || weightVal == null) {
        await Future.delayed(const Duration(milliseconds: 600));
        isPredicting.value = false;
        predictionDetails.value =
            'Please calibrate your AI Fit Profile in your Account tab first.';
        return;
      }

      fitPref ??= 'Regular';
      final String cat = product['category']?.toString() ?? "Men's";

      final List<String> availableSizes = List<String>.from(
        product['sizes'] ?? ['S', 'M', 'L', 'XL'],
      );

      final recommended = _calculateSize(
        heightVal,
        weightVal,
        fitPref,
        cat,
        availableSizes,
      );

      await Future.delayed(const Duration(milliseconds: 800));
      isPredicting.value = false;
      recommendedSize.value = recommended;
      selectedSize.value = recommended;
      predictedSize.value = 1.0;
      predictionDetails.value =
          'Based on your AI Profile (${heightVal.round()}cm, ${weightVal.round()}kg, $fitPref fit).';
    } catch (e) {
      isPredicting.value = false;
      predictionDetails.value = 'Failed to calculate size: $e';
    }
  }

  String _calculateSize(
    double height,
    double weight,
    String fitPreference,
    String category,
    List<String> availableSizes,
  ) {
    if (availableSizes.isEmpty) return 'M';

    double bmi = weight / ((height / 100) * (height / 100));

    String recommended = 'M';
    if (bmi < 19.5) {
      recommended = 'S';
    } else if (bmi >= 19.5 && bmi < 24.5) {
      recommended = 'M';
    } else if (bmi >= 24.5 && bmi < 28.5) {
      recommended = 'L';
    } else {
      recommended = 'XL';
    }

    if (fitPreference.toLowerCase() == 'slim') {
      // stays standard
    } else if (fitPreference.toLowerCase() == 'relaxed') {
      if (recommended == 'S' && availableSizes.contains('M')) {
        recommended = 'M';
      } else if (recommended == 'M' && availableSizes.contains('L')) {
        recommended = 'L';
      } else if (recommended == 'L' && availableSizes.contains('XL')) {
        recommended = 'XL';
      }
    }

    if (availableSizes.contains(recommended)) {
      return recommended;
    }
    return availableSizes.isNotEmpty ? availableSizes.first : 'M';
  }

  void updateQuantity(int val) {
    if (val < 1) return;
    quantity.value = val;
  }

  void addToCart() {
    final bool isB2B = product['isB2B'] == true || product['is_b2b'] == true;
    final dynamic cartController = isB2B
        ? Get.find<B2BCartController>()
        : Get.find<B2CCartController>();

    final String pId = product['id']?.toString() ?? 'prod_${DateTime.now().millisecondsSinceEpoch}';
    final String variantId =
        "${pId}_${selectedSize.value}_${selectedColor.value}";

    final String pName = product['name'] ?? product['title'] ?? 'Luxury Apparel';
    final String pVendor = product['vendor'] ?? product['vendor_name'] ?? product['vendorName'] ?? 'Boutique Apparel';
    final double pPrice = (product['price'] as num?)?.toDouble() ?? 0.0;
    final String pImg = productImages.isNotEmpty
        ? productImages.first
        : 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop';

    final cartItem = CartItem(
      id: variantId,
      name: pName,
      vendorName: pVendor,
      price: pPrice,
      imageUrl: pImg,
      quantity: quantity.value,
      isB2B: isB2B,
      size: selectedSize.value,
      color: selectedColor.value,
      isAiSizeMatched: predictedSize.value > 0,
    );

    cartController.addItem(cartItem);

    Get.toNamed(isB2B ? '/b2b-cart' : '/cart');

    Get.snackbar(
      'Added to Cart',
      '$pName has been added to your cart.',
      backgroundColor: AppColors.camel,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
