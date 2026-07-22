import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';

class SplashController extends GetxController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startInitTimer();
  }

  void _startInitTimer() {
    _timer = Timer(const Duration(milliseconds: 2500), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    try {
      final authRepo = Get.find<AuthRepository>();
      final user = authRepo.currentUser;
      if (user != null) {
        final box = Hive.box('settings');
        final loginTimeMs = box.get('login_time') as int?;
        bool isSessionValid = true;

        if (loginTimeMs != null) {
          final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimeMs);
          final diff = DateTime.now().difference(loginTime).inDays;
          if (diff >= 7) {
            isSessionValid = false;
          }
        } else {
          // Initialize for existing active sessions to prevent abrupt logout
          box.put('login_time', DateTime.now().millisecondsSinceEpoch);
        }

        if (isSessionValid) {
          // 1. Respect user's explicit perspective choice saved in Hive settings
          String? roleStr = box.get('lastSelectedRole')?.toString();

          // 2. Fallback to online profile role from database
          if (roleStr == null || roleStr.isEmpty) {
            try {
              final data = await authRepo.getProfile(user.id);
              if (data != null) {
                roleStr = data['role']?.toString();
              }
            } catch (e) {
              Get.printInfo(
                info: 'Failed to fetch online profile (offline?): $e',
              );
            }
          }

          // 3. Fallback to Auth user metadata
          roleStr ??= user.userMetadata?['role']?.toString();

          if (roleStr != null && roleStr.isNotEmpty) {
            final authCtrl = Get.find<AuthController>();
            AuthRole? matchedRole;
            for (final role in AuthRole.values) {
              if (role.name == roleStr) {
                matchedRole = role;
                break;
              }
            }

            if (matchedRole != null) {
              if (matchedRole == AuthRole.vendor ||
                  matchedRole == AuthRole.corporate) {
                try {
                  final supabase = Get.find<SupabaseService>().client;
                  final vendorRes = await supabase
                      .from('vendors')
                      .select('kyc_status')
                      .eq('owner_id', user.id)
                      .maybeSingle();

                  final kyc = vendorRes?['kyc_status']
                      ?.toString()
                      .toLowerCase();
                  if (kyc != 'approved') {
                    matchedRole = AuthRole.shopper;
                    authCtrl.setRole(AuthRole.shopper);
                  }
                } catch (e) {
                  matchedRole = AuthRole.shopper;
                  authCtrl.setRole(AuthRole.shopper);
                }
              }

              authCtrl.selectedRole.value = matchedRole;
              if (matchedRole == AuthRole.admin) {
                Get.offAllNamed('/admin-panel');
              } else {
                Get.offAllNamed('/main-navigation');
              }
              return;
            }
          }
        } else {
          // Session expired (7 days or more)
          await authRepo.signOut();
          box.delete('login_time');
        }
      }
    } catch (e) {
      Get.printInfo(info: 'Splash session verification failed: $e');
    }
    Get.offAllNamed('/onboarding');
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
