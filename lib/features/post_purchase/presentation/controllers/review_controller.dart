import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';

class ReviewController extends GetxController {
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;
  final ImagePicker _picker = ImagePicker();

  // Review states
  final RxDouble rating = 0.0.obs;
  final RxDouble fitRating =
      1.0.obs; // 0.0: Runs Small, 1.0: True to Size, 2.0: Runs Large
  final TextEditingController reviewTextController = TextEditingController();
  final RxList<XFile> reviewImages = <XFile>[].obs;

  // Loading status
  final RxBool isLoading = false.obs;



  void setRating(double val) {
    rating.value = val;
  }

  void setFitRating(double val) {
    fitRating.value = val;
  }

  String get fitDescription {
    if (fitRating.value < 0.5) return 'Runs Small';
    if (fitRating.value > 1.5) return 'Runs Large';
    return 'True to Size';
  }

  String get ratingLabel {
    int score = rating.value.round();
    switch (score) {
      case 1:
        return 'Disappointed';
      case 2:
        return 'Fair';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Absolutely Love It!';
      default:
        return 'Select a rating';
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        imageQuality: 70,
        maxWidth: 1080,
        source: source,
      );
      if (pickedFile != null) {
        reviewImages.add(pickedFile);
      }
    } catch (e) {
      AppSnackbar.error(
        title: 'Upload Error',
        message: 'Failed to select image: $e',
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < reviewImages.length) {
      reviewImages.removeAt(index);
    }
  }

  Future<void> submitReview(String orderId, String productId) async {
    if (rating.value == 0.0) {
      AppSnackbar.warning(
        title: 'Rating Required',
        message: 'Please select at least 1 star to rate this product.',
      );
      return;
    }

    isLoading.value = true;
    final List<String> uploadedUrls = [];

    try {
      // 1. Upload review photos to Supabase Storage (product-reviews bucket)
      for (var imageFile in reviewImages) {
        final bytes = await imageFile.readAsBytes();
        final fileExt = imageFile.name.split('.').last;
        final fileName =
            'review_${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
        final filePath = 'reviews/$fileName';

        await _supabase.storage.from('product-reviews').uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
                upsert: true,
              ),
            );

        final publicUrl = _supabase.storage
            .from('product-reviews')
            .getPublicUrl(filePath);
        uploadedUrls.add(publicUrl);
      }

      // 2. Insert into Supabase reviews table
      await _supabase.from('reviews').insert({
        'order_id': orderId,
        'product_id': productId,
        'rating': rating.value,
        'fit_rating': fitRating.value,
        'review_text': reviewTextController.text.trim(),
        'image_urls': uploadedUrls,
        'created_at': DateTime.now().toIso8601String(),
      });

      isLoading.value = false;

      // 3. Show Celebration / Confetti Dialog
      Get.generalDialog(
        barrierDismissible: true,
        barrierLabel: 'Review Submitted',
        barrierColor: Colors.black54,
        pageBuilder: (context, anim1, anim2) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 70,
                    color: AppColors.camel,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thank You!',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your verified feedback helps our artisan community improve and guides future shoppers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // Dismiss Dialog
                      Get.back(); // Return to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.camel,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Orders',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionBuilder: (context, anim, _, child) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );

      // Reset form variables
      rating.value = 0.0;
      fitRating.value = 1.0;
      reviewTextController.clear();
      reviewImages.clear();
    } catch (e) {
      isLoading.value = false;
      AppSnackbar.error(
        title: 'Submission Failed',
        message: 'Could not submit review: $e',
      );
    }
  }
}
