import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart'
    hide UserRole;
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthRole { shopper, vendor, corporate, admin }

enum AuthStatus { initial, loading, success, pendingApproval, error }

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final Uuid uuid = const Uuid();

  AuthController(this._authRepository);

  User? get currentUser => _authRepository.currentUser;

  final Rx<AuthRole> selectedRole = AuthRole.shopper.obs;

  final Rx<AuthStatus> status = AuthStatus.initial.obs;
  final RxString errorMessage = ''.obs;

  final RxBool isVendorLogin = false.obs;
  final RxBool isCorporateLogin = false.obs;

  // --- Shopper Controllers ---
  final TextEditingController shopperEmailController = TextEditingController();
  final TextEditingController shopperPasswordController =
      TextEditingController();
  final TextEditingController shopperNameController = TextEditingController();
  final RxBool isShopperLogin = true.obs;

  // --- Vendor Controllers ---
  final TextEditingController vendorEmailController = TextEditingController();
  final TextEditingController vendorPasswordController =
      TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController vendorPhoneController = TextEditingController();
  final TextEditingController vendorCityController = TextEditingController();
  final RxString selectedVendorCategory = "Men's".obs;
  final RxBool hasCnicUploaded = false.obs;
  final RxString cnicFileName = ''.obs;
  final RxString cnicFilePath = ''.obs;
  final RxBool hasSecpUploaded = false.obs;
  final RxString secpFileName = ''.obs;
  final RxString secpFilePath = ''.obs;

  // --- Corporate Controllers ---
  final TextEditingController corporateEmailController =
      TextEditingController();
  final TextEditingController corporatePasswordController =
      TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController corporatePhoneController =
      TextEditingController();
  final TextEditingController ntnController = TextEditingController();
  final RxString selectedVolume = '1-50 Employees'.obs;
  final List<String> volumeOptions = [
    '1-50 Employees',
    '51-200 Employees',
    '201-500 Employees',
    '500+ Employees',
  ];

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box('settings');
    final savedRole = box.get('lastSelectedRole') as String?;
    if (savedRole != null) {
      for (final role in AuthRole.values) {
        if (role.name == savedRole) {
          selectedRole.value = role;
          break;
        }
      }
    }
  }

  void setRole(AuthRole role) {
    selectedRole.value = role;
    status.value = AuthStatus.initial;
    if (role != AuthRole.admin) {
      Hive.box('settings').put('lastSelectedRole', role.name);
    }
  }

  Future<void> _createProfile(
    String userId,
    String role, {
    String? fullName,
    String? vendorId,
    String? phone,
    String? email,
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
        phone: phone,
        email: email,
        height: heightVal,
        weight: weightVal,
        fitPreference: fitPreferenceVal,
        categories: categoriesVal,
      );
    } catch (e) {
      debugPrint('Error creating profile: $e');
    }
  }

  void _markOnboardingComplete(AuthRole role) {
    final box = Hive.box('settings');
    box.put('hasSeenOnboarding', true);
    box.put('login_time', DateTime.now().millisecondsSinceEpoch);
    if (role != AuthRole.admin) {
      box.put('lastSelectedRole', role.name);
    }
    if (Get.isRegistered<OnboardingController>()) {
      Get.find<OnboardingController>().clearOnboardingDrafts();
    }
  }

  void _handleAuthSuccess(
    AuthRole role, {
    String nextRoute = '/main-navigation',
  }) {
    _markOnboardingComplete(role);
    status.value = AuthStatus.success;
    selectedRole.value = role;
    Get.offAllNamed(nextRoute);
  }

  Future<void> signInShopper() async {
    if (shopperEmailController.text.trim().isEmpty ||
        shopperPasswordController.text.trim().isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      final user = await _authRepository.signInWithPassword(
        email: shopperEmailController.text.trim(),
        password: shopperPasswordController.text.trim(),
      );
      if (user != null) {
        _handleAuthSuccess(AuthRole.shopper);
        Get.snackbar(
          'Success',
          'Welcome back!',
          backgroundColor: const Color(0xFFFAF9F6),
        );
      }
    } catch (e) {
      _showError(_cleanMessage(e));
    }
  }

  Future<void> signUpShopper() async {
    if (shopperNameController.text.trim().isEmpty ||
        shopperEmailController.text.trim().isEmpty ||
        shopperPasswordController.text.trim().isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    status.value = AuthStatus.loading;
    try {
      final user = await _authRepository.signUp(
        email: shopperEmailController.text.trim(),
        password: shopperPasswordController.text.trim(),
        fullName: shopperNameController.text.trim(),
        role: 'shopper',
      );
      if (user != null) {
        await _createProfile(
          user.id,
          'shopper',
          fullName: shopperNameController.text.trim(),
          email: shopperEmailController.text.trim(),
        );
        _handleAuthSuccess(AuthRole.shopper);
        Get.snackbar(
          'Success',
          'Account created successfully!',
          backgroundColor: const Color(0xFFFAF9F6),
        );
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
        String roleStr = 'shopper';
        AuthRole authRole = AuthRole.shopper;
        if (Get.isRegistered<OnboardingController>()) {
          final onboarding = Get.find<OnboardingController>();
          if (onboarding.selectedRole.value == UserRole.fashionBrand) {
            roleStr = 'vendor';
            authRole = AuthRole.vendor;
          } else if (onboarding.selectedRole.value == UserRole.corporateBuyer) {
            roleStr = 'corporate';
            authRole = AuthRole.corporate;
          }
        }

        await _createProfile(
          user.id,
          roleStr,
          fullName:
              user.userMetadata?['full_name'] ??
              '${roleStr.capitalizeFirst} User',
          email: user.email,
        );
        _handleAuthSuccess(authRole);
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
        cnicFilePath.value = result.files.first.path ?? '';
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
        secpFilePath.value = result.files.first.path ?? '';
        hasSecpUploaded.value = true;
      }
    } catch (e) {
      _showError('Failed to pick document: $e');
    }
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
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
      final ownerName = contactPersonController.text.trim().isNotEmpty
          ? contactPersonController.text.trim()
          : (brandNameController.text.trim().isNotEmpty
              ? brandNameController.text.trim()
              : 'Owner');
      final phoneNum = vendorPhoneController.text.trim().isNotEmpty
          ? vendorPhoneController.text.trim()
          : 'Not provided';

      final user = await _authRepository.signUp(
        email: vendorEmailController.text.trim(),
        password: vendorPasswordController.text.trim(),
        fullName: ownerName,
        role: 'vendor',
        phone: phoneNum,
      );

      if (user != null) {
        _markOnboardingComplete(AuthRole.vendor);
        final vendorId = user.id;

        String cnicUrl = '';
        String secpUrl = '';

        if (cnicFilePath.value.isNotEmpty && File(cnicFilePath.value).existsSync()) {
          try {
            cnicUrl = await _authRepository.uploadVendorDocument(
              userId: vendorId,
              file: File(cnicFilePath.value),
              docType: 'cnic',
            );
          } catch (e) {
            debugPrint('Error uploading CNIC doc: $e');
          }
        }

        if (secpFilePath.value.isNotEmpty && File(secpFilePath.value).existsSync()) {
          try {
            secpUrl = await _authRepository.uploadVendorDocument(
              userId: vendorId,
              file: File(secpFilePath.value),
              docType: 'secp',
            );
          } catch (e) {
            debugPrint('Error uploading SECP doc: $e');
          }
        }

        final currentDateStr = _formatCurrentDate();

        final cityVal = vendorCityController.text.trim().isNotEmpty
            ? vendorCityController.text.trim()
            : 'Karachi';

        // 1. Create the profile row first
        await _createProfile(
          user.id,
          'vendor',
          fullName: ownerName,
          phone: phoneNum,
          email: vendorEmailController.text.trim(),
        );

        // 2. Create the vendor row
        await _authRepository.createVendor(
          id: vendorId,
          brandName: brandNameController.text.trim(),
          ownerId: user.id,
          kycStatus: 'pending',
          cnicDocUrl: cnicUrl,
          secpDocUrl: secpUrl,
          bio: 'Newly registered vendor brand category: ${selectedVendorCategory.value}.',
          city: cityVal,
          category: selectedVendorCategory.value,
          email: vendorEmailController.text.trim(),
          phone: phoneNum,
          ownerName: ownerName,
        );

        // 3. Update the profile with the vendorId
        await _createProfile(
          user.id,
          'vendor',
          fullName: ownerName,
          vendorId: vendorId,
          phone: phoneNum,
          email: vendorEmailController.text.trim(),
        );

        try {
          final adminCtrl = Get.find<AdminController>();
          final newVendor = KycVendorEntity(
            id: vendorId,
            brandName: brandNameController.text.trim(),
            ownerName: ownerName,
            email: vendorEmailController.text.trim(),
            phone: phoneNum,
            category: selectedVendorCategory.value,
            appliedDate: currentDateStr,
            status: KycStatus.pending,
            cnicDocUrl: cnicUrl,
            secpDocUrl: secpUrl,
            bio: 'Newly registered vendor brand category: ${selectedVendorCategory.value}.',
            city: cityVal,
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
        // Query kyc_status from database to perform real-time access control
        final supabase = Get.find<SupabaseService>().client;
        final vendorRes = await supabase
            .from('vendors')
            .select('kyc_status')
            .eq('owner_id', user.id)
            .maybeSingle();

        final String kyc =
            vendorRes?['kyc_status']?.toString().toLowerCase() ?? 'pending';

        if (kyc != 'approved') {
          await _authRepository.signOut();
          _showError(
            kyc == 'rejected'
                ? 'Your brand application has been rejected. Please contact support.'
                : 'Your brand application is pending admin approval.',
          );
          return;
        }

        _handleAuthSuccess(AuthRole.vendor);
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
      final compName = companyNameController.text.trim();
      final corpPhone = corporatePhoneController.text.trim().isNotEmpty
          ? corporatePhoneController.text.trim()
          : 'Not provided';

      final user = await _authRepository.signUp(
        email: corporateEmailController.text.trim(),
        password: corporatePasswordController.text.trim(),
        fullName: compName,
        role: 'corporate',
        phone: corpPhone,
      );
      if (user != null) {
        final vendorId = user.id;

        String cnicUrl = '';
        String secpUrl = '';

        if (cnicFilePath.value.isNotEmpty && File(cnicFilePath.value).existsSync()) {
          try {
            cnicUrl = await _authRepository.uploadVendorDocument(
              userId: vendorId,
              file: File(cnicFilePath.value),
              docType: 'cnic',
            );
          } catch (e) {
            debugPrint('Error uploading corporate CNIC doc: $e');
          }
        }

        if (secpFilePath.value.isNotEmpty && File(secpFilePath.value).existsSync()) {
          try {
            secpUrl = await _authRepository.uploadVendorDocument(
              userId: vendorId,
              file: File(secpFilePath.value),
              docType: 'secp',
            );
          } catch (e) {
            debugPrint('Error uploading corporate SECP doc: $e');
          }
        }

        final currentDateStr = _formatCurrentDate();

        // 1. Create the profile row first
        await _createProfile(
          user.id,
          'corporate',
          fullName: compName,
          phone: corpPhone,
          email: corporateEmailController.text.trim(),
        );

        // 2. Create the vendor table row representing the corporate application
        await _authRepository.createVendor(
          id: vendorId,
          brandName: compName,
          ownerId: user.id,
          kycStatus: 'pending',
          cnicDocUrl: cnicUrl,
          secpDocUrl: secpUrl,
          bio: 'Corporate buyer NTN: ${ntnController.text.trim()}, Volume: ${selectedVolume.value}.',
          city: 'Lahore',
          category: 'Corporate',
        );

        // 3. Link the profile to the vendor/corporate application row
        await _createProfile(
          user.id,
          'corporate',
          fullName: compName,
          vendorId: vendorId,
          phone: corpPhone,
          email: corporateEmailController.text.trim(),
        );

        final box = Hive.box('settings');
        box.put('corporate_ntn', ntnController.text.trim());
        box.put('corporate_volume', selectedVolume.value);

        try {
          final adminCtrl = Get.find<AdminController>();
          final newCorporate = KycVendorEntity(
            id: vendorId,
            brandName: compName,
            ownerName: compName,
            email: corporateEmailController.text.trim(),
            phone: corpPhone,
            category: 'Corporate',
            appliedDate: currentDateStr,
            status: KycStatus.pending,
            cnicDocUrl: cnicUrl,
            secpDocUrl: secpUrl,
            bio: 'Corporate buyer NTN: ${ntnController.text.trim()}, Volume: ${selectedVolume.value}.',
            city: 'Lahore',
          );
          adminCtrl.kycQueue.insert(0, newCorporate);
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
        // Query kyc_status from database to perform real-time access control
        final supabase = Get.find<SupabaseService>().client;
        final vendorRes = await supabase
            .from('vendors')
            .select('kyc_status')
            .eq('owner_id', user.id)
            .maybeSingle();

        final String kyc =
            vendorRes?['kyc_status']?.toString().toLowerCase() ?? 'pending';

        if (kyc != 'approved') {
          await _authRepository.signOut();
          _showError(
            kyc == 'rejected'
                ? 'Your corporate application has been rejected. Please contact support.'
                : 'Your corporate application is pending admin approval.',
          );
          return;
        }

        _handleAuthSuccess(AuthRole.corporate);
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
}
