enum KycStatus { pending, approved, rejected }

enum ProductStatus { pending, approved, rejected }

class KycVendorEntity {
  final String id;
  final String brandName;
  final String ownerName;
  final String email;
  final String phone;
  final String category;
  final String appliedDate;
  final KycStatus status;
  final String cnicDocUrl;
  final String secpDocUrl;
  final String bio;
  final String city;

  const KycVendorEntity({
    required this.id,
    required this.brandName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.category,
    required this.appliedDate,
    required this.status,
    required this.cnicDocUrl,
    required this.secpDocUrl,
    required this.bio,
    required this.city,
  });
}

class PendingProductEntity {
  final String id;
  final String name;
  final String vendorName;
  final String vendorId;
  final double price;
  final String category;
  final List<String> sizes;
  final String imageUrl;
  final List<String> additionalImages;
  final String description;
  final ProductStatus status;

  const PendingProductEntity({
    required this.id,
    required this.name,
    required this.vendorName,
    required this.vendorId,
    required this.price,
    required this.category,
    required this.sizes,
    required this.imageUrl,
    this.additionalImages = const [],
    this.description = '',
    required this.status,
  });
}

class TransactionEntity {
  final String id;
  final String customerName;
  final String vendorName;
  final double grossAmount;
  final double platformFeePercent;
  final double netToVendor;
  final String date;
  final String status;

  const TransactionEntity({
    required this.id,
    required this.customerName,
    required this.vendorName,
    required this.grossAmount,
    required this.platformFeePercent,
    required this.netToVendor,
    required this.date,
    required this.status,
  });

  double get platformEarned => grossAmount * (platformFeePercent / 100);
}

class ActivityFeedItem {
  final String id;
  final String title;
  final String subtitle;
  final ActivityType type;
  final String time;

  const ActivityFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.time,
  });
}

enum ActivityType { transaction, vendorSignup, approval, rejection, payout }
