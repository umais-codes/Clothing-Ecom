// import 'package:flutter_test/flutter_test.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   test('Test vendor insert RLS', () async {
//     SharedPreferences.setMockInitialValues({});
//     await Supabase.initialize(
//       url: 'https://jkixfvkadkooshtjmnip.supabase.co',
//       anonKey: 'sb_publishable_ol4i-wPIVNhWSw1W6-_BZA_l9UvPWXx',
//     );
//     final supabase = Supabase.instance.client;
    
//     try {
//       final email = 'vendor_test_${DateTime.now().millisecondsSinceEpoch}@yopmail.com';
//       final response = await supabase.auth.signUp(
//         email: email,
//         password: 'password123',
//       );
//       final user = response.user;
//       print('SIGNUP SUCCESS: ${user?.id}');

//       if (user != null) {
//         // We will try to insert a vendor row directly (without a profile row)
//         // Use user.id as the vendor ID to satisfy auth.uid() = id if that is the RLS policy!
//         try {
//           await supabase.from('vendors').insert({
//             'id': user.id,
//             'brand_name': 'RLS Test Brand',
//             'owner_id': user.id,
//             'kyc_status': 'pending',
//           });
//           print('VENDOR INSERT SUCCESS WITHOUT PROFILE');
//         } catch (e) {
//           print('VENDOR INSERT FAILED: $e');
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   });
// }
