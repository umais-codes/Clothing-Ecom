import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
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
      final res = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
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
        final res = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb
              ? null
              : 'io.supabase.velvetmaison://login-callback/',
        );
        if (res) {
          return _supabase.auth.currentUser;
        }
        return null;
      } else if (provider.toLowerCase() == 'apple') {
        final res = await _supabase.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: kIsWeb
              ? null
              : 'io.supabase.velvetmaison://login-callback/',
        );
        if (res) {
          return _supabase.auth.currentUser;
        }
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('Error signing in with social provider: $e');
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<User?> signUp({
    required String email,
    required String password,
    String? fullName,
    String? role,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': ?fullName, 'role': ?role, 'phone': ?phone},
      );
      return response.user;
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<User?> signInWithPassword({
    required String email,
    required String password,
  }) async {
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
    String? phone,
    String? email,
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
        'phone': phone,
        'email': email,
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
    String? cnicDocUrl,
    String? secpDocUrl,
    String? bio,
    String? city,
    String? category,
    String? email,
    String? phone,
    String? ownerName,
  }) async {
    try {
      try {
        await _supabase.from('vendors').insert({
          'id': id,
          'brand_name': brandName,
          'owner_id': ownerId,
          'kyc_status': kycStatus,
          'cnic_doc_url': cnicDocUrl,
          'secp_doc_url': secpDocUrl,
          'bio': bio,
          'city': city,
          'category': category,
          'email': email,
          'phone': phone,
          'owner_name': ownerName,
        });
      } catch (colErr) {
        debugPrint('Inserting extra columns into vendors table failed, falling back to base columns: $colErr');
        await _supabase.from('vendors').insert({
          'id': id,
          'brand_name': brandName,
          'owner_id': ownerId,
          'kyc_status': kycStatus,
          'cnic_doc_url': cnicDocUrl,
          'secp_doc_url': secpDocUrl,
          'bio': bio,
          'city': city,
          'category': category,
        });
      }
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
      // 1. Update metadata in Supabase Auth user record (this always works and acts as a fail-safe fallback)
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'height': height,
            'weight': weight,
            'fit_preference': fitPreference,
          },
        ),
      );

      // 2. Try to update profiles database table
      try {
        await _supabase
            .from('profiles')
            .update({
              'height': height,
              'weight': weight,
              'fit_preference': fitPreference,
            })
            .eq('id', userId);
      } catch (dbError) {
        debugPrint(
          'profiles table update for body metrics failed: $dbError. Saved in metadata.',
        );
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> updateProfileDetails({
    required String userId,
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      // Update metadata in Supabase Auth user record
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'phone': ?phone,
            'avatar_url': ?avatarUrl,
          },
        ),
      );

      // Update profiles database table
      try {
        await _supabase
            .from('profiles')
            .update({
              'full_name': fullName,
              'phone': ?phone,
              'avatar_url': ?avatarUrl,
            })
            .eq('id', userId);
      } catch (dbError) {
        debugPrint(
          'Database update failed, falling back to full_name only: $dbError',
        );
        try {
          await _supabase
              .from('profiles')
              .update({'full_name': fullName})
              .eq('id', userId);
        } catch (fbError) {
          debugPrint(
            'Fallback database update failed silently: $fbError. Profile changes saved in user metadata.',
          );
        }
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_avatar.png';
      final path = '$userId/$fileName';

      try {
        await _supabase.storage.from('avatars').upload(path, file);
        return _supabase.storage.from('avatars').getPublicUrl(path);
      } catch (storageError) {
        debugPrint(
          'Uploading to avatars bucket failed, using fallback rma-evidence: $storageError',
        );
        await _supabase.storage.from('rma-evidence').upload(path, file);
        return _supabase.storage.from('rma-evidence').getPublicUrl(path);
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<String> uploadVendorDocument({
    required String userId,
    required File file,
    required String docType,
  }) async {
    try {
      final ext = file.path.split('.').last;
      final fileName =
          '${docType}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = 'vendor_docs/$userId/$fileName';

      try {
        await _supabase.storage.from('rma-evidence').upload(path, file);
        return _supabase.storage.from('rma-evidence').getPublicUrl(path);
      } catch (_) {
        try {
          await _supabase.storage.from('avatars').upload(path, file);
          return _supabase.storage.from('avatars').getPublicUrl(path);
        } catch (storageError) {
          debugPrint('Upload failed: $storageError');
          return file.path; // Fallback to local file path
        }
      }
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}
