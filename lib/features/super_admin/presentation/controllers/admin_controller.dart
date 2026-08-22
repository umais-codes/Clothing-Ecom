import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/app/utils/asset_downloader_util.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class AdminController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    loadPendingApplications();
  }

  final RxBool isLoadingKyc = false.obs;
  final RxString kycError = ''.obs;

  Future<void> loadPendingApplications() async {
    isLoadingKyc.value = true;
    kycError.value = '';
    // Load pending Applications (both Vendor and Corporate) from Supabase
    try {
      final supabase = Get.find<SupabaseService>().client;
      final res = await supabase
          .from('vendors')
          .select('*')
          .eq('kyc_status', 'pending');

      final Map<String, KycVendorEntity> existingQueue = {
        for (var v in kycQueue) v.id: v,
      };
      kycQueue.clear();

      final items = res as List;

      // Fetch corresponding profiles in a separate query to avoid joint Postgrest issues
      final ownerIds = items
          .map((item) => item['owner_id']?.toString())
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, dynamic> profilesMap = {};
      if (ownerIds.isNotEmpty) {
        try {
          final profilesRes = await supabase
              .from('profiles')
              .select('id, full_name, role, email')
              .filter('id', 'in', ownerIds);

          for (var p in (profilesRes as List)) {
            final pMap = p as Map<String, dynamic>;
            final id = pMap['id']?.toString();
            if (id != null) {
              profilesMap[id] = pMap;
            }
          }
        } catch (pe) {
          debugPrint('Select with email from profiles failed: $pe');
          try {
            final baseRes = await supabase
                .from('profiles')
                .select('id, full_name, role')
                .filter('id', 'in', ownerIds);

            for (var p in (baseRes as List)) {
              final pMap = p as Map<String, dynamic>;
              final id = pMap['id']?.toString();
              if (id != null) {
                profilesMap[id] = pMap;
              }
            }
          } catch (_) {}
        }
      }

      for (var item in items) {
        final vendorId = item['id']?.toString() ?? '';
        final existingItem = existingQueue[vendorId];
        final brandName = item['brand_name']?.toString() ?? 'Brand';
        final ownerId = item['owner_id']?.toString();
        final profile = ownerId != null ? profilesMap[ownerId] : null;

        final itemOwnerName = item['owner_name']?.toString();
        final profileFullName = profile?['full_name']?.toString();
        final ownerName =
            (itemOwnerName != null && itemOwnerName.trim().isNotEmpty)
            ? itemOwnerName
            : ((profileFullName != null &&
                      profileFullName.trim().isNotEmpty &&
                      profileFullName != 'User' &&
                      profileFullName != 'Unknown' &&
                      profileFullName != 'Owner')
                  ? profileFullName
                  : brandName);

        final bioContent = item['bio']?.toString() ?? '';
        final itemEmail = item['email']?.toString();
        final profileEmail = profile?['email']?.toString();

        String email = '';
        if (existingItem != null &&
            existingItem.email.isNotEmpty &&
            !existingItem.email.contains('No email')) {
          email = existingItem.email;
        } else if (itemEmail != null &&
            itemEmail.trim().isNotEmpty &&
            !itemEmail.contains('@velvetmaison.pk')) {
          email = itemEmail;
        } else if (profileEmail != null && profileEmail.trim().isNotEmpty) {
          email = profileEmail;
        } else {
          final emailMatch = RegExp(
            r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
          ).firstMatch(bioContent);
          if (emailMatch != null) {
            email = emailMatch.group(0)!;
          } else {
            email = (itemEmail != null && itemEmail.trim().isNotEmpty)
                ? itemEmail
                : ((profileEmail != null && profileEmail.trim().isNotEmpty)
                      ? profileEmail
                      : 'No email provided');
          }
        }

        final itemPhone = item['phone']?.toString();
        final profilePhone = profile?['phone']?.toString();

        String phone = '';
        if (existingItem != null &&
            existingItem.phone.isNotEmpty &&
            existingItem.phone != 'Not provided' &&
            !existingItem.phone.contains('-')) {
          phone = existingItem.phone;
        } else {
          final phoneExplicitMatch = RegExp(
            r'Phone:\s*([\+?\d\s-]{7,20})',
            caseSensitive: false,
          ).firstMatch(bioContent);
          if (phoneExplicitMatch != null) {
            phone = phoneExplicitMatch.group(1)!.trim();
          } else if (itemPhone != null &&
              itemPhone.trim().isNotEmpty &&
              itemPhone != 'Not provided' &&
              !itemPhone.contains('-')) {
            phone = itemPhone;
          } else if (profilePhone != null && profilePhone.trim().isNotEmpty) {
            phone = profilePhone;
          } else {
            final generalPhoneMatch = RegExp(
              r'(\+?\d{10,15})',
            ).firstMatch(bioContent);
            if (generalPhoneMatch != null) {
              phone = generalPhoneMatch.group(0)!;
            } else {
              phone = 'Not provided';
            }
          }
        }

        String appliedDate = '';
        if (item['created_at'] != null) {
          try {
            final dt = DateTime.parse(item['created_at'].toString());
            final months = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec',
            ];
            appliedDate = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
          } catch (_) {}
        }
        if (appliedDate.isEmpty) {
          final dt = DateTime.now();
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          appliedDate = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
        }

        final role = profile?['role']?.toString() ?? 'vendor';
        final isCorporate = role == 'corporate';

        final entity = KycVendorEntity(
          id: vendorId,
          brandName: brandName,
          ownerName: isCorporate ? brandName : ownerName,
          email: email,
          phone: phone,
          category:
              item['category']?.toString() ??
              (isCorporate ? 'Corporate' : "Women's"),
          appliedDate: appliedDate,
          status: KycStatus.pending,
          cnicDocUrl: item['cnic_doc_url']?.toString() ?? '',
          secpDocUrl: item['secp_doc_url']?.toString() ?? '',
          bio:
              item['bio']?.toString() ??
              (isCorporate
                  ? 'B2B Corporate Account Application.'
                  : 'Newly registered vendor brand.'),
          city: item['city']?.toString() ?? 'Not provided',
        );

        if (!kycQueue.any((v) => v.id == vendorId)) {
          kycQueue.insert(0, entity);
        }
      }
    } catch (e) {
      kycError.value = e.toString();
      debugPrint('Failed to load pending applications from database: $e');
    } finally {
      isLoadingKyc.value = false;
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────────────
  final RxInt selectedSidebarIndex = 0.obs;

  void changeSidebarIndex(int index) {
    selectedSidebarIndex.value = index;
  }

  // ── Financial Metrics ────────────────────────────────────────────────────────
  final RxDouble totalGmv = 4875240.50.obs;
  final RxDouble totalCommission = 243762.03.obs;
  final RxDouble pendingPayouts = 87430.00.obs;

  // ── Activity Feed ────────────────────────────────────────────────────────────
  final RxList<ActivityFeedItem> activityFeed = <ActivityFeedItem>[
    const ActivityFeedItem(
      id: 'act-001',
      title: 'New vendor application',
      subtitle: 'Threads & Co. has submitted their KYC documents.',
      type: ActivityType.vendorSignup,
      time: '2 mins ago',
    ),
    const ActivityFeedItem(
      id: 'act-002',
      title: 'Safepay payout processed',
      subtitle: 'PKR 45,200 routed to Zara Couture.',
      type: ActivityType.payout,
      time: '14 mins ago',
    ),
    const ActivityFeedItem(
      id: 'act-003',
      title: 'Product approved',
      subtitle: 'Admin approved "Silk Kaftan – Ivory" from House of Linen.',
      type: ActivityType.approval,
      time: '32 mins ago',
    ),
    const ActivityFeedItem(
      id: 'act-004',
      title: 'New B2C order',
      subtitle: 'Sara Ahmed placed an order worth PKR 12,400.',
      type: ActivityType.transaction,
      time: '1 hr ago',
    ),
    const ActivityFeedItem(
      id: 'act-005',
      title: 'Vendor rejected',
      subtitle: 'Incomplete SECP docs — FashionFord application declined.',
      type: ActivityType.rejection,
      time: '2 hrs ago',
    ),
    const ActivityFeedItem(
      id: 'act-006',
      title: 'New B2B quote request',
      subtitle: 'Al-Malik Textiles submitted bulk order of 500 units.',
      type: ActivityType.transaction,
      time: '3 hrs ago',
    ),
  ].obs;

  // ── KYC Queue ────────────────────────────────────────────────────────────────
  final RxList<KycVendorEntity> kycQueue = <KycVendorEntity>[].obs;

  final Rx<KycVendorEntity?> selectedVendor = Rx<KycVendorEntity?>(null);

  void selectVendor(KycVendorEntity vendor) {
    selectedVendor.value = vendor;
  }

  void clearSelectedVendor() {
    selectedVendor.value = null;
  }

  void approveVendor(String vendorId) async {
    try {
      final supabase = Get.find<SupabaseService>().client;
      await supabase
          .from('vendors')
          .update({'kyc_status': 'approved'})
          .or('id.eq.$vendorId,owner_id.eq.$vendorId');

      try {
        await supabase
            .from('profiles')
            .update({'role': 'vendor'})
            .eq('id', vendorId);
      } catch (_) {}
    } catch (e) {
      debugPrint('Failed to approve application in Supabase: $e');
    }

    kycQueue.removeWhere((v) => v.id == vendorId);
    if (selectedVendor.value?.id == vendorId) selectedVendor.value = null;
    _addActivity(
      ActivityFeedItem(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Vendor Approved',
        subtitle: 'SaaS account activated for vendor $vendorId.',
        type: ActivityType.approval,
        time: 'Just now',
      ),
    );
    Get.snackbar(
      'Account Approved',
      'The partner account has been activated successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void rejectVendor(String vendorId) async {
    try {
      final supabase = Get.find<SupabaseService>().client;
      await supabase
          .from('vendors')
          .update({'kyc_status': 'rejected'})
          .or('id.eq.$vendorId,owner_id.eq.$vendorId');
    } catch (e) {
      debugPrint('Failed to reject application in Supabase: $e');
    }

    kycQueue.removeWhere((v) => v.id == vendorId);
    if (selectedVendor.value?.id == vendorId) selectedVendor.value = null;
    _addActivity(
      ActivityFeedItem(
        id: 'act-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Application Rejected',
        subtitle: 'More info requested from vendor $vendorId.',
        type: ActivityType.rejection,
        time: 'Just now',
      ),
    );
    Get.snackbar(
      'Application Rejected',
      'Vendor has been notified to resubmit documents.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  // ── Catalog Moderation ───────────────────────────────────────────────────────
  final RxList<PendingProductEntity> pendingProducts = <PendingProductEntity>[
    const PendingProductEntity(
      id: 'prod-001',
      name: 'Silk Kaftan — Ivory',
      vendorName: 'House of Linen',
      vendorId: 'kyc-002',
      price: 8500,
      category: "Women's",
      sizes: ['S', 'M', 'L', 'XL'],
      imageUrl: 'https://picsum.photos/seed/prod001/400/500',
      additionalImages: [
        'https://picsum.photos/seed/prod001-2/400/500',
        'https://picsum.photos/seed/prod001-3/400/500',
      ],
      description:
          'Elegant silk kaftan with intricate hand embroidery. Perfect for formal evening events and wedding festivities.',
      status: ProductStatus.pending,
    ),
    const PendingProductEntity(
      id: 'prod-002',
      name: 'Linen Kurta — Navy',
      vendorName: 'Threads & Co.',
      vendorId: 'kyc-001',
      price: 3200,
      category: "Men's",
      sizes: ['M', 'L', 'XL', 'XXL'],
      imageUrl: 'https://picsum.photos/seed/prod002/400/500',
      additionalImages: ['https://picsum.photos/seed/prod002-2/400/500'],
      description:
          'Breathable 100% pure linen kurta in deep navy. Designed for maximum comfort in warm climates.',
      status: ProductStatus.pending,
    ),
    const PendingProductEntity(
      id: 'prod-003',
      name: 'Embroidered Shawl Coat',
      vendorName: 'Karimi Couture',
      vendorId: 'kyc-004',
      price: 22000,
      category: "Women's",
      sizes: ['XS', 'S', 'M', 'L'],
      imageUrl: 'https://picsum.photos/seed/prod003/400/500',
      additionalImages: [
        'https://picsum.photos/seed/prod003-2/400/500',
        'https://picsum.photos/seed/prod003-3/400/500',
      ],
      description:
          'Hand-crafted wool shawl coat featuring traditional paisley embroidery. A luxury staple for the winter season.',
      status: ProductStatus.pending,
    ),
    const PendingProductEntity(
      id: 'prod-004',
      name: 'Suede Loafer — Tan',
      vendorName: 'Sole Republic',
      vendorId: 'kyc-003',
      price: 6800,
      category: 'Accessories',
      sizes: ['40', '41', '42', '43', '44'],
      imageUrl: 'https://picsum.photos/seed/prod004/400/500',
      additionalImages: ['https://picsum.photos/seed/prod004-2/400/500'],
      description:
          'Premium Italian suede loafers with genuine leather lining and cushioned insoles for all-day wear.',
      status: ProductStatus.pending,
    ),
    const PendingProductEntity(
      id: 'prod-005',
      name: 'Floral Lawn 3-Piece',
      vendorName: 'Threads & Co.',
      vendorId: 'kyc-001',
      price: 4100,
      category: "Women's",
      sizes: ['S', 'M', 'L'],
      imageUrl: 'https://picsum.photos/seed/prod005/400/500',
      additionalImages: ['https://picsum.photos/seed/prod005-2/400/500'],
      description:
          'Vibrant floral print 3-piece lawn suit including embroidered dupatta and dyed trousers.',
      status: ProductStatus.pending,
    ),
    const PendingProductEntity(
      id: 'prod-006',
      name: 'Handwoven Jute Bag',
      vendorName: 'House of Linen',
      vendorId: 'kyc-002',
      price: 2400,
      category: 'Accessories',
      sizes: ['One Size'],
      imageUrl: 'https://picsum.photos/seed/prod006/400/500',
      additionalImages: ['https://picsum.photos/seed/prod006-2/400/500'],
      description:
          'Eco-friendly hand-woven jute tote bag with leather handles. Durable and stylish for everyday essentials.',
      status: ProductStatus.pending,
    ),
  ].obs;

  void approveProduct(String productId) {
    pendingProducts.removeWhere((p) => p.id == productId);
    Get.snackbar(
      'Product Approved',
      'The item is now live on the catalogue.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void rejectProduct(String productId) {
    pendingProducts.removeWhere((p) => p.id == productId);
    Get.snackbar(
      'Product Rejected',
      'Vendor notified to fix and resubmit.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void approveAllProducts() {
    pendingProducts.clear();
    Get.snackbar(
      'All Products Approved',
      'Catalogue cleared — all items are now live.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  // ── Financial Ledger ─────────────────────────────────────────────────────────
  final RxList<TransactionEntity> transactions = <TransactionEntity>[
    const TransactionEntity(
      id: 'TXN-00912',
      customerName: 'Sara Ahmed',
      vendorName: 'Threads & Co.',
      grossAmount: 12400,
      platformFeePercent: 5.0,
      netToVendor: 11780,
      date: 'May 6, 2026',
      status: 'Settled',
    ),
    const TransactionEntity(
      id: 'TXN-00911',
      customerName: 'Omar Farouk',
      vendorName: 'House of Linen',
      grossAmount: 8750,
      platformFeePercent: 5.0,
      netToVendor: 8312.50,
      date: 'May 6, 2026',
      status: 'Settled',
    ),
    const TransactionEntity(
      id: 'TXN-00910',
      customerName: 'Nadia Hussain',
      vendorName: 'Karimi Couture',
      grossAmount: 45000,
      platformFeePercent: 5.0,
      netToVendor: 42750,
      date: 'May 5, 2026',
      status: 'Pending Payout',
    ),
    const TransactionEntity(
      id: 'TXN-00909',
      customerName: 'Imran Shah',
      vendorName: 'Sole Republic',
      grossAmount: 6800,
      platformFeePercent: 5.0,
      netToVendor: 6460,
      date: 'May 5, 2026',
      status: 'Settled',
    ),
    const TransactionEntity(
      id: 'TXN-00908',
      customerName: 'Fatima Zahra',
      vendorName: 'Threads & Co.',
      grossAmount: 21600,
      platformFeePercent: 5.0,
      netToVendor: 20520,
      date: 'May 4, 2026',
      status: 'Settled',
    ),
    const TransactionEntity(
      id: 'TXN-00907',
      customerName: 'Al-Malik Textiles',
      vendorName: 'House of Linen',
      grossAmount: 380000,
      platformFeePercent: 3.5,
      netToVendor: 366700,
      date: 'May 4, 2026',
      status: 'Pending Payout',
    ),
  ].obs;

  // ── Asset Management ─────────────────────────────────────────────────────────

  Future<void> downloadFile(String url, String fileName) async {
    await AssetDownloaderUtil.saveToGallery(url: url, fileName: fileName);
  }

  void _addActivity(ActivityFeedItem item) {
    activityFeed.insert(0, item);
  }

  String formatCurrency(double value) {
    if (value >= 1000000) {
      return 'PKR ${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return 'PKR ${(value / 1000).toStringAsFixed(1)}K';
    }
    return 'PKR ${value.toStringAsFixed(0)}';
  }
}
