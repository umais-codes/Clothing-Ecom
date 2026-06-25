import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Observables for instant UI updates
  final RxString userName = 'Eleanor Fitzgerald'.obs;
  final RxString userEmail = 'eleanor.fitz@example.com'.obs;
  final RxString userPhone = '+1 234 567 890'.obs;
  final RxString profileImagePath = ''.obs;

  // Fit Profile Metrics
  final RxString height = '175cm'.obs;
  final RxString weight = '62kg'.obs;
  final RxString fitPreference = 'Tailored Slim'.obs;

  // Settings Toggles
  final RxBool notificationsEnabled = true.obs;

  AuthRole get currentRole => _authController.selectedRole.value;

  String get roleBadgeText {
    switch (currentRole) {
      case AuthRole.shopper:
        return 'B2C Shopper';
      case AuthRole.corporate:
        return 'B2B Corporate Client';
      case AuthRole.vendor:
        return 'Vendor Partner';
      case AuthRole.admin:
        return 'admin';
    }
  }

  bool get showUniformAllowance => currentRole == AuthRole.corporate;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        userEmail.value = user.email ?? '';
        userPhone.value = user.phone ?? '';

        final metadata = user.userMetadata;
        if (metadata != null) {
          userName.value = metadata['full_name']?.toString() ?? userName.value;
          final avatarUrl = metadata['avatar_url']?.toString() ?? '';
          if (avatarUrl.isNotEmpty) {
            profileImagePath.value = avatarUrl;
          }
        }

        // Fetch custom profile metrics from Supabase DB via repository
        final data = await _authRepository.getProfile(user.id);
        if (data != null) {
          if (data['full_name'] != null) {
            userName.value = data['full_name'].toString();
          }
          if (data['height'] != null) {
            height.value =
                '${data['height'].toString().replaceAll('.0', '')}cm';
          } else {
            height.value = 'Not Set';
          }
          if (data['weight'] != null) {
            weight.value =
                '${data['weight'].toString().replaceAll('.0', '')}kg';
          } else {
            weight.value = 'Not Set';
          }
          if (data['fit_preference'] != null) {
            fitPreference.value = data['fit_preference'].toString();
          } else {
            fitPreference.value = 'Not Set';
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 500,
      );
      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void updateBodyMetrics() {
    final user = _authRepository.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'No user logged in.');
      return;
    }

    // Parse current values or use defaults
    double currentHeight =
        double.tryParse(height.value.replaceAll('cm', '')) ?? 170.0;
    double currentWeight =
        double.tryParse(weight.value.replaceAll('kg', '')) ?? 65.0;
    String currentFit = fitPreference.value == 'Not Set'
        ? 'Regular'
        : fitPreference.value;

    final tempHeight = currentHeight.obs;
    final tempWeight = currentWeight.obs;
    final tempFit = currentFit.obs;

    final fitOptions = ['Slim', 'Regular', 'Relaxed'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calibrate AI Fit Profile',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Height
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Height',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.camelLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tempHeight.value.round()} cm',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.camel,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(
                () => SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.camel,
                    inactiveTrackColor: AppColors.greyLight,
                    thumbColor: AppColors.camel,
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: tempHeight.value,
                    min: 140,
                    max: 210,
                    divisions: 70,
                    onChanged: (v) => tempHeight.value = v,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weight',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.camelLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tempWeight.value.round()} kg',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.camel,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(
                () => SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.camel,
                    inactiveTrackColor: AppColors.greyLight,
                    thumbColor: AppColors.camel,
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: tempWeight.value,
                    min: 35,
                    max: 150,
                    divisions: 115,
                    onChanged: (v) => tempWeight.value = v,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Preferred Fit
              const Text(
                'Preferred Fit',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  children: fitOptions.map((fit) {
                    final isSelected = tempFit.value == fit;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: fit != fitOptions.last ? 8.0 : 0,
                        ),
                        child: CustomButton(
                          text: fit,
                          variant: isSelected
                              ? ButtonVariant.primary
                              : ButtonVariant.secondary,
                          onPressed: () => tempFit.value = fit,
                          height: 40,
                          borderRadius: 8,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 25),
              CustomButton(
                text: 'Save Changes',
                onPressed: () async {
                  try {
                    Get.back(); // Close bottom sheet
                    Get.showOverlay(
                      asyncFunction: () async {
                        await _authRepository.updateBodyMetrics(
                          userId: user.id,
                          height: tempHeight.value,
                          weight: tempWeight.value,
                          fitPreference: tempFit.value,
                        );

                        // Update locally
                        height.value = '${tempHeight.value.round()}cm';
                        weight.value = '${tempWeight.value.round()}kg';
                        fitPreference.value = tempFit.value;

                        Get.snackbar(
                          'Success',
                          'Fit profile updated successfully.',
                          backgroundColor: const Color(0xFFFAF9F6),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      loadingWidget: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.camel,
                        ),
                      ),
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to update fit profile: $e',
                      backgroundColor: const Color(0xFFFAF9F6),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                width: double.infinity,
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> logout() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      debugPrint('Error signing out of Supabase: $e');
    }
    Get.offAllNamed('/onboarding');
  }
}
