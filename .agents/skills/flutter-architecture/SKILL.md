---
name: flutter-architecture
description: >
  Flutter Clean Architecture + GetX best practices for the ecom_app project.
  Use this skill when scaffolding new features, adding controllers, defining
  repository contracts, registering dependencies, configuring routes, or
  reviewing structural correctness. Covers the project's exact folder layout,
  GetX patterns (controllers, bindings, services), routing, dependency injection,
  and code quality rules.
---

# Flutter Architecture Best Practices — ecom_app

## 1. Architecture Overview

The project uses **Clean Architecture** layered with **GetX** for state management,
dependency injection, and navigation.

```
lib/
├── app/                    # App-wide shared infrastructure
│   ├── middleware/         # Route guards (AdminGuard, AuthGuard)
│   ├── routes/             # AppRoutes (constants) + AppPages (GetPage list)
│   ├── theme/              # AppColors, AppTheme
│   ├── utils/              # Responsive, constants, asset util
│   ├── validations/        # AppValidator (form validation)
│   └── widgets/            # Shared reusable widgets
│
├── core/                   # Cross-cutting concerns
│   ├── supabase/           # SupabaseService singleton
│   └── error/              # ErrorHandler
│
├── features/               # Vertical feature slices
│   └── <feature_name>/
│       ├── controllers/            # GetX controllers (UI state + logic)
│       ├── data/
│       │   ├── models/             # Data transfer objects (fromMap/toMap)
│       │   └── repositories/      # *_repository_impl.dart (Supabase calls)
│       ├── domain/
│       │   ├── entities/          # Pure Dart business entities
│       │   └── repositories/      # Abstract repository interfaces
│       └── presentation/
│           ├── bindings/          # GetX bindings (DI per route)
│           ├── screens/ or views/ # Screen widgets
│           └── widgets/           # Feature-local widgets
│
└── main.dart               # Bootstrap — Supabase init, global DI, runApp
```

---

## 2. Layer Responsibilities

| Layer | Responsibility | May import |
|---|---|---|
| `presentation/` | Build UI, react to observable state | `controllers/`, app widgets, AppColors |
| `controllers/` | UI logic, observable state, calls repo | `domain/repositories/` |
| `domain/` | Business contracts and pure entities | Nothing from Flutter/Supabase |
| `data/` | External data access (Supabase, Hive) | `domain/`, `core/supabase/`, `core/error/` |
| `core/` | Shared infrastructure | Flutter internals only |

**Forbidden imports:**
- `presentation/` must NOT import `data/repositories/` directly
- `domain/` must NOT import `supabase_flutter`, `hive`, `get`
- `controllers/` must NOT call `_supabase` directly

---

## 3. Feature Slice — Full Template

### 3a. Domain Layer

```dart
// features/orders/domain/entities/order_entity.dart
class OrderEntity {
  final String id;
  final String userId;
  final double total;
  final String status;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
  });
}
```

```dart
// features/orders/domain/repositories/order_repository.dart
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders(String userId);
  Future<void> createOrder(OrderEntity order);
  Future<void> updateOrderStatus(String orderId, String status);
}
```

### 3b. Data Layer

```dart
// features/orders/data/models/order_model.dart
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.total,
    required super.status,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'total': total,
    'status': status,
  };
}
```

```dart
// features/orders/data/repositories/order_repository_impl.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/core/error/error_handler.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

  @override
  Future<List<OrderEntity>> getOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response.map((m) => OrderModel.fromMap(m)).toList();
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> createOrder(OrderEntity order) async {
    try {
      await _supabase.from('orders').insert(
        OrderModel(
          id: order.id,
          userId: order.userId,
          total: order.total,
          status: order.status,
        ).toMap(),
      );
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}
```

### 3c. Controller

```dart
// features/orders/controllers/order_controller.dart
import 'package:get/get.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/entities/order_entity.dart';

class OrderController extends GetxController {
  final OrderRepository _repo;
  OrderController(this._repo);

  final RxList<OrderEntity> orders = <OrderEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<AuthController>().currentUser;
    if (user != null) fetchOrders(user.id);
  }

  Future<void> fetchOrders(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repo.getOrders(userId);
      orders.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders(String userId) => fetchOrders(userId);
}
```

### 3d. Binding

```dart
// features/orders/presentation/bindings/order_binding.dart
import 'package:get/get.dart';
import '../../domain/repositories/order_repository.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../controllers/order_controller.dart';

class OrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => OrderRepositoryImpl());
    Get.lazyPut<OrderController>(
      () => OrderController(Get.find<OrderRepository>()),
    );
  }
}
```

### 3e. Route Registration (app_routes.dart + app_pages.dart)

```dart
// 1. Add constant in app_routes.dart
abstract class AppRoutes {
  // ... existing routes
  static const orders = '/orders';
}

// 2. Add GetPage in app_pages.dart
GetPage(
  name: AppRoutes.orders,
  page: () => const OrdersScreen(),
  binding: OrderBinding(),
  transition: Transition.fadeIn,
),
```

---

## 4. GetX Controller Patterns

### Observable State Types

```dart
// Primitives
final RxBool isLoading = false.obs;
final RxString errorMessage = ''.obs;
final RxInt selectedIndex = 0.obs;
final RxDouble totalPrice = 0.0.obs;

// Nullable
final Rxn<UserProfile> profile = Rxn<UserProfile>();

// Lists
final RxList<Product> products = <Product>[].obs;

// Maps
final RxMap<String, dynamic> filters = <String, dynamic>{}.obs;
```

### Lifecycle Hooks

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Called when controller is first registered
    // Safe to access Get.find<OtherController>() here
    loadData();
  }

  @override
  void onReady() {
    super.onReady();
    // Called after first frame — safe for navigation/dialogs
  }

  @override
  void onClose() {
    // Cancel streams, timers, dispose TextEditingControllers
    _subscription?.cancel();
    textController.dispose();
    super.onClose();
  }
}
```

### TextEditingController Disposal

Always dispose in `onClose()`:

```dart
final TextEditingController nameController = TextEditingController();
final TextEditingController emailController = TextEditingController();

@override
void onClose() {
  nameController.dispose();
  emailController.dispose();
  super.onClose();
}
```

### Accessing Other Controllers

```dart
// Already registered (permanent)
final authCtrl = Get.find<AuthController>();

// Might not be registered yet — guard it
if (Get.isRegistered<AdminCrudController>()) {
  final adminCtrl = Get.find<AdminCrudController>();
}
```

---

## 5. Dependency Injection Rules

### Permanent (Global) — Register in main.dart

For services and repositories that live for the full app lifetime:

```dart
// main.dart — always permanent: true
await Get.putAsync(() => SupabaseService().init());

Get.put<MyRepository>(MyRepositoryImpl(), permanent: true);
Get.put(MyController(Get.find<MyRepository>()), permanent: true);
```

### Lazy (Route-Scoped) — Register in Bindings

For feature controllers that should be created on demand and cleaned up on route pop:

```dart
// In a Binding class
Get.lazyPut<OrderRepository>(() => OrderRepositoryImpl());
Get.lazyPut<OrderController>(() => OrderController(Get.find()));
```

**Rule**: Never `Get.put` a scoped controller in `main.dart` — use bindings.

### Registration Order

Always register dependencies BEFORE things that depend on them:

```dart
// Correct — repo first, then controller
Get.put<AuthRepository>(AuthRepositoryImpl(), permanent: true);
Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);

// Wrong — controller registered before its dependency
Get.put(AuthController(AuthRepositoryImpl()), permanent: true); // tight coupling
```

---

## 6. Routing & Navigation

### AppRoutes — Route Constants

All route strings must be declared in `lib/app/routes/app_routes.dart`:

```dart
abstract class AppRoutes {
  static const myNewRoute = '/my-new-route';
}
```

Never hardcode route strings like `Get.toNamed('/my-screen')` in widget code.

### AppPages — Page Registrations

All `GetPage` entries must be in `lib/app/routes/app_pages.dart`:

```dart
GetPage(
  name: AppRoutes.myNewRoute,
  page: () => const MyScreen(),
  binding: MyBinding(),
  transition: Transition.fadeIn,  // default transition for this app
),
```

### Navigation Methods

```dart
// Push (adds to stack)
Get.toNamed(AppRoutes.productDetails, arguments: {'id': product.id})

// Replace current route
Get.offNamed(AppRoutes.mainNavigation)

// Clear entire stack
Get.offAllNamed(AppRoutes.splash)

// Back
Get.back()
Get.back(result: someReturnValue)

// Read arguments on destination
final args = Get.arguments as Map<String, dynamic>;
final id = args['id'] as String;
```

### Route Guards (Middleware)

```dart
// In AppPages
GetPage(
  name: AppRoutes.adminPanel,
  page: () => const AdminMainLayout(),
  binding: AdminBinding(),
  middlewares: [AdminGuard()],
),
```

---

## 7. Presentation Layer Patterns

### Screen with Obx

```dart
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = context.screenWidth;
    final ctrl = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: CustomAppBar(title: 'My Orders'),
      body: Obx(() {
        if (ctrl.isLoading.value) return _buildShimmer(sw);
        if (ctrl.errorMessage.value.isNotEmpty) {
          return _buildError(ctrl.errorMessage.value, ctrl.refreshOrders);
        }
        if (ctrl.orders.isEmpty) return _buildEmpty(sw);
        return _buildList(sw, ctrl.orders);
      }),
    );
  }
}
```

### Use `Obx` Not `GetX` Widget

```dart
// Preferred — concise
Obx(() => Text(ctrl.count.toString()))

// Avoid unless you need the controller instance inside
GetX<MyController>(builder: (ctrl) => Text(ctrl.count.toString()))
```

### StatelessWidget Over StatefulWidget

Always prefer `StatelessWidget`. Use `StatefulWidget` only when you need
`initState` / `dispose` for something that GetX cannot manage (rare).

### Widget Decomposition

Keep `build` methods short. Extract sub-sections into private methods or
dedicated widgets:

```dart
// Good
Widget build(BuildContext context) {
  return Column(children: [
    _buildHeader(sw),
    _buildProductGrid(sw),
    _buildCheckoutBar(sw),
  ]);
}

// Bad — 200 line build method
```

---

## 8. File & Class Naming Conventions

| Type | File name | Class name |
|---|---|---|
| Repository interface | `order_repository.dart` | `OrderRepository` |
| Repository impl | `order_repository_impl.dart` | `OrderRepositoryImpl` |
| Entity | `order_entity.dart` | `OrderEntity` |
| Model | `order_model.dart` | `OrderModel` |
| Controller | `order_controller.dart` | `OrderController` |
| Binding | `order_binding.dart` | `OrderBinding` |
| Screen | `orders_screen.dart` | `OrdersScreen` |
| Widget | `order_card_widget.dart` | `OrderCardWidget` |

**Always:** `snake_case` for files, `PascalCase` for classes, `camelCase` for methods/variables.

---

## 9. Enum Usage

Define enums at the top of the relevant file (or in a shared enums file for widely used ones):

```dart
// In controller file (feature-local)
enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

enum AuthRole { shopper, vendor, corporate, admin }

enum AuthStatus { initial, loading, success, pendingApproval, error }
```

Use enums instead of raw strings for status comparisons.

---

## 10. Error Handling Convention

```dart
// In repositories — always translate with ErrorHandler
try {
  // Supabase call
} catch (e) {
  throw Exception(ErrorHandler.getErrorMessage(e));
}

// In controllers — always strip Exception prefix before showing
try {
  await _repo.doSomething();
} catch (e) {
  errorMessage.value = e.toString().replaceFirst('Exception: ', '');
}

// In UI — never show raw exception messages
Obx(() => ctrl.errorMessage.value.isNotEmpty
    ? Text(ctrl.errorMessage.value, style: ...)
    : const SizedBox.shrink())
```

---

## 11. Code Quality Rules

### Dart Best Practices

```dart
// Use final for everything that does not change
final String name = 'Umais';

// Use const constructors wherever possible
const SizedBox(height: 16)
const EdgeInsets.symmetric(horizontal: 16)

// Use null-safe access
final text = map['key']?.toString() ?? 'default';

// Prefer early returns over deeply nested ifs
if (user == null) return;
// ... rest of code

// Avoid long parameter lists — use named params
void createOrder({
  required String userId,
  required double total,
  String status = 'pending',
}) {}
```

### Import Order (Dart convention)

```dart
// 1. dart: imports
import 'dart:io';

// 2. package: imports (external)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 3. package: imports (internal — ecom_app)
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

// 4. Relative imports
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';
```

---

## 12. Quick Scaffold Checklist

When creating a new feature from scratch:

- [ ] **Domain** — Create entity in `domain/entities/`
- [ ] **Domain** — Create abstract repository interface in `domain/repositories/`
- [ ] **Data** — Create model (extends entity) in `data/models/`
- [ ] **Data** — Implement repository in `data/repositories/*_impl.dart`
- [ ] **Controllers** — Create GetX controller with `isLoading`, `errorMessage`
- [ ] **Binding** — Create `*_binding.dart` with `lazyPut` registrations
- [ ] **Routes** — Add constant to `AppRoutes`, add `GetPage` to `AppPages`
- [ ] **Presentation** — Build screen/widgets using AppColors + Responsive
- [ ] **main.dart** — Register only if the controller needs to be permanent/global
- [ ] **Supabase** — Add RLS policies for any new tables in Supabase Dashboard
