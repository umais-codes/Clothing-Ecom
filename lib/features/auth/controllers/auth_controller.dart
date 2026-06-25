import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:uuid/uuid.dart';

enum AuthRole { shopper, vendor, corporate, admin }

enum AuthStatus { initial, loading, success, pendingApproval, error }

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final Uuid uuid = const Uuid();

  AuthController(this._authRepository);

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
      await _authRepository.createProfile(
        userId: userId,
        role: role,
        fullName: fullName,
        vendorId: vendorId,
        height: heightVal,
        weight: weightVal,
        fitPreference: fitPreferenceVal,
        categories: categoriesVal,
      );
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
      await _authRepository.sendOtp(shopperPhoneController.text.trim());
      status.value = AuthStatus.initial;
      showShopperOtpField.value = true;
    } catch (e) {
      _showError(_cleanMessage(e));
    }
  }

  Future<void> verifyShopperOtp() async {
    if (shopperOtpController.text.length < 6) {
      _showError('Please enter the 6-digit OTP.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      final user = await _authRepository.verifyOtp(
        shopperPhoneController.text.trim(),
        shopperOtpController.text.trim(),
      );
      if (user != null) {
        await _createProfile(user.id, 'shopper', fullName: 'Shopper User');
        status.value = AuthStatus.success;
        selectedRole.value = AuthRole.shopper;
        Get.offAllNamed('/main-navigation');
      } else {
        _showError('Invalid OTP code.');
      }
    } catch (e) {
      _showError(_cleanMessage(e));
    }
  }

  void continueWithSocial(String provider) async {
    status.value = AuthStatus.loading;
    try {
      final user = await _authRepository.signInWithSocialProvider(provider);
      if (user != null) {
        await _createProfile(
          user.id,
          'shopper',
          fullName: user.userMetadata?['full_name'] ?? 'Shopper User',
        );
        status.value = AuthStatus.success;
        selectedRole.value = AuthRole.shopper;
        Get.offAllNamed('/main-navigation');
      } else {
        status.value = AuthStatus.initial;
      }
    } catch (e) {
      _showError(_cleanMessage(e));
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
      final user = await _authRepository.signUp(
        email: vendorEmailController.text.trim(),
        password: vendorPasswordController.text.trim(),
      );

      if (user != null) {
        final vendorId = uuid.v4();

        await _authRepository.createVendor(
          id: vendorId,
          brandName: brandNameController.text.trim(),
          ownerId: user.id,
          kycStatus: 'pending',
        );

        await _createProfile(
          user.id,
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
      _showError(_cleanMessage(e));
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
      final user = await _authRepository.signInWithPassword(
        email: vendorEmailController.text.trim(),
        password: vendorPasswordController.text.trim(),
      );
      if (user != null) {
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
      _showError(_cleanMessage(e));
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
      final user = await _authRepository.signUp(
        email: corporateEmailController.text.trim(),
        password: corporatePasswordController.text.trim(),
      );
      if (user != null) {
        await _createProfile(
          user.id,
          'corporate',
          fullName: companyNameController.text.trim(),
        );
        status.value = AuthStatus.success;
        selectedRole.value = AuthRole.corporate;
        Get.offAllNamed('/main-navigation');
      }
    } catch (e) {
      _showError(_cleanMessage(e));
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
      final user = await _authRepository.signInWithPassword(
        email: corporateEmailController.text.trim(),
        password: corporatePasswordController.text.trim(),
      );
      if (user != null) {
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
      _showError(_cleanMessage(e));
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

  String _cleanMessage(dynamic e) {
    final str = e.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
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
