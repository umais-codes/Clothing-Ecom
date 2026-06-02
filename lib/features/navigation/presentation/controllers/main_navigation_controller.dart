import 'package:ecom_app/features/cart/presentation/screens/b2b_cart_screen.dart';
import 'package:ecom_app/features/cart/presentation/screens/b2c_cart_screen.dart';
import 'package:ecom_app/features/vendor_orders/presentation/views/vendor_orders_view.dart';
import 'package:ecom_app/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:ecom_app/features/vendor_dashboard/presentation/views/vendor_dashboard_view.dart';
import 'package:ecom_app/features/b2b_portal/presentation/views/b2b_portal_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';
import 'package:ecom_app/features/home/presentation/views/home_view.dart';
import 'package:ecom_app/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:ecom_app/features/profile/presentation/views/profile_view.dart';
import 'package:ecom_app/features/vendor_inventory/presentation/views/inventory_view.dart';

class MainNavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final RxList<Widget> pages = <Widget>[].obs;

  AuthRole get currentRole => Get.find<AuthController>().selectedRole.value;

  @override
  void onInit() {
    super.onInit();
    _initializePages();

    ever(Get.find<AuthController>().selectedRole, (_) {
      _initializePages();
      selectedIndex.value = 0;
    });
  }

  void _initializePages() {
    if (currentRole == AuthRole.vendor) {
      pages.assignAll([
        const VendorDashboardView(),
        const InventoryView(),
        const VendorOrdersView(),
        const ProfileView(),
      ]);
    } else if (currentRole == AuthRole.corporate) {
      pages.assignAll([
        const B2BPortalView(),
        DiscoveryScreen(),
        const WishlistScreen(),
        const B2BCartScreen(),
        const ProfileView(),
      ]);
    } else {
      pages.assignAll([
        const HomeView(),
        DiscoveryScreen(),
        const WishlistScreen(),
        const B2CCartScreen(),
        const ProfileView(),
      ]);
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  List<NavigationItemData> get navItems {
    if (currentRole == AuthRole.vendor) {
      return [
        NavigationItemData(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: 'Dashboard',
        ),
        NavigationItemData(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: 'Inventory',
        ),
        NavigationItemData(
          icon: Icons.assignment_outlined,
          activeIcon: Icons.assignment_rounded,
          label: 'Orders',
        ),
        NavigationItemData(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Profile',
        ),
      ];
    } else if (currentRole == AuthRole.corporate) {
      return [
        NavigationItemData(
          icon: Icons.business_outlined,
          activeIcon: Icons.business_rounded,
          label: 'Sourcing',
        ),
        NavigationItemData(
          icon: Icons.auto_awesome_outlined,
          activeIcon: Icons.auto_awesome_rounded,
          label: 'Discover',
        ),
        NavigationItemData(
          icon: Icons.favorite_outline_rounded,
          activeIcon: Icons.favorite_rounded,
          label: 'Wishlist',
        ),
        NavigationItemData(
          icon: Icons.shopping_bag_outlined,
          activeIcon: Icons.shopping_bag_rounded,
          label: 'Cart',
          hasBadge: true,
        ),
        NavigationItemData(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Profile',
        ),
      ];
    } else {
      return [
        NavigationItemData(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Home',
        ),
        NavigationItemData(
          icon: Icons.auto_awesome_outlined,
          activeIcon: Icons.auto_awesome_rounded,
          label: 'Discover',
        ),
        NavigationItemData(
          icon: Icons.favorite_outline_rounded,
          activeIcon: Icons.favorite_rounded,
          label: 'Wishlist',
        ),
        NavigationItemData(
          icon: Icons.shopping_bag_outlined,
          activeIcon: Icons.shopping_bag_rounded,
          label: 'Cart',
          hasBadge: true,
        ),
        NavigationItemData(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Profile',
        ),
      ];
    }
  }
}

class NavigationItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool hasBadge;

  NavigationItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.hasBadge = false,
  });
}
