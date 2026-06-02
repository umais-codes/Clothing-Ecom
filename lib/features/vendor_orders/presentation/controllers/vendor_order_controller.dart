import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/vendor_order.dart';

class VendorOrderController extends GetxController {
  final RxList<VendorOrder> orders = <VendorOrder>[].obs;
  final RxString selectedTab = 'All'.obs;

  // Controllers for bottom sheet input
  final trackingController = TextEditingController();

  final List<String> tabs = [
    'All',
    'New Orders',
    'Processing',
    'Shipped',
    'Returns (RMA)',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadMockOrders();
  }

  @override
  void onClose() {
    trackingController.dispose();
    super.onClose();
  }

  void _loadMockOrders() {
    orders.assignAll([
      VendorOrder(
        id: '#ORD-9921',
        customerName: 'Sarah Al-Fayed',
        amount: 250.00,
        status: 'Pending',
        orderDate: DateTime.now().subtract(const Duration(minutes: 10)),
        isB2B: false,
        shippingAddress: 'Apt 4B, Beverly Hills Tower, Marina, Dubai, UAE',
        customerPhone: '+971 50 123 4567',
        items: [
          const VendorOrderItem(
            id: 'item_1',
            name: 'Silk Slip Dress',
            quantity: 1,
            unitPrice: 120.00,
            size: 'S',
            color: 'Champagne',
            imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=300&auto=format&fit=crop',
          ),
          const VendorOrderItem(
            id: 'item_2',
            name: 'Cashmere Ribbed Knit',
            quantity: 1,
            unitPrice: 130.00,
            size: 'M',
            color: 'Soft Taupe',
            imageUrl: 'https://images.unsplash.com/photo-1574164904299-3a102b110380?q=80&w=300&auto=format&fit=crop',
          ),
        ],
        timeline: [
          OrderTimelineStep(
            title: 'Order Placed',
            description: 'Order successfully authorized and paid.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
            isCompleted: true,
          ),
          const OrderTimelineStep(
            title: 'Under Review',
            description: 'Awaiting vendor confirmation and stock check.',
            isCompleted: false,
          ),
          const OrderTimelineStep(
            title: 'Fulfillment & Packing',
            description: 'Items will be packed and printed with shipping labels.',
            isCompleted: false,
          ),
        ],
      ),
      VendorOrder(
        id: '#ORD-9920',
        customerName: 'Luxe Apparel Retail Corp',
        amount: 12450.00,
        status: 'Processing',
        orderDate: DateTime.now().subtract(const Duration(hours: 12)),
        isB2B: true,
        shippingAddress: 'Warehouse 12, Logistics Park South, Karachi, Pakistan',
        customerPhone: '+92 300 987 6543',
        items: [
          const VendorOrderItem(
            id: 'item_3',
            name: 'Velvet Tuxedo Jacket',
            quantity: 50,
            unitPrice: 249.00,
            imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=300&auto=format&fit=crop',
          ),
        ],
        b2bMatrix: {
          'Midnight Black': {'S': 10, 'M': 15, 'L': 15, 'XL': 10},
          'Navy Blue': {'S': 5, 'M': 10, 'L': 10, 'XL': 5},
          'Camel Gold': {'S': 5, 'M': 5, 'L': 5, 'XL': 5},
        },
        b2bSizes: ['S', 'M', 'L', 'XL'],
        b2bColors: ['Midnight Black', 'Navy Blue', 'Camel Gold'],
        timeline: [
          OrderTimelineStep(
            title: 'Order Placed',
            description: 'Corporate PO processed. Payment terms: Net 30.',
            timestamp: DateTime.now().subtract(const Duration(hours: 12)),
            isCompleted: true,
          ),
          OrderTimelineStep(
            title: 'Order Accepted',
            description: 'Confirmed by Velvet Maison packing house.',
            timestamp: DateTime.now().subtract(const Duration(hours: 11)),
            isCompleted: true,
          ),
          const OrderTimelineStep(
            title: 'Packing Order',
            description: 'Sorting sizes and colors into custom garment covers.',
            isCompleted: true,
          ),
          const OrderTimelineStep(
            title: 'Dispatch & Courier',
            description: 'Awaiting shipping manifest and carrier pickup.',
            isCompleted: false,
          ),
        ],
      ),
      VendorOrder(
        id: '#ORD-9919',
        customerName: 'James Wilson',
        amount: 120.00,
        status: 'Shipped',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        isB2B: false,
        shippingAddress: '12 A, Street 5, Phase 6 DHA, Lahore, Pakistan',
        customerPhone: '+92 333 456 7890',
        trackingNumber: 'TRK88721992',
        courierPartner: 'Trax Logistics',
        packageWeight: 1.2,
        items: [
          const VendorOrderItem(
            id: 'item_4',
            name: 'Linen Lounge Pants',
            quantity: 1,
            unitPrice: 120.00,
            size: 'L',
            color: 'Natural Oatmeal',
            imageUrl: 'https://images.unsplash.com/photo-1509551388413-e18d0ac5d495?q=80&w=300&auto=format&fit=crop',
          ),
        ],
        timeline: [
          OrderTimelineStep(
            title: 'Order Placed',
            description: 'Paid via Apple Pay.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isCompleted: true,
          ),
          OrderTimelineStep(
            title: 'Accepted',
            description: 'Stock locked and confirmed.',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
            isCompleted: true,
          ),
          OrderTimelineStep(
            title: 'Shipped',
            description: 'Picked up by FedEx. Tracking: TRK88721992',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isCompleted: true,
          ),
        ],
      ),
      VendorOrder(
        id: '#ORD-9918',
        customerName: 'Elena Rossi',
        amount: 450.00,
        status: 'Returned',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        isB2B: false,
        shippingAddress: 'House 44, F-8/2, Islamabad, Pakistan',
        customerPhone: '+92 321 654 0987',
        returnReason: 'The classic trench coat fabric is stunning, but the size M runs slightly larger than standard charts. Requesting return.',
        returnImages: [
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=300&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=300&auto=format&fit=crop',
        ],
        items: [
          const VendorOrderItem(
            id: 'item_5',
            name: 'Classic Trench Coat',
            quantity: 1,
            unitPrice: 450.00,
            size: 'M',
            color: 'Honey Camel',
            imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=300&auto=format&fit=crop',
          ),
        ],
        timeline: [
          OrderTimelineStep(
            title: 'Return Requested',
            description: 'Customer requested return: "Size was slightly too large."',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isCompleted: true,
          ),
          const OrderTimelineStep(
            title: 'Awaiting Return Package',
            description: 'RMA label generated. Pre-paid parcel is in transit.',
            isCompleted: false,
          ),
        ],
      ),
    ]);
  }

  List<VendorOrder> get filteredOrders {
    final filter = selectedTab.value;
    if (filter == 'All') {
      return orders;
    } else if (filter == 'New Orders') {
      return orders.where((o) => o.status == 'Pending').toList();
    } else if (filter == 'Processing') {
      return orders.where((o) => o.status == 'Processing').toList();
    } else if (filter == 'Shipped') {
      return orders.where((o) => o.status == 'Shipped').toList();
    } else if (filter == 'Returns (RMA)') {
      return orders.where((o) => o.status == 'Returned').toList();
    }
    return [];
  }

  void acceptOrder(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      final updatedTimeline = List<OrderTimelineStep>.from(oldOrder.timeline)
        ..add(OrderTimelineStep(
          title: 'Order Accepted',
          description: 'Confirmed by vendor. Moving to fulfillment.',
          timestamp: DateTime.now(),
          isCompleted: true,
        ));
      
      final updatedOrder = oldOrder.copyWith(
        status: 'Processing',
        timeline: updatedTimeline,
      );
      orders[index] = updatedOrder;
      
      Get.snackbar(
        'Order Accepted',
        'Order $orderId has been moved to Processing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC19A6B).withValues(alpha: 0.1),
        colorText: const Color(0xFF1A1A1A),
      );

      // Close the bottom sheet modal if it is currently open
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // Automatically navigate to the packing checklist workspace
      Get.toNamed('/fulfillment-checklist', arguments: updatedOrder);
    }
  }

  void markAsShipped(String orderId, String trackingNumber) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = orders[index];
      final updatedTimeline = List<OrderTimelineStep>.from(oldOrder.timeline)
        ..add(OrderTimelineStep(
          title: 'Shipped',
          description: 'Dispatched via carrier. Tracking: $trackingNumber',
          timestamp: DateTime.now(),
          isCompleted: true,
        ));

      orders[index] = oldOrder.copyWith(
        status: 'Shipped',
        trackingNumber: trackingNumber,
        timeline: updatedTimeline,
      );

      Get.snackbar(
        'Order Shipped',
        'Order $orderId marked as Shipped. Tracking ID added.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4A7C59).withValues(alpha: 0.1),
        colorText: const Color(0xFF4A7C59),
      );
    }
  }

  void processReturn(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      // Simulate completing the refund
      orders.removeAt(index);
      
      Get.snackbar(
        'Refund Completed',
        'RMA for order $orderId completed successfully. Refund initiated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC0392B).withValues(alpha: 0.1),
        colorText: const Color(0xFFC0392B),
      );
    }
  }
}
