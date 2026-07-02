import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

abstract class AuthRepository {
  /// Check if there is a current user logged in.
  User? get currentUser;

  /// Fetch the profile data for a specific user ID.
  Future<Map<String, dynamic>?> getProfile(String userId);

  /// Send OTP to the shopper's mobile number.
  Future<void> sendOtp(String phone);

  /// Verify the OTP token for the shopper's mobile number.
  Future<User?> verifyOtp(String phone, String token);

  /// Perform Social Sign-In (Native Google or Web-OAuth fallbacks).
  Future<User?> signInWithSocialProvider(String provider);

  /// Sign up a user with email and password.
  Future<User?> signUp({required String email, required String password, String? fullName});

  /// Sign in a user with email and password.
  Future<User?> signInWithPassword({required String email, required String password});

  /// Create a profile record.
  Future<void> createProfile({
    required String userId,
    required String role,
    String? fullName,
    String? vendorId,
    double? height,
    double? weight,
    String? fitPreference,
    List<String>? categories,
  });

  /// Create a vendor record.
  Future<void> createVendor({
    required String id,
    required String brandName,
    required String ownerId,
    required String kycStatus,
  });

  /// Sign out the current user session.
  Future<void> signOut();

  /// Update existing profile body metrics.
  Future<void> updateBodyMetrics({
    required String userId,
    required double height,
    required double weight,
    required String fitPreference,
  });

  /// Update user profile details.
  Future<void> updateProfileDetails({
    required String userId,
    required String fullName,
    String? phone,
    String? avatarUrl,
  });

  /// Upload avatar file.
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  });
}
