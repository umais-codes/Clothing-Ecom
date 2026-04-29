import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:file_picker/file_picker.dart';

enum AuthRole { shopper, vendor, corporate }

enum AuthStatus { initial, loading, success, pendingApproval, error }

class AuthController extends GetxController {
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

  // Shopper Actions
  Future<void> sendShopperOtp() async {
    if (shopperPhoneController.text.length < 10) {
      _showError('Please enter a valid mobile number.');
      return;
    }
    status.value = AuthStatus.loading;
    await Future.delayed(const Duration(seconds: 1)); // Mock
    status.value = AuthStatus.initial;
    showShopperOtpField.value = true;
  }

  Future<void> verifyShopperOtp() async {
    if (shopperOtpController.text.length < 6) {
      _showError('Please enter the 6-digit OTP.');
      return;
    }
    status.value = AuthStatus.loading;
    await Future.delayed(const Duration(seconds: 1)); // Mock
    status.value = AuthStatus.success;
    selectedRole.value = AuthRole.shopper;
    Get.offAllNamed('/main-navigation');
  }

  void continueWithSocial(String provider) {
    status.value = AuthStatus.loading;
    Future.delayed(const Duration(seconds: 1), () {
      status.value = AuthStatus.success;
      Get.offAllNamed('/main-navigation');
    });
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
        !hasCnicUploaded.value ||
        !hasSecpUploaded.value) {
      _showError('Please complete all required fields and uploads.');
      return;
    }
    status.value = AuthStatus.loading;
    await Future.delayed(const Duration(seconds: 2)); // Mock
    status.value = AuthStatus.pendingApproval;
    Get.to(() => const PendingApprovalScreen(), transition: Transition.fadeIn);
  }

  Future<void> signInVendor() async {
    if (vendorEmailController.text.isEmpty ||
        vendorPasswordController.text.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    status.value = AuthStatus.loading;
    await Future.delayed(const Duration(seconds: 2)); // Mock
    status.value = AuthStatus.success;
    // Set role explicitly to ensure navigation logic picks it up
    selectedRole.value = AuthRole.vendor;
    
    Get.offAllNamed('/main-navigation');
    
    Get.snackbar(
      'Success',
      'Welcome back to the Brand Portal',
      backgroundColor: const Color(0xFFFAF9F6),
    );
  }

  // Corporate Actions
  Future<void> registerCorporate() async {
    if (companyNameController.text.isEmpty ||
        corporateEmailController.text.isEmpty ||
        ntnController.text.isEmpty) {
      _showError('Please fill out all corporate details.');
      return;
    }
    status.value = AuthStatus.loading;
    await Future.delayed(const Duration(seconds: 2)); // Mock
    status.value = AuthStatus.success;
    selectedRole.value = AuthRole.corporate;
    Get.offAllNamed('/main-navigation');
  }

  Future<void> signInCorporate() async {
    if (corporateEmailController.text.isEmpty ||
        corporatePasswordController.text.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    status.value = AuthStatus.loading;
    await Future.delayed(const Duration(seconds: 2)); // Mock
    status.value = AuthStatus.success;
    // Set role explicitly to ensure navigation logic picks it up
    selectedRole.value = AuthRole.corporate;

    Get.offAllNamed('/main-navigation');

    Get.snackbar(
      'Success',
      'Welcome to Corporate Access',
      backgroundColor: const Color(0xFFFAF9F6),
    );
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
