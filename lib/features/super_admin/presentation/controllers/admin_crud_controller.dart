import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/admin_entities.dart';

class AdminCrudController extends GetxController {
  // ── Global Search & Filters ──────────────────────────────────────────────────
  final RxString globalSearchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString selectedCategoryFilter = 'All'.obs;
  final RxString selectedStatusFilter = 'All'.obs;

  // ── Catalog Management ───────────────────────────────────────────────────────
  final RxList<PendingProductEntity> allProducts = <PendingProductEntity>[
    const PendingProductEntity(
      id: 'P-001',
      name: 'Signature Silk Kaftan',
      vendorName: 'House of Linen',
      vendorId: 'V-002',
      price: 12500,
      category: 'Luxury Wear',
      sizes: ['S', 'M', 'L'],
      imageUrl: 'https://picsum.photos/seed/p1/400/500',
      status: ProductStatus.approved,
      description: 'Hand-woven luxury silk with gold thread embroidery.',
    ),
    const PendingProductEntity(
      id: 'P-002',
      name: 'Midnight Velvet Blazer',
      vendorName: 'Threads & Co.',
      vendorId: 'V-001',
      price: 18000,
      category: 'Men\'s Formal',
      sizes: ['40', '42', '44'],
      imageUrl: 'https://picsum.photos/seed/p2/400/500',
      status: ProductStatus.approved,
      description: 'Premium Italian velvet with satin lapels.',
    ),
    const PendingProductEntity(
      id: 'P-003',
      name: 'Desert Bloom Lawn',
      vendorName: 'Zara Couture',
      vendorId: 'V-003',
      price: 4500,
      category: 'Summer Collection',
      sizes: ['Unstitched'],
      imageUrl: 'https://picsum.photos/seed/p3/400/500',
      status: ProductStatus.pending,
      description: '3-piece designer lawn with chiffon dupatta.',
    ),
  ].obs;

  // ── User & Vendor Management ─────────────────────────────────────────────────
  final RxList<AppUserEntity> allUsers = <AppUserEntity>[
    const AppUserEntity(
      id: 'U-9921',
      fullName: 'Sarah Al-Fayed',
      email: 'sarah.fayed@corporate.ae',
      role: UserRole.corporate,
      status: 'Active',
      joinDate: 'Jan 12, 2026',
    ),
    const AppUserEntity(
      id: 'U-9920',
      fullName: 'Bilal Rehman',
      email: 'bilal@houseoflinen.com',
      role: UserRole.vendor,
      status: 'Active',
      joinDate: 'Feb 05, 2026',
    ),
    const AppUserEntity(
      id: 'U-9919',
      fullName: 'Imran Shah',
      email: 'imran.shah@gmail.com',
      role: UserRole.shopper,
      status: 'Suspended',
      joinDate: 'Mar 14, 2026',
    ),
  ].obs;

  // ── Financial Rules Engine ───────────────────────────────────────────────────
  final RxList<FinancialRuleEntity> financialRules = <FinancialRuleEntity>[
    const FinancialRuleEntity(
      id: 'R-001',
      title: 'B2C Platform Commission',
      value: 12.5,
      type: 'Percentage',
      category: 'Commission',
    ),
    const FinancialRuleEntity(
      id: 'R-002',
      title: 'B2B Corporate Fee',
      value: 8.0,
      type: 'Percentage',
      category: 'Commission',
    ),
    const FinancialRuleEntity(
      id: 'R-003',
      title: 'Premium Vendor Tier',
      value: 5000,
      type: 'Fixed Amount',
      category: 'Subscription',
    ),
  ].obs;

  // ── Actions ──────────────────────────────────────────────────────────────────

  void updateProduct(PendingProductEntity product) {
    int index = allProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      allProducts[index] = product;
    } else {
      allProducts.insert(0, product);
    }
    allProducts.refresh();
  }

  void deleteProduct(String id) {
    allProducts.removeWhere((p) => p.id == id);
  }

  void updateUserRole(String userId, UserRole newRole) {
    int index = allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = allUsers[index];
      allUsers[index] = AppUserEntity(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: newRole,
        status: user.status,
        joinDate: user.joinDate,
      );
    }
  }

  void impersonateUser(String userId) {
    Get.snackbar(
      'Impersonation Active',
      'Now viewing platform from user $userId perspective.',
      backgroundColor: const Color(0xFFC19A6B),
      colorText: Colors.white,
    );
  }

  void updateFinancialRule(FinancialRuleEntity rule) {
    int index = financialRules.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      financialRules[index] = rule;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
