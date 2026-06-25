import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

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

  void loadUserProfile() {
    try {
      final user = _supabase.auth.currentUser;
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
    Get.snackbar(
      'Coming Soon',
      'Body metrics update feature is under development.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out of Supabase: $e');
    }
    Get.offAllNamed('/onboarding');
  }
}
