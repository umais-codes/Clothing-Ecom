import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  // Replace these with your actual live Supabase Project Credentials
  static const String supabaseUrl = 'https://placeholder.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholderAnonKey';

  late final SupabaseClient client;

  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
    client = Supabase.instance.client;
    return this;
  }
}
