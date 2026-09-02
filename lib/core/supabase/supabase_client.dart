import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';

class SupabaseService extends GetxService {
  // Replace these with your actual live Supabase Project Credentials
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jkixfvkadkooshtjmnip.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_ol4i-wPIVNhWSw1W6-_BZA_l9UvPWXx',
  );

  late final SupabaseClient client;
  static bool _isHandlingExpired = false;

  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
    );
    client = Supabase.instance.client;

    // Listen to global auth state transitions
    client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        debugPrint('Supabase Auth: User Signed Out');
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        debugPrint('Supabase Auth: JWT Token Successfully Refreshed');
      }
    });

    return this;
  }

  /// Global handler for expired JWT / 401 Unauthorized errors across any controller or service
  static Future<void> handleSessionExpired([String? reason]) async {
    if (_isHandlingExpired) return;
    _isHandlingExpired = true;

    try {
      debugPrint('🚨 Session Expired Triggered ($reason). Signing out cleanly...');
      if (Get.isRegistered<SupabaseService>()) {
        await Get.find<SupabaseService>().client.auth.signOut();
      }
    } catch (_) {}

    // Navigate cleanly to onboarding/sign in screen
    Get.offAllNamed('/onboarding');

    AppSnackbar.warning(
      title: 'Session Expired',
      message: 'Your login session has expired. Please sign in again.',
    );

    Future.delayed(const Duration(seconds: 2), () {
      _isHandlingExpired = false;
    });
  }
}
