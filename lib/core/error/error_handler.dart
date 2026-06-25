import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('invalid email or password')) {
        return 'The email or password you entered is incorrect.';
      } else if (msg.contains('user already exists') || msg.contains('already registered')) {
        return 'An account with this email already exists.';
      } else if (msg.contains('invalid otp') || msg.contains('otp incorrect')) {
        return 'The verification code is incorrect. Please check and try again.';
      } else if (msg.contains('otp expired') || msg.contains('expired otp')) {
        return 'The verification code has expired. Please request a new one.';
      } else if (msg.contains('too many requests')) {
        return 'Too many attempts. Please try again in a few minutes.';
      }
      return error.message;
    } else if (error is PostgrestException) {
      return 'Database operations failed. Please try again later.';
    } else if (error is FormatException) {
      return 'Data format is invalid.';
    }
    
    final errStr = error?.toString() ?? '';
    if (errStr.contains('network') || errStr.contains('socketexception') || errStr.contains('failed host lookup')) {
      return 'Network connection issue. Please check your internet connection.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}
