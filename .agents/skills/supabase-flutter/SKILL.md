---
name: supabase-flutter
description: >
  Comprehensive guide for all Supabase backend operations in the ecom_app Flutter project.
  Use this skill whenever you need to add, modify, or debug any feature that touches Supabase:
  authentication, database queries, storage uploads, realtime subscriptions, or RLS policies.
  Covers project-specific architecture (GetX + Clean Architecture), existing patterns, and Flutter best practices.
---

# Supabase + Flutter Skill — ecom_app

## 1. Project Tech Stack (Always Respect)

| Layer | Technology |
|---|---|
| Flutter SDK | ^3.11.4 |
| State Management | GetX ^4.7.3 |
| Supabase | supabase_flutter ^2.8.0 |
| Local Cache | Hive ^2.2.3 / hive_flutter ^1.1.0 |
| HTTP (custom) | Dio ^5.9.2 |
| Auth | Supabase Auth (OTP, Email/Password, Google OAuth, Apple OAuth) |
| Storage | Supabase Storage (buckets: vatars, ma-evidence, vendor docs) |

---

## 2. Architecture — Clean Architecture with GetX

Every feature MUST follow this folder structure:

`
lib/features/<feature_name>/
├── controllers/              # GetX controllers (UI logic, state)
├── data/
│   ├── models/               # Data models (fromMap / toMap)
│   └── repositories/         # *_repository_impl.dart — Supabase calls live here
├── domain/
│   ├── entities/             # Pure Dart entities (no Supabase dependency)
│   └── repositories/         # Abstract repository interfaces
└── presentation/
    ├── screens/
    └── widgets/
`

**Rule**: Supabase calls ONLY belong in data/repositories/*_repository_impl.dart. Controllers must NEVER call _supabase directly.

---

## 3. SupabaseService — Singleton Access Pattern

The project uses a GetX service singleton. ALWAYS access the client this way:

`dart
// In any repository implementation:
final SupabaseClient _supabase = Get.find<SupabaseService>().client;
`

Never call Supabase.instance.client directly elsewhere in the codebase. Use the registered service.

**SupabaseService** is initialized in main.dart:
`dart
await Get.putAsync(() => SupabaseService().init());
`

---

## 4. Repository Implementation Pattern

Every *_repository_impl.dart MUST follow this pattern:

`dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/core/error/error_handler.dart';
import '../../domain/repositories/my_feature_repository.dart';

class MyFeatureRepositoryImpl implements MyFeatureRepository {
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

  @override
  Future<SomeModel?> fetchSomething(String id) async {
    try {
      final res = await _supabase
          .from('table_name')
          .select()
          .eq('id', id)
          .maybeSingle();
      return res != null ? SomeModel.fromMap(res) : null;
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}
`

**Critical rules:**
- Always wrap Supabase calls in 	ry/catch.
- Always rethrow with 	hrow Exception(ErrorHandler.getErrorMessage(e)).
- Use .maybeSingle() instead of .single() to avoid exceptions on empty results.
- Use .select('col1, col2') to specify columns explicitly (performance).

---

## 5. ErrorHandler — Central Error Mapping

Located at lib/core/error/error_handler.dart. ALWAYS use it:

`dart
// Correct
throw Exception(ErrorHandler.getErrorMessage(e));

// Wrong — never expose raw Supabase errors to controllers
throw Exception(e.toString());
`

ErrorHandler.getErrorMessage(e) handles:
- AuthException — user-friendly auth messages
- PostgrestException — database error messages
- FormatException — data format errors
- Network errors (socket/DNS failures)

When you add new error cases, extend ErrorHandler, do NOT add error logic in repositories.

---

## 6. Database Query Patterns

### Basic CRUD

`dart
// SELECT all rows
final List<Map<String, dynamic>> rows = await _supabase
    .from('products')
    .select();

// SELECT with filter
final row = await _supabase
    .from('profiles')
    .select('id, full_name, role, avatar_url')
    .eq('id', userId)
    .maybeSingle();

// INSERT
await _supabase.from('orders').insert({
  'user_id': userId,
  'status': 'pending',
  'total': total,
});

// UPSERT (insert or update)
await _supabase.from('profiles').upsert({
  'id': userId,
  'full_name': fullName,
  'updated_at': DateTime.now().toIso8601String(),
});

// UPDATE with filter
await _supabase
    .from('products')
    .update({'status': 'approved'})
    .eq('id', productId);

// DELETE
await _supabase
    .from('orders')
    .delete()
    .eq('id', orderId);
`

### Advanced Patterns

`dart
// Pagination (critical for large tables like products/orders)
final rows = await _supabase
    .from('products')
    .select()
    .eq('is_b2b', false)
    .range(offset, offset + pageSize - 1)
    .order('created_at', ascending: false);

// Joins / Foreign key relations
final orders = await _supabase
    .from('orders')
    .select('*, order_items(*, products(name, image_url))')
    .eq('user_id', userId);

// Full text search
final results = await _supabase
    .from('products')
    .select()
    .textSearch('name', query, config: 'english');

// Multiple filters
final products = await _supabase
    .from('products')
    .select()
    .eq('category', category)
    .eq('status', 'approved')
    .gte('price', minPrice)
    .lte('price', maxPrice);

// Count
final count = await _supabase
    .from('products')
    .count()
    .eq('vendor_id', vendorId);
`

---

## 7. Authentication Patterns

### Email/Password

`dart
// Sign Up
final response = await _supabase.auth.signUp(
  email: email,
  password: password,
  data: {'full_name': fullName, 'role': role},
);

// Sign In
final response = await _supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Sign Out
await _supabase.auth.signOut();

// Current user (synchronous)
final user = _supabase.auth.currentUser;
`

### OTP (Phone)

`dart
// Send OTP
await _supabase.auth.signInWithOtp(phone: phone);

// Verify OTP
final res = await _supabase.auth.verifyOTP(
  type: OtpType.sms,
  token: token,
  phone: phone,
);
`

### Google OAuth (Native preferred)

`dart
// 1. Try native Google Sign-In first
final googleUser = await GoogleSignIn(...).signIn();
final googleAuth = await googleUser!.authentication;
final response = await _supabase.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken: googleAuth.idToken!,
  accessToken: googleAuth.accessToken,
);

// 2. Fallback to web-based OAuth
await _supabase.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: 'io.supabase.ecomapp://login-callback',
);
`

### Auth State Listening (in controllers)

`dart
late final StreamSubscription<AuthState> _authSubscription;

@override
void onInit() {
  super.onInit();
  _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    if (session == null) {
      Get.offAllNamed(Routes.AUTH);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  });
}

@override
void onClose() {
  _authSubscription.cancel();
  super.onClose();
}
`

---

## 8. Storage Patterns

### Upload File

`dart
final path = '/_avatar.png';
await _supabase.storage.from('avatars').upload(path, file);
final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
`

### Upload with Graceful Fallback (project pattern)

`dart
try {
  await _supabase.storage.from('avatars').upload(path, file);
  return _supabase.storage.from('avatars').getPublicUrl(path);
} catch (_) {
  await _supabase.storage.from('rma-evidence').upload(path, file);
  return _supabase.storage.from('rma-evidence').getPublicUrl(path);
}
`

### Existing Storage Buckets

| Bucket | Purpose |
|---|---|
| vatars | User profile photos |
| ma-evidence | Return/vendor documents (shared fallback) |

### Upload from Web (Bytes)

`dart
await _supabase.storage.from('products').uploadBinary(
  path,
  fileBytes,
  fileOptions: const FileOptions(contentType: 'image/jpeg'),
);
`

---

## 9. Realtime Subscriptions

`dart
late final RealtimeChannel _channel;

void _subscribeToOrders(String vendorId) {
  _channel = _supabase
      .channel('vendor_orders_')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: FilterType.eq,
          column: 'vendor_id',
          value: vendorId,
        ),
        callback: (payload) {
          fetchOrders();
        },
      )
      .subscribe();
}

@override
void onClose() {
  _supabase.removeChannel(_channel);
  super.onClose();
}
`

Note: The project configures eventsPerSecond: 10 in RealtimeClientOptions. Do not change this.

---

## 10. Data Models — fromMap / toMap Convention

`dart
class Product {
  final String id;
  final String name;
  final double price;
  final bool isB2B;

  const Product({required this.id, required this.name, required this.price, required this.isB2B});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Product',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      // Handle bool as int (0/1) or string 'true'/'false' from Supabase
      isB2B: map['is_b2b'] == true || map['is_b2b'] == 1 || map['is_b2b'] == 'true',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'is_b2b': isB2B,
  };
}
`

Key rules for fromMap:
- Always null-coalesce: ?. with defaults.
- Cast numerics: (map['field'] as num?)?.toDouble().
- Handle booleans in all three forms: 	rue, 1, 'true'.
- Use ?.toString() ?? '' for strings.

---

## 11. GetX Controller Pattern for Supabase Data

`dart
class ProductController extends GetxController {
  final ProductRepository _repo;
  ProductController(this._repo);

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repo.getProducts();
      products.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
`

Rules:
- Always use RxBool isLoading and RxString errorMessage.
- Always call isLoading.value = false in inally.
- Strip 'Exception: ' prefix before displaying.

---

## 12. Known Database Tables

| Table | Key Columns |
|---|---|
| profiles | id, ull_name, ole, vatar_url, phone, email, height, weight, it_preference, shopping_categories, endor_id |
| endors | id, rand_name, owner_id, kyc_status, cnic_doc_url, secp_doc_url, io, city, category, email, phone, owner_name |
| products | id, 
ame, price, status, is_b2b, endor_id, category, image_url, description, sizes, colors, moq |
| orders | id, user_id, endor_id, status, 	otal, created_at |
| order_items | id, order_id, product_id, quantity, price |

Always verify actual schema in Supabase Dashboard before writing new queries.

---

## 13. Row Level Security (RLS) Guidance

Every table MUST have RLS enabled.

`sql
-- Enable RLS
ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;

-- User-scoped read
CREATE POLICY "Users can read own data"
  ON new_table FOR SELECT
  USING (auth.uid() = user_id);

-- User-scoped insert
CREATE POLICY "Users can insert own data"
  ON new_table FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Vendor-scoped
CREATE POLICY "Vendors can read their products"
  ON products FOR SELECT
  USING (vendor_id = (SELECT id FROM vendors WHERE owner_id = auth.uid()));

-- Admin bypass via JWT role claim
CREATE POLICY "Admins can do anything"
  ON new_table FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');
`

Roles: shopper, endor, corporate, dmin / super_admin.

---

## 14. Environment Configuration

`dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://jkixfvkadkooshtjmnip.supabase.co',
);
`

To override in CI/CD or staging:
`powershell
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key
`

Never commit service_role keys. Only the publishable (anon) key belongs in client code.

---

## 15. Hive + Supabase Cache-First Pattern

`dart
Future<List<Product>> getProducts() async {
  try {
    final response = await _supabase.from('products').select();
    final products = response.map((m) => Product.fromMap(m)).toList();
    final box = Hive.box('productsCache');
    await box.put('all', response);
    return products;
  } catch (_) {
    final box = Hive.box('productsCache');
    final cached = box.get('all') as List?;
    if (cached != null) {
      return cached.map((m) => Product.fromMap(Map<String, dynamic>.from(m))).toList();
    }
    return [];
  }
}
`

---

## 16. Common Pitfalls

- Use .maybeSingle() never .single() — .single() throws on 0 or 2+ rows.
- Never access _supabase before SupabaseService is initialized.
- Use onClose() not dispose() for cleanup in GetX controllers.
- Cast 
um to double: (map['price'] as num?)?.toDouble().
- Always .toIso8601String() for timestamp fields.
- Use debugPrint not print.
- Guard optional controller finds: if (Get.isRegistered<T>()) Get.find<T>().

---

## 17. Dependency Registration in main.dart

`dart
// Always use permanent: true for core repositories
final myRepo = Get.put<MyRepository>(
  MyRepositoryImpl(),
  permanent: true,
);
Get.put(MyController(myRepo), permanent: true);
`

Registration order matters — repositories before controllers.

---

## 18. File Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Repository Interface | <feature>_repository.dart | uth_repository.dart |
| Repository Impl | <feature>_repository_impl.dart | uth_repository_impl.dart |
| Controller | <feature>_controller.dart | uth_controller.dart |
| Model | <feature>_model.dart | product_model.dart |
| Screen | <name>_screen.dart | login_screen.dart |
| Widget | <name>_widget.dart | product_card_widget.dart |

All filenames use snake_case. Classes use PascalCase.

---

## 19. Quick Implementation Checklist

When adding a new Supabase-backed feature:

- [ ] Create domain repository interface in domain/repositories/
- [ ] Create model in data/models/ with romMap / 	oMap
- [ ] Implement repository in data/repositories/*_impl.dart
  - [ ] Access client via Get.find<SupabaseService>().client
  - [ ] Wrap all calls in 	ry/catch with ErrorHandler
  - [ ] Use .maybeSingle() for single-row queries
- [ ] Create GetX controller in controllers/
  - [ ] RxBool isLoading, RxString errorMessage
  - [ ] inally { isLoading.value = false; }
  - [ ] Cancel stream subscriptions in onClose()
- [ ] Register repo + controller in main.dart with permanent: true
- [ ] Add RLS policies in Supabase Dashboard for new tables
- [ ] Test with both connected and offline (Hive fallback) scenarios
