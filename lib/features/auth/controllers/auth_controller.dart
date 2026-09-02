import 'dart:io';

import 'package:ecom_app/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:ecom_app/features/discovery/presentation/controllers/filter_controller.dart';
import 'package:ecom_app/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart'
    hide UserRole;
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecom_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';

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
  final TextEditingController corporateContactPersonController =
      TextEditingController();
  final TextEditingController corporatePhoneController =
      TextEditingController();
  final TextEditingController corporateCityController = TextEditingController();
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

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      debugPrint('Error in AuthController signOut: $e');
    }
    selectedRole.value = AuthRole.shopper;
    final box = Hive.box('settings');
    await box.delete('lastSelectedRole');
    await box.delete('login_time');
    await box.delete('corporate_ntn');
    await box.delete('corporate_volume');
    status.value = AuthStatus.initial;
  }

  void setRole(AuthRole role) {
    selectedRole.value = role;
    status.value = AuthStatus.initial;
    if (role != AuthRole.admin) {
      Hive.box('settings').put('lastSelectedRole', role.name);
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadTrendingProducts();
    }
    if (Get.isRegistered<FilterController>()) {
      Get.find<FilterController>().loadProducts();
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

  Future<String> _resolveUserDbRole(String userId) async {
    final supabase = Get.find<SupabaseService>().client;
    try {
      final profile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      final role = profile?['role']?.toString().toLowerCase();
      if (role != null && role.isNotEmpty) {
        return role;
      }
    } catch (e) {
      debugPrint('Error checking profile role: $e');
    }

    try {
      final vendor = await supabase
          .from('vendors')
          .select('id, category')
          .or('id.eq.$userId,owner_id.eq.$userId')
          .maybeSingle();
      if (vendor != null) {
        if (vendor['category']?.toString().toLowerCase() == 'corporate') {
          return 'corporate';
        }
        return 'vendor';
      }
    } catch (e) {
      debugPrint('Error checking vendor role: $e');
    }

    return 'shopper';
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
        final dbRole = await _resolveUserDbRole(user.id);
        if (dbRole == 'vendor') {
          await _authRepository.signOut();
          selectedRole.value = AuthRole.vendor;
          _showError(
            'This account is registered as a Brand/Vendor. Please sign in through the Brand Portal tab.',
          );
          return;
        } else if (dbRole == 'corporate') {
          await _authRepository.signOut();
          selectedRole.value = AuthRole.corporate;
          _showError(
            'This account is registered as a Corporate Buyer. Please sign in through the Corporate Access tab.',
          );
          return;
        }

        _handleAuthSuccess(AuthRole.shopper);
        AppSnackbar.success(
          title: 'Welcome Back',
          message: 'You have signed in successfully.',
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
        AppSnackbar.success(
          title: 'Account Created',
          message: 'Welcome to Valvet Maison!',
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

  // --- Vendor Actions ---
  Future<void> pickCnicDocument() async {
    try {
      final picker = ImagePicker();
      final XFile? result = await picker.pickImage(source: ImageSource.gallery);

      if (result != null) {
        cnicFileName.value = result.name;
        cnicFilePath.value = result.path;
        hasCnicUploaded.value = true;
      }
    } catch (e) {
      _showError('Failed to pick document: $e');
    }
  }

  Future<void> pickSecpDocument() async {
    try {
      final picker = ImagePicker();
      final XFile? result = await picker.pickImage(source: ImageSource.gallery);

      if (result != null) {
        secpFileName.value = result.name;
        secpFilePath.value = result.path;
        hasSecpUploaded.value = true;
      }
    } catch (e) {
      _showError('Failed to pick document: $e');
    }
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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

      final isolatedClient = SupabaseClient(
        SupabaseService.supabaseUrl,
        SupabaseService.supabaseAnonKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );

      final authRes = await isolatedClient.auth.signUp(
        email: vendorEmailController.text.trim(),
        password: vendorPasswordController.text.trim(),
        data: {'full_name': ownerName, 'role': 'vendor', 'phone': phoneNum},
      );

      final user = authRes.user;

      if (user != null) {
        final vendorId = user.id;

        String cnicUrl = '';
        String secpUrl = '';

        if (cnicFilePath.value.isNotEmpty &&
            File(cnicFilePath.value).existsSync()) {
          try {
            final file = File(cnicFilePath.value);
            final ext = file.path.split('.').last;
            final path =
                'vendor_docs/$vendorId/cnic_${DateTime.now().millisecondsSinceEpoch}.$ext';
            await isolatedClient.storage
                .from('rma-evidence')
                .upload(path, file);
            cnicUrl = isolatedClient.storage
                .from('rma-evidence')
                .getPublicUrl(path);
          } catch (e) {
            debugPrint('Error uploading CNIC doc: $e');
          }
        }

        if (secpFilePath.value.isNotEmpty &&
            File(secpFilePath.value).existsSync()) {
          try {
            final file = File(secpFilePath.value);
            final ext = file.path.split('.').last;
            final path =
                'vendor_docs/$vendorId/secp_${DateTime.now().millisecondsSinceEpoch}.$ext';
            await isolatedClient.storage
                .from('rma-evidence')
                .upload(path, file);
            secpUrl = isolatedClient.storage
                .from('rma-evidence')
                .getPublicUrl(path);
          } catch (e) {
            debugPrint('Error uploading SECP doc: $e');
          }
        }

        final currentDateStr = _formatCurrentDate();

        final cityVal = vendorCityController.text.trim().isNotEmpty
            ? vendorCityController.text.trim()
            : 'Karachi';

        // 1. Create profile row in Supabase DB via isolated client
        try {
          await isolatedClient.from('profiles').upsert({
            'id': user.id,
            'role': 'vendor',
            'full_name': ownerName,
            'phone': phoneNum,
            'email': vendorEmailController.text.trim(),
            'vendor_id': vendorId,
          });
        } catch (pe) {
          debugPrint('Profile upsert with extra columns failed: $pe');
          try {
            await isolatedClient.from('profiles').upsert({
              'id': user.id,
              'role': 'vendor',
              'full_name': ownerName,
            });
          } catch (pe2) {
            debugPrint(
              'Base profile upsert ignored (trigger created profile): $pe2',
            );
          }
        }

        final vendorEmailStr = vendorEmailController.text.trim();
        final bioStr =
            'Newly registered vendor brand category: ${selectedVendorCategory.value}.\nContact Email: $vendorEmailStr | Phone: $phoneNum';

        // 2. Create vendor row in Supabase DB via isolated client
        try {
          await isolatedClient.from('vendors').insert({
            'id': vendorId,
            'brand_name': brandNameController.text.trim(),
            'owner_id': user.id,
            'kyc_status': 'pending',
            'cnic_doc_url': cnicUrl,
            'secp_doc_url': secpUrl,
            'bio': bioStr,
            'city': cityVal,
            'category': selectedVendorCategory.value,
            'email': vendorEmailStr,
            'phone': phoneNum,
            'owner_name': ownerName,
          });
        } catch (colErr) {
          debugPrint('Isolated vendor insert fallback: $colErr');
          await isolatedClient.from('vendors').insert({
            'id': vendorId,
            'brand_name': brandNameController.text.trim(),
            'owner_id': user.id,
            'kyc_status': 'pending',
            'cnic_doc_url': cnicUrl,
            'secp_doc_url': secpUrl,
            'bio': bioStr,
            'city': cityVal,
            'category': selectedVendorCategory.value,
          });
        }

        // 3. Add to Super Admin queue if active
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
            bio:
                'Newly registered vendor brand category: ${selectedVendorCategory.value}.',
            city: cityVal,
          );
          adminCtrl.kycQueue.insert(0, newVendor);
        } catch (_) {}

        isolatedClient.dispose();

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
        final dbRole = await _resolveUserDbRole(user.id);
        if (dbRole == 'shopper') {
          await _authRepository.signOut();
          selectedRole.value = AuthRole.shopper;
          _showError(
            'This account is registered as a Consumer/Shopper. Please sign in through the Shopper tab or register your Brand.',
          );
          return;
        } else if (dbRole == 'corporate') {
          await _authRepository.signOut();
          selectedRole.value = AuthRole.corporate;
          _showError(
            'This account is registered as a Corporate Buyer. Please sign in through the Corporate Access tab.',
          );
          return;
        }

        final supabase = Get.find<SupabaseService>().client;
        try {
          final vendorRes = await supabase
              .from('vendors')
              .select('kyc_status')
              .or('id.eq.${user.id},owner_id.eq.${user.id}')
              .maybeSingle();

          final String kyc =
              vendorRes?['kyc_status']?.toString().toLowerCase() ?? '';

          if (kyc == 'rejected') {
            await _authRepository.signOut();
            _showError(
              'Your brand application has been rejected. Please contact support.',
            );
            return;
          }
        } catch (e) {
          debugPrint('KYC check error: $e');
        }

        _handleAuthSuccess(AuthRole.vendor);
        AppSnackbar.success(
          title: 'Brand Portal',
          message: 'Welcome back to your Brand Dashboard',
        );
      }
    } catch (e) {
      _showError(_cleanMessage(e));
    }
  }

  // --- Corporate Actions ---
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
      final contactPerson =
          corporateContactPersonController.text.trim().isNotEmpty
          ? corporateContactPersonController.text.trim()
          : compName;
      final corpPhone = corporatePhoneController.text.trim().isNotEmpty
          ? corporatePhoneController.text.trim()
          : 'Not provided';
      final corpCity = corporateCityController.text.trim().isNotEmpty
          ? corporateCityController.text.trim()
          : 'Lahore';
      final corpEmailStr = corporateEmailController.text.trim();
      final ntnVal = ntnController.text.trim();
      final volumeVal = selectedVolume.value;

      final bioStr =
          'Corporate buyer NTN: $ntnVal, Volume: $volumeVal.\nContact Person: $contactPerson | Email: $corpEmailStr | Phone: $corpPhone | City: $corpCity';

      final isolatedClient = SupabaseClient(
        SupabaseService.supabaseUrl,
        SupabaseService.supabaseAnonKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );

      final authRes = await isolatedClient.auth.signUp(
        email: corpEmailStr,
        password: corporatePasswordController.text.trim(),
        data: {
          'full_name': contactPerson,
          'role': 'corporate',
          'phone': corpPhone,
        },
      );

      final user = authRes.user;
      if (user != null) {
        final vendorId = user.id;

        String cnicUrl = '';
        String secpUrl = '';

        if (cnicFilePath.value.isNotEmpty &&
            File(cnicFilePath.value).existsSync()) {
          try {
            final file = File(cnicFilePath.value);
            final ext = file.path.split('.').last;
            final path =
                'vendor_docs/$vendorId/cnic_${DateTime.now().millisecondsSinceEpoch}.$ext';
            await isolatedClient.storage
                .from('rma-evidence')
                .upload(path, file);
            cnicUrl = isolatedClient.storage
                .from('rma-evidence')
                .getPublicUrl(path);
          } catch (e) {
            debugPrint('Error uploading corporate CNIC doc: $e');
          }
        }

        if (secpFilePath.value.isNotEmpty &&
            File(secpFilePath.value).existsSync()) {
          try {
            final file = File(secpFilePath.value);
            final ext = file.path.split('.').last;
            final path =
                'vendor_docs/$vendorId/secp_${DateTime.now().millisecondsSinceEpoch}.$ext';
            await isolatedClient.storage
                .from('rma-evidence')
                .upload(path, file);
            secpUrl = isolatedClient.storage
                .from('rma-evidence')
                .getPublicUrl(path);
          } catch (e) {
            debugPrint('Error uploading corporate SECP doc: $e');
          }
        }

        final currentDateStr = _formatCurrentDate();

        try {
          await isolatedClient.from('profiles').upsert({
            'id': user.id,
            'role': 'corporate',
            'full_name': contactPerson,
            'phone': corpPhone,
            'email': corpEmailStr,
            'vendor_id': vendorId,
          });
        } catch (pe) {
          debugPrint('Corporate profile upsert failed: $pe');
          try {
            await isolatedClient.from('profiles').upsert({
              'id': user.id,
              'role': 'corporate',
              'full_name': contactPerson,
            });
          } catch (pe2) {
            debugPrint(
              'Base corporate profile upsert ignored (trigger created profile): $pe2',
            );
          }
        }

        try {
          await isolatedClient.from('vendors').insert({
            'id': vendorId,
            'brand_name': compName,
            'owner_id': user.id,
            'kyc_status': 'pending',
            'cnic_doc_url': cnicUrl,
            'secp_doc_url': secpUrl,
            'bio': bioStr,
            'city': corpCity,
            'category': 'Corporate',
            'email': corpEmailStr,
            'phone': corpPhone,
            'owner_name': contactPerson,
          });
        } catch (colErr) {
          await isolatedClient.from('vendors').insert({
            'id': vendorId,
            'brand_name': compName,
            'owner_id': user.id,
            'kyc_status': 'pending',
            'cnic_doc_url': cnicUrl,
            'secp_doc_url': secpUrl,
            'bio': bioStr,
            'city': corpCity,
            'category': 'Corporate',
          });
        }

        final box = Hive.box('settings');
        box.put('corporate_ntn', ntnVal);
        box.put('corporate_volume', volumeVal);

        try {
          final adminCtrl = Get.find<AdminController>();
          final newCorporate = KycVendorEntity(
            id: vendorId,
            brandName: compName,
            ownerName: contactPerson,
            email: corpEmailStr,
            phone: corpPhone,
            category: 'Corporate',
            appliedDate: currentDateStr,
            status: KycStatus.pending,
            cnicDocUrl: cnicUrl,
            secpDocUrl: secpUrl,
            bio: bioStr,
            city: corpCity,
          );
          adminCtrl.kycQueue.insert(0, newCorporate);
        } catch (_) {}

        isolatedClient.dispose();

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
        final dbRole = await _resolveUserDbRole(user.id);
        if (dbRole == 'shopper') {
          await _authRepository.signOut();
          selectedRole.value = AuthRole.shopper;
          _showError(
            'This account is registered as a Consumer/Shopper. Please sign in through the Shopper tab or register as a Corporate Buyer.',
          );
          return;
        } else if (dbRole == 'vendor') {
          await _authRepository.signOut();
          selectedRole.value = AuthRole.vendor;
          _showError(
            'This account is registered as a Brand/Vendor. Please sign in through the Brand Portal tab.',
          );
          return;
        }

        final supabase = Get.find<SupabaseService>().client;
        try {
          final vendorRes = await supabase
              .from('vendors')
              .select('kyc_status')
              .or('id.eq.${user.id},owner_id.eq.${user.id}')
              .maybeSingle();

          final String kyc =
              vendorRes?['kyc_status']?.toString().toLowerCase() ?? '';

          if (kyc == 'rejected') {
            await _authRepository.signOut();
            _showError(
              'Your corporate application has been rejected. Please contact support.',
            );
            return;
          }
        } catch (e) {
          debugPrint('Corporate KYC check error: $e');
        }

        _handleAuthSuccess(AuthRole.corporate);
        AppSnackbar.success(
          title: 'Corporate Access',
          message: 'Welcome to Corporate Wholesale Portal',
        );
      }
    } catch (e) {
      _showError(_cleanMessage(e));
    }
  }

  void _showError(String message) {
    status.value = AuthStatus.error;
    errorMessage.value = message;
    AppSnackbar.error(
      title: 'Authentication Error',
      message: message,
    );
  }

  String _cleanMessage(dynamic e) {
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('user_already_exists') ||
          e.code == 'user_already_exists') {
        return 'An account with this email address already exists. Please log in or use a different email address.';
      }
      if (msg.contains('invalid login credentials')) {
        return 'Invalid email or password. Please double check your credentials.';
      }
      if (msg.contains('password should be at least')) {
        return 'Password must be at least 6 characters long.';
      }
      return e.message;
    }
    final str = e.toString();
    if (str.contains('user_already_exists') ||
        str.contains('User already registered')) {
      return 'An account with this email address already exists. Please log in or use a different email address.';
    }
    if (str.startsWith('Exception: ')) {
      return str.substring(11);
    }
    return str;
  }
}
