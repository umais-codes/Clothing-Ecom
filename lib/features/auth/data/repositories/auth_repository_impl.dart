import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/core/error/error_handler.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final res = await _supabase.from('profiles').select().eq('id', userId).maybeSingle();
      return res;
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<User?> verifyOtp(String phone, String token) async {
    try {
      final res = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: token,
        phone: phone,
      );
      return res.user;
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<User?> signInWithSocialProvider(String provider) async {
    try {
      if (provider.toLowerCase() == 'google') {
        try {
          const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
          const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

          final GoogleSignIn googleSignIn = GoogleSignIn(
            clientId: iosClientId.isNotEmpty ? iosClientId : null,
            serverClientId: webClientId.isNotEmpty ? webClientId : null,
          );

          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            return null; // User cancelled native sign-in dialog
          }

          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final idToken = googleAuth.idToken;
          final accessToken = googleAuth.accessToken;

          if (idToken == null) {
            throw Exception('Google Sign-In succeeded but did not return an ID Token.');
          }

          final response = await _supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );
          return response.user;
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
        throw Exception('Unsupported provider');
      }

      // Web-based OAuth Redirect fallback
      await _supabase.auth.signInWithOAuth(
        oauthProvider,
        redirectTo: 'io.supabase.ecomapp://login-callback',
      );
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<User?> signUp({required String email, required String password, String? fullName}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response.user;
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<User?> signInWithPassword({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> createProfile({
    required String userId,
    required String role,
    String? fullName,
    String? vendorId,
    double? height,
    double? weight,
    String? fitPreference,
    List<String>? categories,
  }) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'full_name': fullName ?? 'User',
        'role': role,
        'vendor_id': vendorId,
        'height': height,
        'weight': weight,
        'fit_preference': fitPreference,
        'shopping_categories': categories,
      });
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> createVendor({
    required String id,
    required String brandName,
    required String ownerId,
    required String kycStatus,
  }) async {
    try {
      await _supabase.from('vendors').insert({
        'id': id,
        'brand_name': brandName,
        'owner_id': ownerId,
        'kyc_status': kycStatus,
      });
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> updateBodyMetrics({
    required String userId,
    required double height,
    required double weight,
    required String fitPreference,
  }) async {
    try {
      await _supabase.from('profiles').update({
        'height': height,
        'weight': weight,
        'fit_preference': fitPreference,
      }).eq('id', userId);
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}
