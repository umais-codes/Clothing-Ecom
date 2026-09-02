import 'dart:async';
import 'package:flutter/foundation.dart';
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
    _timer = Timer(const Duration(milliseconds: 2000), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    try {
      final authRepo = Get.find<AuthRepository>();
      final supabaseService = Get.find<SupabaseService>();
      final supabase = supabaseService.client;

      final user = authRepo.currentUser;
      if (user != null) {
        // Proactively refresh expired JWT token
        final session = supabase.auth.currentSession;
        if (session == null || session.isExpired) {
          try {
            debugPrint('Refreshing expired Supabase auth session token...');
            final refreshRes = await supabase.auth.refreshSession();
            if (refreshRes.session == null) {
              throw Exception('No valid session returned from Supabase refresh');
            }
          } catch (refreshErr) {
            debugPrint('Session refresh failed: $refreshErr. Logging out.');
            await SupabaseService.handleSessionExpired('Session refresh failed');
            return;
          }
        }

        final box = Hive.box('settings');
        final loginTimeMs = box.get('login_time') as int?;
        bool isSessionValid = true;

        if (loginTimeMs != null) {
          final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimeMs);
          final diff = DateTime.now().difference(loginTime).inDays;
          if (diff >= 14) {
            isSessionValid = false;
          }
        } else {
          box.put('login_time', DateTime.now().millisecondsSinceEpoch);
        }

        if (isSessionValid) {
          // 1. Respect user's explicit perspective choice saved in Hive settings
          String? roleStr = box.get('lastSelectedRole')?.toString();

          // 2. Validate online profile role from database
          try {
            final data = await supabase
                .from('profiles')
                .select('role')
                .eq('id', user.id)
                .maybeSingle();
            if (data != null && data['role'] != null) {
              roleStr = data['role'].toString();
            }
          } catch (e) {
            final errStr = e.toString().toLowerCase();
            if (errStr.contains('jwt') ||
                errStr.contains('unauthorized') ||
                errStr.contains('pgrst303') ||
                errStr.contains('401')) {
              debugPrint('Auth check failed on startup (JWT expired): $e');
              await SupabaseService.handleSessionExpired('JWT expired on profile check');
              return;
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
              authCtrl.selectedRole.value = matchedRole;
              box.put('lastSelectedRole', matchedRole.name);

              if (matchedRole == AuthRole.admin) {
                Get.offAllNamed('/admin-panel');
              } else {
                Get.offAllNamed('/main-navigation');
              }
              return;
            }
          }
        } else {
          // Session expired after 14 days
          await authRepo.signOut();
          box.delete('login_time');
        }
      }
    } catch (e) {
      debugPrint('Splash session verification failed: $e');
    }
    Get.offAllNamed('/onboarding');
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
