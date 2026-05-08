import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/utils/asset_downloader_util.dart';
import 'package:ecom_app/features/super_admin/domain/entities/admin_entities.dart';

class AdminController extends GetxController {
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
      title: 'Stripe payout processed',
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
  final RxList<KycVendorEntity> kycQueue = <KycVendorEntity>[
    const KycVendorEntity(
      id: 'kyc-001',
      brandName: 'Threads & Co.',
      ownerName: 'Ayesha Siddiqui',
      email: 'ayesha@threadsco.pk',
      phone: '+92-321-4550012',
      category: "Women's Apparel",
      appliedDate: 'May 6, 2026',
      status: KycStatus.pending,
      cnicDocUrl: 'https://picsum.photos/seed/cnic1/800/600',
      secpDocUrl: 'https://picsum.photos/seed/secp1/800/600',
      bio:
          "Premium women's apparel brand specialising in luxury ready-to-wear and bespoke ensembles since 2018.",
      city: 'Lahore',
    ),
    const KycVendorEntity(
      id: 'kyc-002',
      brandName: 'House of Linen',
      ownerName: 'Bilal Rehman',
      email: 'bilal@houseoflinen.com',
      phone: '+92-300-8872341',
      category: 'Home & Apparel',
      appliedDate: 'May 5, 2026',
      status: KycStatus.pending,
      cnicDocUrl: 'https://picsum.photos/seed/cnic2/800/600',
      secpDocUrl: 'https://picsum.photos/seed/secp2/800/600',
      bio:
          "Sustainable linen clothing and home textile brand, ethically sourced from Punjab's finest mills.",
      city: 'Faisalabad',
    ),
    const KycVendorEntity(
      id: 'kyc-003',
      brandName: 'Sole Republic',
      ownerName: 'Zara Malik',
      email: 'zara@solerepublic.pk',
      phone: '+92-311-9900453',
      category: 'Footwear & Accessories',
      appliedDate: 'May 4, 2026',
      status: KycStatus.pending,
      cnicDocUrl: 'https://picsum.photos/seed/cnic3/800/600',
      secpDocUrl: 'https://picsum.photos/seed/secp3/800/600',
      bio:
          'Contemporary footwear label fusing Eastern craftsmanship with modern silhouettes.',
      city: 'Karachi',
    ),
    const KycVendorEntity(
      id: 'kyc-004',
      brandName: 'Karimi Couture',
      ownerName: 'Hassan Karimi',
      email: 'hassan@karimicouture.com',
      phone: '+92-333-2211890',
      category: "Men's Formal",
      appliedDate: 'May 3, 2026',
      status: KycStatus.pending,
      cnicDocUrl: 'https://picsum.photos/seed/cnic4/800/600',
      secpDocUrl: 'https://picsum.photos/seed/secp4/800/600',
      bio:
          'Bespoke and ready-to-wear menswear tailored with Italian fabric and local craftsmanship.',
      city: 'Islamabad',
    ),
  ].obs;

  final Rx<KycVendorEntity?> selectedVendor = Rx<KycVendorEntity?>(null);

  void selectVendor(KycVendorEntity vendor) {
    selectedVendor.value = vendor;
  }

  void clearSelectedVendor() {
    selectedVendor.value = null;
  }

  void approveVendor(String vendorId) {
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
      'Vendor Approved',
      'SaaS account has been activated successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4A7C59),
      colorText: const Color(0xFFFFFFFF),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void rejectVendor(String vendorId) {
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
      backgroundColor: const Color(0xFFC0392B),
      colorText: const Color(0xFFFFFFFF),
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
      category: "Women's Formal",
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
      category: "Men's Casual",
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
      category: "Women's Winter",
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
      category: 'Footwear',
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
      category: "Women's Casual",
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
      backgroundColor: const Color(0xFF4A7C59),
      colorText: const Color(0xFFFFFFFF),
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
      backgroundColor: const Color(0xFFC0392B),
      colorText: const Color(0xFFFFFFFF),
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
      backgroundColor: const Color(0xFF4A7C59),
      colorText: const Color(0xFFFFFFFF),
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
