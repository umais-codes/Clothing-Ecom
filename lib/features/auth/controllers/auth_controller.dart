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
  final TextEditingController corporatePhoneController = TextEditingController();
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
        fullName: contactPersonController.text.trim().isNotEmpty
            ? contactPersonController.text.trim()
            : brandNameController.text.trim(),
        role: 'vendor',
        phone: vendorPhoneController.text.trim(),
      );

      if (user != null) {
        _markOnboardingComplete(AuthRole.vendor);
        final vendorId = user.id;

        // 1. Create the profile row first (without vendorId to avoid FK constraints if any)
        await _createProfile(
          user.id,
          'vendor',
          fullName: contactPersonController.text.trim(),
          phone: vendorPhoneController.text.trim(),
          email: vendorEmailController.text.trim(),
        );

        // 2. Create the vendor row (safe since the owner profile now exists)
        await _authRepository.createVendor(
          id: vendorId,
          brandName: brandNameController.text.trim(),
          ownerId: user.id,
          kycStatus: 'pending',
          cnicDocUrl: 'https://picsum.photos/seed/newcnic/800/600',
          secpDocUrl: 'https://picsum.photos/seed/newsecp/800/600',
          bio: 'Newly registered vendor brand category: ${selectedVendorCategory.value}.',
          city: 'Karachi',
          category: selectedVendorCategory.value,
        );

        // 3. Update the profile with the vendorId
        await _createProfile(
          user.id,
          'vendor',
          fullName: contactPersonController.text.trim(),
          vendorId: vendorId,
          phone: vendorPhoneController.text.trim(),
          email: vendorEmailController.text.trim(),
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
            phone: vendorPhoneController.text.trim().isEmpty
                ? '+92-300-1234567'
                : vendorPhoneController.text.trim(),
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
        // Query kyc_status from database to perform real-time access control
        final supabase = Get.find<SupabaseService>().client;
        final vendorRes = await supabase
            .from('vendors')
            .select('kyc_status')
            .eq('owner_id', user.id)
            .maybeSingle();

        final String kyc = vendorRes?['kyc_status']?.toString().toLowerCase() ?? 'pending';

        if (kyc != 'approved') {
          await _authRepository.signOut();
          _showError(kyc == 'rejected'
              ? 'Your brand application has been rejected. Please contact support.'
              : 'Your brand application is pending admin approval.');
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
      final user = await _authRepository.signUp(
        email: corporateEmailController.text.trim(),
        password: corporatePasswordController.text.trim(),
        fullName: companyNameController.text.trim(),
        role: 'corporate',
        phone: corporatePhoneController.text.trim(),
      );
      if (user != null) {
        final vendorId = user.id;

        // 1. Create the profile row first (without vendorId to satisfy FK constraints)
        await _createProfile(
          user.id,
          'corporate',
          fullName: companyNameController.text.trim(),
          phone: corporatePhoneController.text.trim(),
          email: corporateEmailController.text.trim(),
        );

        // 2. Create the vendor table row representing the corporate application
        await _authRepository.createVendor(
          id: vendorId,
          brandName: companyNameController.text.trim(),
          ownerId: user.id,
          kycStatus: 'pending',
          cnicDocUrl: 'https://picsum.photos/seed/corpc/800/600',
          secpDocUrl: 'https://picsum.photos/seed/corps/800/600',
          bio: 'Corporate buyer NTN: ${ntnController.text.trim()}, Volume: ${selectedVolume.value}.',
          city: 'Lahore',
          category: 'Corporate',
        );

        // 3. Link the profile to the vendor/corporate application row
        await _createProfile(
          user.id,
          'corporate',
          fullName: companyNameController.text.trim(),
          vendorId: vendorId,
          phone: corporatePhoneController.text.trim(),
          email: corporateEmailController.text.trim(),
        );

        // Save local corporate details for offline/profile reference
        final box = Hive.box('settings');
        box.put('corporate_ntn', ntnController.text.trim());
        box.put('corporate_volume', selectedVolume.value);

        // Pre-insert application in Admin Onboarding Screen queue
        try {
          final adminCtrl = Get.find<AdminController>();
          final newCorporate = KycVendorEntity(
            id: vendorId,
            brandName: companyNameController.text,
            ownerName: companyNameController.text,
            email: corporateEmailController.text,
            phone: corporatePhoneController.text.trim().isEmpty
                ? '+92-333-7654321'
                : corporatePhoneController.text.trim(),
            category: 'Corporate', // Categorized as Corporate
            appliedDate: 'June 2, 2026',
            status: KycStatus.pending,
            cnicDocUrl: 'https://picsum.photos/seed/corpc/800/600',
            secpDocUrl: 'https://picsum.photos/seed/corps/800/600',
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

        final String kyc = vendorRes?['kyc_status']?.toString().toLowerCase() ?? 'pending';

        if (kyc != 'approved') {
          await _authRepository.signOut();
          _showError(kyc == 'rejected'
              ? 'Your corporate application has been rejected. Please contact support.'
              : 'Your corporate application is pending admin approval.');
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

  @override
  void onClose() {
    shopperEmailController.dispose();
    shopperPasswordController.dispose();
    shopperNameController.dispose();
    vendorEmailController.dispose();
    vendorPasswordController.dispose();
    brandNameController.dispose();
    contactPersonController.dispose();
    vendorPhoneController.dispose();
    corporateEmailController.dispose();
    corporatePasswordController.dispose();
    companyNameController.dispose();
    corporatePhoneController.dispose();
    ntnController.dispose();
    super.onClose();
  }
}
