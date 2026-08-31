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
import 'package:ecom_app/app/widgets/custom_permission_dialog.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Observables for instant UI updates
  final RxString userName = 'Guest Shopper'.obs;
  final RxString userEmail = 'guest@velvetmaison.pk'.obs;
  final RxString userPhone = 'Not logged in'.obs;
  final RxString profileImagePath = ''.obs;
  final RxBool isSaving = false.obs;

  // Vendor specific observables
  final RxString brandName = ''.obs;
  final RxString kycStatus = 'pending'.obs;
  final RxInt vendorActiveProducts = 0.obs;
  final RxInt vendorPendingOrders = 0.obs;
  final RxDouble vendorMonthlyRevenue = 0.0.obs;

  // Corporate specific observables
  final RxString companyNtn = ''.obs;
  final RxString employeeVolume = ''.obs;

  // Fit Profile Metrics
  final RxString height = '170cm'.obs;
  final RxString weight = '65kg'.obs;
  final RxString fitPreference = 'Regular Fit'.obs;

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
        String name = metadata?['full_name']?.toString() ?? '';
        if (name.isEmpty && user.email != null) {
          name = user.email!.split('@')[0];
          if (name.isNotEmpty) {
            name = name[0].toUpperCase() + name.substring(1);
          }
        }
        userName.value = name.isNotEmpty ? name : 'Shopper';

        final rawAvatar = metadata?['avatar_url']?.toString() ?? '';
        if (rawAvatar.isNotEmpty &&
            !rawAvatar.contains('vendor_docs') &&
            !rawAvatar.contains('secp') &&
            !rawAvatar.contains('cnic') &&
            !rawAvatar.contains('rma-evidence')) {
          profileImagePath.value = rawAvatar;
        } else {
          profileImagePath.value = '';
        }

        final phoneVal = metadata?['phone']?.toString() ?? '';
        if (phoneVal.isNotEmpty) {
          userPhone.value = phoneVal;
        }
        if (metadata?['height'] != null) {
          height.value =
              '${metadata!['height'].toString().replaceAll('.0', '')}cm';
        }
        if (metadata?['weight'] != null) {
          weight.value =
              '${metadata!['weight'].toString().replaceAll('.0', '')}kg';
        }
        if (metadata?['fit_preference'] != null) {
          fitPreference.value = metadata!['fit_preference'].toString();
        }

        // Fetch custom profile metrics from Supabase DB via repository
        final data = await _authRepository.getProfile(user.id);
        if (data != null) {
          if (data['full_name'] != null &&
              data['full_name'].toString().trim().isNotEmpty) {
            userName.value = data['full_name'].toString();
          }
          if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
            userPhone.value = data['phone'].toString();
          }
          final dbAvatar = data['avatar_url']?.toString() ?? '';
          if (dbAvatar.isNotEmpty &&
              !dbAvatar.contains('vendor_docs') &&
              !dbAvatar.contains('secp') &&
              !dbAvatar.contains('cnic') &&
              !dbAvatar.contains('rma-evidence')) {
            profileImagePath.value = dbAvatar;
          }
          if (data['height'] != null) {
            height.value =
                '${data['height'].toString().replaceAll('.0', '')}cm';
          }
          if (data['weight'] != null) {
            weight.value =
                '${data['weight'].toString().replaceAll('.0', '')}kg';
          }
          if (data['fit_preference'] != null) {
            fitPreference.value = data['fit_preference'].toString();
          }
        }

        final supabase = Get.find<SupabaseService>().client;
        Map<String, dynamic>? vendorRes;
        try {
          vendorRes = await supabase
              .from('vendors')
              .select()
              .or('id.eq.${user.id},owner_id.eq.${user.id}')
              .maybeSingle();
        } catch (ve) {
          debugPrint('Vendor check in profile controller error: $ve');
        }

        // Fetch role-specific vendor / corporate data
        if (currentRole == AuthRole.vendor) {
          if (vendorRes != null) {
            brandName.value = vendorRes['brand_name']?.toString() ?? '';
            kycStatus.value = vendorRes['kyc_status']?.toString() ?? 'pending';
            final String vendorId = vendorRes['id'].toString();

            try {
              final productsRes = await supabase
                  .from('products')
                  .select('id')
                  .eq('vendor_id', vendorId);

              final productIds = (productsRes as List)
                  .map((p) => p['id'].toString())
                  .toList();

              vendorActiveProducts.value = productIds.length;

              if (productIds.isNotEmpty) {
                final itemsRes = await supabase
                    .from('order_items')
                    .select(
                      'quantity, unit_price, order_id, orders!inner(status, created_at)',
                    )
                    .filter('product_id', 'in', productIds);

                final Set<String> pendingOrderIds = {};
                double monthlyRevenueSum = 0.0;

                final now = DateTime.now();
                final thirtyDaysAgo = now.subtract(const Duration(days: 30));

                for (var item in (itemsRes as List)) {
                  final order = item['orders'];
                  if (order != null) {
                    final status =
                        order['status']?.toString().toLowerCase() ?? '';
                    final orderId = item['order_id']?.toString() ?? '';

                    if (status == 'pending' || status == 'paid') {
                      pendingOrderIds.add(orderId);
                    }

                    if (status != 'cancelled') {
                      final createdAtStr = order['created_at']?.toString();
                      if (createdAtStr != null) {
                        final createdAt = DateTime.tryParse(createdAtStr);
                        if (createdAt != null &&
                            createdAt.isAfter(thirtyDaysAgo)) {
                          final double qty =
                              (item['quantity'] as num?)?.toDouble() ?? 0.0;
                          final double price =
                              (item['unit_price'] as num?)?.toDouble() ?? 0.0;
                          monthlyRevenueSum += (qty * price);
                        }
                      }
                    }
                  }
                }

                vendorPendingOrders.value = pendingOrderIds.length;
                vendorMonthlyRevenue.value = monthlyRevenueSum;
              } else {
                vendorPendingOrders.value = 0;
                vendorMonthlyRevenue.value = 0.0;
              }
            } catch (ve) {
              debugPrint('Failed to load vendor details: $ve');
            }
          }
        } else if (currentRole == AuthRole.corporate) {
          final box = Hive.box('settings');
          final metaCompany =
              metadata?['company_name']?.toString() ??
              data?['company_name']?.toString();
          final metaNtn =
              metadata?['ntn']?.toString() ??
              metadata?['ntn_number']?.toString() ??
              data?['ntn_number']?.toString();
          final metaVolume =
              metadata?['volume']?.toString() ??
              metadata?['employee_volume']?.toString() ??
              data?['employee_volume']?.toString();

          if (metaCompany != null && metaCompany.isNotEmpty) {
            userName.value = metaCompany;
          }
          companyNtn.value =
              metaNtn ??
              box.get('corporate_ntn', defaultValue: 'NTN-8762541-0') as String;
          employeeVolume.value =
              metaVolume ??
              box.get('corporate_volume', defaultValue: '51-200 Employees')
                  as String;
        }
      } else {
        userName.value = 'Guest Shopper';
        userEmail.value = 'guest@velvetmaison.pk';
        userPhone.value = 'Not logged in';
        profileImagePath.value = '';
        height.value = '170cm';
        weight.value = '65kg';
        fitPreference.value = 'Regular Fit';
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
                    Get.back();
                    Get.showOverlay(
                      asyncFunction: () async {
                        await _authRepository.updateBodyMetrics(
                          userId: user.id,
                          height: tempHeight.value,
                          weight: tempWeight.value,
                          fitPreference: tempFit.value,
                        );

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

      if (currentRole == AuthRole.vendor &&
          brandName != null &&
          brandName.isNotEmpty) {
        try {
          final supabase = Get.find<SupabaseService>().client;
          await supabase
              .from('vendors')
              .update({'brand_name': brandName})
              .eq('owner_id', user.id);
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
    userName.value = 'Guest Shopper';
    userEmail.value = 'guest@velvetmaison.pk';
    userPhone.value = 'Not logged in';
    profileImagePath.value = '';
    height.value = '170cm';
    weight.value = '65kg';
    fitPreference.value = 'Regular Fit';
    brandName.value = '';
    kycStatus.value = 'pending';
    companyNtn.value = '';
    employeeVolume.value = '';
    vendorActiveProducts.value = 0;
    vendorPendingOrders.value = 0;
    vendorMonthlyRevenue.value = 0.0;
  }

  Future<void> logout() async {
    final context = Get.context;
    if (context == null) return;

    CustomPermissionDialog.show(
      context: context,
      icon: Icons.logout_rounded,
      title: 'Sign Out?',
      description: 'Are you sure you want to sign out of your account?',
      grantText: 'Log Out',
      denyText: 'Cancel',
      onGrant: () async {
        try {
          await _authController.signOut();
          _resetProfileData();
        } catch (e) {
          debugPrint('Error signing out: $e');
        }
        Get.offAllNamed('/onboarding');
      },
    );
  }
}
