import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecom_app/app/theme/app_theme.dart';
import 'package:ecom_app/app/routes/app_pages.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/cart/data/repositories/cart_repository.dart';
import 'package:ecom_app/features/cart/presentation/controllers/cart_controller.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2c_cart_controller.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2b_cart_controller.dart';
import 'package:ecom_app/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:ecom_app/features/discovery/data/repositories/discovery_repository_impl.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:ecom_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecom_app/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:ecom_app/features/wishlist/domain/models/product_model.dart';
import 'package:ecom_app/features/vendor_inventory/data/models/product_variant_model.dart';
import 'package:ecom_app/features/vendor_inventory/data/models/vendor_product_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProductAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ProductVariantAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(VendorProductAdapter());
  }

  await Get.putAsync(() => SupabaseService().init());

  final cartRepo = CartRepository();
  await cartRepo.init();
  await Hive.openBox('settings');

  Get.put(B2CCartController(cartRepo), permanent: true);
  Get.put(B2BCartController(cartRepo), permanent: true);
  Get.put(CartController(cartRepo), permanent: true);
  final authRepo = Get.put<AuthRepository>(
    AuthRepositoryImpl(),
    permanent: true,
  );
  Get.put(AuthController(authRepo), permanent: true);
  Get.put<DiscoveryRepository>(DiscoveryRepositoryImpl(), permanent: true);

  runApp(const EcomApp());
}

class EcomApp extends StatelessWidget {
  const EcomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Valvet Maison',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      builder: (context, child) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            final primaryFocus = FocusManager.instance.primaryFocus;
            if (primaryFocus != null && primaryFocus.hasFocus) {
              primaryFocus.unfocus();
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              final primaryFocus = FocusManager.instance.primaryFocus;
              if (primaryFocus != null && primaryFocus.hasFocus) {
                primaryFocus.unfocus();
              }
            },
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
