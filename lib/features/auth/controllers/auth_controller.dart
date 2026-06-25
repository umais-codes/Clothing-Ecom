import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:uuid/uuid.dart';

enum AuthRole { shopper, vendor, corporate, admin }

enum AuthStatus { initial, loading, success, pendingApproval, error }

class AuthController extends GetxController {
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;
  final Uuid uuid = const Uuid();

  final Rx<AuthRole> selectedRole = AuthRole.shopper.obs;

  final Rx<AuthStatus> status = AuthStatus.initial.obs;
  final RxString errorMessage = ''.obs;

  final RxBool isVendorLogin = false.obs;
  final RxBool isCorporateLogin = false.obs;

  // --- Shopper Controllers ---
  final TextEditingController shopperPhoneController = TextEditingController();
  final TextEditingController shopperOtpController = TextEditingController();
  final RxBool showShopperOtpField = false.obs;

  // --- Vendor Controllers ---
  final TextEditingController vendorEmailController = TextEditingController();
  final TextEditingController vendorPasswordController =
      TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final RxString selectedVendorCategory = "Men's".obs;
  final RxBool hasCnicUploaded = false.obs;
  final RxString cnicFileName = ''.obs;
  final RxBool hasSecpUploaded = false.obs;
  final RxString secpFileName = ''.obs;

  // --- Corporate Controllers ---
  final TextEditingController corporateEmailController =
      TextEditingController();
  final TextEditingController corporatePasswordController =
      TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController ntnController = TextEditingController();
  final RxString selectedVolume = '1-50 Employees'.obs;
  final List<String> volumeOptions = [
    '1-50 Employees',
    '51-200 Employees',
    '201-500 Employees',
    '500+ Employees',
  ];

  void setRole(AuthRole role) {
    selectedRole.value = role;
    status.value = AuthStatus.initial;
  }

  Future<void> _createProfile(
    String userId,
    String role, {
    String? fullName,
    String? vendorId,
  }) async {
    double? heightVal;
    double? weightVal;
    String? fitPreferenceVal;
    List<String>? categoriesVal;

    if (Get.isRegistered<OnboardingController>()) {
      final onboarding = Get.find<OnboardingController>();
      if (onboarding.hasPersonalized.value) {
        heightVal = onboarding.height.value;
        weightVal = onboarding.weight.value;
        fitPreferenceVal = onboarding.selectedFit.value;
        categoriesVal = onboarding.selectedCategories.toList();
      }
    }

    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'full_name': fullName ?? 'User',
        'role': role,
        'vendor_id': vendorId,
        'height': heightVal,
        'weight': weightVal,
        'fit_preference': fitPreferenceVal,
        'shopping_categories': categoriesVal,
      });
    } catch (e) {
      debugPrint('Error creating profile: $e');
    }
  }

  // Shopper Actions
  Future<void> sendShopperOtp() async {
    if (shopperPhoneController.text.length < 10) {
      _showError('Please enter a valid mobile number.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      await _supabase.auth.signInWithOtp(
        phone: shopperPhoneController.text.trim(),
      );
      status.value = AuthStatus.initial;
      showShopperOtpField.value = true;
    } catch (e) {
      _showError('Failed to send OTP: $e');
    }
  }

  Future<void> verifyShopperOtp() async {
    if (shopperOtpController.text.length < 6) {
      _showError('Please enter the 6-digit OTP.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      final res = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: shopperOtpController.text.trim(),
        phone: shopperPhoneController.text.trim(),
      );
      if (res.user != null) {
        await _createProfile(res.user!.id, 'shopper', fullName: 'Shopper User');
        status.value = AuthStatus.success;
        selectedRole.value = AuthRole.shopper;
        Get.offAllNamed('/main-navigation');
      } else {
        _showError('Invalid OTP code.');
      }
    } catch (e) {
      _showError('OTP verification failed: $e');
    }
  }

  void continueWithSocial(String provider) async {
    status.value = AuthStatus.loading;
    try {
      if (provider.toLowerCase() == 'google') {
        try {
          // Native Google Sign-In Setup (can be customized via environment defines)
          const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
          const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

          final GoogleSignIn googleSignIn = GoogleSignIn(
            clientId: iosClientId.isNotEmpty ? iosClientId : null,
            serverClientId: webClientId.isNotEmpty ? webClientId : null,
          );

          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            status.value = AuthStatus.initial;
            return; // User canceled the native sign-in dialog
          }

          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final idToken = googleAuth.idToken;
          final accessToken = googleAuth.accessToken;

          if (idToken == null) {
            throw 'Google Sign-In succeeded but did not return an ID Token.';
          }

          final response = await _supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

          if (response.user != null) {
            await _createProfile(
              response.user!.id,
              'shopper',
              fullName:
                  response.user!.userMetadata?['full_name'] ??
                  googleUser.displayName,
            );
            status.value = AuthStatus.success;
            selectedRole.value = AuthRole.shopper;
            Get.offAllNamed('/main-navigation');
            return;
          }
        } catch (nativeError) {
          debugPrint(
            'Native Google Sign-In failed or was unconfigured, falling back to Web OAuth: $nativeError',
          );
        }
      }

      OAuthProvider oauthProvider;
      if (provider.toLowerCase() == 'google') {
        oauthProvider = OAuthProvider.google;
      } else if (provider.toLowerCase() == 'apple') {
        oauthProvider = OAuthProvider.apple;
      } else {
        throw 'Unsupported provider';
      }

      // Web-based OAuth Redirect fallback
      await _supabase.auth.signInWithOAuth(
        oauthProvider,
        redirectTo: 'io.supabase.ecomapp://login-callback',
      );
    } catch (e) {
      _showError('Social sign in failed: $e');
    }
  }

  // Vendor Actions
  Future<void> pickCnicDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        cnicFileName.value = result.files.first.name;
        hasCnicUploaded.value = true;
      }
    } catch (e) {
      _showError('Failed to pick document: $e');
    }
  }

  Future<void> pickSecpDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        secpFileName.value = result.files.first.name;
        hasSecpUploaded.value = true;
      }
    } catch (e) {
      _showError('Failed to pick document: $e');
    }
  }

  Future<void> registerVendor() async {
    if (brandNameController.text.isEmpty ||
        vendorEmailController.text.isEmpty ||
        vendorPasswordController.text.isEmpty) {
      _showError('Please complete all required fields.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      final response = await _supabase.auth.signUp(
        email: vendorEmailController.text.trim(),
        password: vendorPasswordController.text.trim(),
      );

      if (response.user != null) {
        final vendorId = uuid.v4();

        await _supabase.from('vendors').insert({
          'id': vendorId,
          'brand_name': brandNameController.text.trim(),
          'owner_id': response.user!.id,
          'kyc_status': 'pending',
        });

        await _createProfile(
          response.user!.id,
          'vendor',
          fullName: contactPersonController.text.trim(),
          vendorId: vendorId,
        );

        try {
          final adminCtrl = Get.find<AdminController>();
          final newVendor = KycVendorEntity(
            id: vendorId,
            brandName: brandNameController.text,
            ownerName: contactPersonController.text.isEmpty
                ? 'Unknown'
                : contactPersonController.text,
            email: vendorEmailController.text,
            phone: '+92-300-1234567',
            category: selectedVendorCategory.value,
            appliedDate: 'June 2, 2026',
            status: KycStatus.pending,
            cnicDocUrl: 'https://picsum.photos/seed/newcnic/800/600',
            secpDocUrl: 'https://picsum.photos/seed/newsecp/800/600',
            bio:
                'Newly registered vendor brand category: ${selectedVendorCategory.value}.',
            city: 'Karachi',
          );
          adminCtrl.kycQueue.insert(0, newVendor);
        } catch (_) {}

        status.value = AuthStatus.pendingApproval;
        Get.to(
          () => const PendingApprovalScreen(),
          transition: Transition.fadeIn,
        );
      }
    } catch (e) {
      _showError('Vendor registration failed: $e');
    }
  }

  Future<void> signInVendor() async {
    if (vendorEmailController.text.isEmpty ||
        vendorPasswordController.text.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: vendorEmailController.text.trim(),
        password: vendorPasswordController.text.trim(),
      );
      if (response.user != null) {
        status.value = AuthStatus.success;
        selectedRole.value = AuthRole.vendor;
        Get.offAllNamed('/main-navigation');
        Get.snackbar(
          'Success',
          'Welcome back to the Brand Portal',
          backgroundColor: const Color(0xFFFAF9F6),
        );
      }
    } catch (e) {
      _showError('Authentication failed: $e');
    }
  }

  // Corporate Actions
  Future<void> registerCorporate() async {
    if (companyNameController.text.isEmpty ||
        corporateEmailController.text.isEmpty ||
        corporatePasswordController.text.isEmpty) {
      _showError('Please fill out all corporate details.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      final response = await _supabase.auth.signUp(
        email: corporateEmailController.text.trim(),
        password: corporatePasswordController.text.trim(),
      );
      if (response.user != null) {
        await _createProfile(
          response.user!.id,
          'corporate',
          fullName: companyNameController.text.trim(),
        );
        status.value = AuthStatus.success;
        selectedRole.value = AuthRole.corporate;
        Get.offAllNamed('/main-navigation');
      }
    } catch (e) {
      _showError('Corporate registration failed: $e');
    }
  }

  Future<void> signInCorporate() async {
    if (corporateEmailController.text.isEmpty ||
        corporatePasswordController.text.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: corporateEmailController.text.trim(),
        password: corporatePasswordController.text.trim(),
      );
      if (response.user != null) {
        status.value = AuthStatus.success;
        selectedRole.value = AuthRole.corporate;
        Get.offAllNamed('/main-navigation');
        Get.snackbar(
          'Success',
          'Welcome to Corporate Access',
          backgroundColor: const Color(0xFFFAF9F6),
        );
      }
    } catch (e) {
      _showError('Authentication failed: $e');
    }
  }

  void _showError(String message) {
    status.value = AuthStatus.error;
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFAF9F6),
      colorText: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  void onClose() {
    shopperPhoneController.dispose();
    shopperOtpController.dispose();
    vendorEmailController.dispose();
    vendorPasswordController.dispose();
    brandNameController.dispose();
    contactPersonController.dispose();
    corporateEmailController.dispose();
    corporatePasswordController.dispose();
    companyNameController.dispose();
    ntnController.dispose();
    super.onClose();
  }
}
