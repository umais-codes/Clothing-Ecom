
class VendorOrderItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String? size;
  final String? color;
  final String imageUrl;

  const VendorOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.size,
    this.color,
    required this.imageUrl,
  });
}

class OrderTimelineStep {
  final String title;
  final String description;
  final DateTime? timestamp;
  final bool isCompleted;

  const OrderTimelineStep({
    required this.title,
    required this.description,
    this.timestamp,
    required this.isCompleted,
  });
}

class VendorOrder {
  final String id;
  final String customerName;
  final double amount;
  final String status; // 'Pending', 'Processing', 'Shipped', 'Returned'
  final DateTime orderDate;
  final bool isB2B;
  final List<VendorOrderItem> items;
  final String? trackingNumber;
  final List<OrderTimelineStep> timeline;

  // New shipping/logistics and RMA fields
  final String? shippingAddress;
  final String? customerPhone;
  final double? packageWeight;
  final String? courierPartner;
  final String? returnReason;
  final List<String>? returnImages;
  
  // Matrix data for B2B orders: color -> {size: quantity}
  final Map<String, Map<String, int>>? b2bMatrix;
  final List<String>? b2bSizes;
  final List<String>? b2bColors;

  const VendorOrder({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.orderDate,
    required this.isB2B,
    required this.items,
    this.trackingNumber,
    required this.timeline,
    this.shippingAddress,
    this.customerPhone,
    this.packageWeight,
    this.courierPartner,
    this.returnReason,
    this.returnImages,
    this.b2bMatrix,
    this.b2bSizes,
    this.b2bColors,
  });

  VendorOrder copyWith({
    String? status,
    String? trackingNumber,
    List<OrderTimelineStep>? timeline,
    double? packageWeight,
    String? courierPartner,
    String? returnReason,
    List<String>? returnImages,
  }) {
    return VendorOrder(
      id: id,
      customerName: customerName,
      amount: amount,
      status: status ?? this.status,
      orderDate: orderDate,
      isB2B: isB2B,
      items: items,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      timeline: timeline ?? this.timeline,
      shippingAddress: shippingAddress,
      customerPhone: customerPhone,
      packageWeight: packageWeight ?? this.packageWeight,
      courierPartner: courierPartner ?? this.courierPartner,
      returnReason: returnReason ?? this.returnReason,
      returnImages: returnImages ?? this.returnImages,
      b2bMatrix: b2bMatrix,
      b2bSizes: b2bSizes,
      b2bColors: b2bColors,
    );
  }
}
