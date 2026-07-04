import 'dart:io';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Observables for instant UI updates
  final RxString userName = 'Eleanor Fitzgerald'.obs;
  final RxString userEmail = 'eleanor.fitz@example.com'.obs;
  final RxString userPhone = '+1 234 567 890'.obs;
  final RxString profileImagePath = ''.obs;
  final RxBool isSaving = false.obs;

  // Vendor specific observables
  final RxString brandName = ''.obs;
  final RxString kycStatus = 'pending'.obs;

  // Corporate specific observables
  final RxString companyNtn = ''.obs;
  final RxString employeeVolume = ''.obs;

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

    // Automatically reload profile info when login status succeeds
    ever(_authController.status, (status) {
      if (status == AuthStatus.success) {
        loadUserProfile();
      }
    });
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
          final phoneVal = metadata['phone']?.toString() ?? '';
          if (phoneVal.isNotEmpty) {
            userPhone.value = phoneVal;
          }
          if (metadata['height'] != null) {
            height.value = '${metadata['height'].toString().replaceAll('.0', '')}cm';
          }
          if (metadata['weight'] != null) {
            weight.value = '${metadata['weight'].toString().replaceAll('.0', '')}kg';
          }
          if (metadata['fit_preference'] != null) {
            fitPreference.value = metadata['fit_preference'].toString();
          }
        }

        // Fetch custom profile metrics from Supabase DB via repository
        final data = await _authRepository.getProfile(user.id);
        if (data != null) {
          if (data['full_name'] != null) {
            userName.value = data['full_name'].toString();
          }
          try {
            if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
              userPhone.value = data['phone'].toString();
            }
            if (data['avatar_url'] != null &&
                data['avatar_url'].toString().isNotEmpty) {
              profileImagePath.value = data['avatar_url'].toString();
            }
          } catch (_) {}
          if (data['height'] != null) {
            height.value = '${data['height'].toString().replaceAll('.0', '')}cm';
          }
          if (data['weight'] != null) {
            weight.value = '${data['weight'].toString().replaceAll('.0', '')}kg';
          }
          if (data['fit_preference'] != null) {
            fitPreference.value = data['fit_preference'].toString();
          }
        }

        // Fetch role-specific vendor / corporate data
        if (currentRole == AuthRole.vendor) {
          try {
            final supabase = Get.find<SupabaseService>().client;
            final vendorRes = await supabase
                .from('vendors')
                .select()
                .eq('owner_id', user.id)
                .maybeSingle();
            if (vendorRes != null) {
              brandName.value = vendorRes['brand_name']?.toString() ?? '';
              kycStatus.value = vendorRes['kyc_status']?.toString() ?? 'pending';
            }
          } catch (e) {
            debugPrint('Failed to load vendor details: $e');
          }
        } else if (currentRole == AuthRole.corporate) {
          final box = Hive.box('settings');
          companyNtn.value = box.get('corporate_ntn', defaultValue: 'NTN-8762541-0') as String;
          employeeVolume.value = box.get('corporate_volume', defaultValue: '51-200 Employees') as String;
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
        padding: EdgeInsets.all(MediaQuery.of(Get.context!).size.width * 0.05),
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
                  Text(
                    'Calibrate AI Fit Profile',
                    style: GoogleFonts.outfit(
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
              SizedBox(height: MediaQuery.of(Get.context!).size.width * 0.02),
              // Height
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Height',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            MediaQuery.of(Get.context!).size.width * 0.02,
                        vertical: MediaQuery.of(Get.context!).size.width * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.camelLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tempHeight.value.round()} cm',
                        style: GoogleFonts.outfit(
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
                    trackHeight: 2,
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
              SizedBox(height: MediaQuery.of(Get.context!).size.width * 0.02),
              // Weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weight',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            MediaQuery.of(Get.context!).size.width * 0.02,
                        vertical: MediaQuery.of(Get.context!).size.width * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.camelLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tempWeight.value.round()} kg',
                        style: GoogleFonts.outfit(
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
                    trackHeight: 2,
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
              SizedBox(height: MediaQuery.of(Get.context!).size.width * 0.02),
              // Preferred Fit
              Text(
                'Preferred Fit',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              SizedBox(height: MediaQuery.of(Get.context!).size.width * 0.02),
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
              SizedBox(height: MediaQuery.of(Get.context!).size.width * 0.05),
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
              SizedBox(height: MediaQuery.of(Get.context!).size.width * 0.02),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> saveProfileChanges({
    required String name,
    required String email,
    required String phone,
    String? brandName,
    String? ntn,
  }) async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) return;

      isSaving.value = true;

      String? uploadedAvatarUrl;
      final localPath = profileImagePath.value;

      if (localPath.isNotEmpty && !localPath.startsWith('http')) {
        final file = File(localPath);
        try {
          uploadedAvatarUrl = await _authRepository.uploadAvatar(
            userId: user.id,
            file: file,
          );
        } catch (e) {
          debugPrint('Failed to upload avatar to Supabase: $e');
        }
      }

      await _authRepository.updateProfileDetails(
        userId: user.id,
        fullName: name,
        phone: phone,
        avatarUrl: uploadedAvatarUrl,
      );

      userName.value = name;
      userEmail.value = email;
      userPhone.value = phone;
      if (uploadedAvatarUrl != null) {
        profileImagePath.value = uploadedAvatarUrl;
      }

      // Save role-specific details
      if (currentRole == AuthRole.vendor && brandName != null && brandName.isNotEmpty) {
        try {
          final supabase = Get.find<SupabaseService>().client;
          await supabase.from('vendors').update({
            'brand_name': brandName,
          }).eq('owner_id', user.id);
          this.brandName.value = brandName;
        } catch (e) {
          debugPrint('Failed to update brand name in Supabase: $e');
        }
      } else if (currentRole == AuthRole.corporate && ntn != null) {
        final box = Hive.box('settings');
        box.put('corporate_ntn', ntn);
        companyNtn.value = ntn;
      }
    } catch (e) {
      debugPrint('Error saving profile changes: $e');
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  void _resetProfileData() {
    userName.value = 'Eleanor Fitzgerald';
    userEmail.value = 'eleanor.fitz@example.com';
    userPhone.value = '+1 234 567 890';
    profileImagePath.value = '';
    height.value = '175cm';
    weight.value = '62kg';
    fitPreference.value = 'Tailored Slim';
    brandName.value = '';
    kycStatus.value = 'pending';
    companyNtn.value = '';
    employeeVolume.value = '';
  }

  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      _resetProfileData();
    } catch (e) {
      debugPrint('Error signing out of Supabase: $e');
    }
    Get.offAllNamed('/onboarding');
  }
}
