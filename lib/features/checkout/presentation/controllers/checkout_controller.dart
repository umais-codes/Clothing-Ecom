import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:safepay_checkout/safepay_payment_gateway.dart';
import 'package:ecom_app/core/supabase/supabase_client.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2c_cart_controller.dart';
import 'package:ecom_app/features/cart/presentation/controllers/b2b_cart_controller.dart';
import 'package:ecom_app/features/vendor_orders/presentation/controllers/vendor_order_controller.dart';
import 'package:ecom_app/features/vendor_orders/domain/entities/vendor_order.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class CheckoutController extends GetxController {
  // ignore: unused_field
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;
  final Uuid _uuid = const Uuid();

  static const String clientKey = String.fromEnvironment(
    'SAFEPAY_CLIENT_KEY',
    defaultValue: 'sec_e0db25ff-9b4e-4f7f-a1df-b6ba9d423e85',
  );
  static const String secretKey = String.fromEnvironment(
    'SAFEPAY_SECRET_KEY',
    defaultValue: 'sec_sandbox_secret_key',
  );

  // Mode state
  final RxBool isB2B = false.obs;

  // Processing state
  final RxBool isProcessing = false.obs;

  // Shipping & Contact form controllers
  final fullNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final postalCodeController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // B2B Procurement details
  final companyNameController = TextEditingController();
  final ntnController = TextEditingController();
  final procurementEmailController = TextEditingController();
  final poNumberController = TextEditingController();

  // Toggle options
  final RxBool billingSameAsShipping = true.obs;

  // Selected Payment Method:
  // For B2C: 'Safepay' is the primary online payment.
  // For B2B: 'PO', 'Net30', or 'Safepay' (Raast/Bank Transfer)
  final RxString selectedPaymentOption = 'Safepay'.obs;

  // Dynamic Validation state
  final RxBool isFormValid = false.obs;

  // Reference to cart controllers
  late final B2CCartController b2cCart;
  late final B2BCartController b2bCart;

  @override
  void onInit() {
    super.onInit();
    b2cCart = Get.find<B2CCartController>();
    b2bCart = Get.find<B2BCartController>();

    // Parse route arguments
    final args = Get.arguments;
    if (args != null) {
      isB2B.value = args['isB2B'] == true;
      if (isB2B.value) {
        // Pre-select initial option from arguments (e.g. PO or Quote)
        final initialOpt = args['initialOption'];
        if (initialOpt == 'Quote') {
          selectedPaymentOption.value = 'Quote';
        } else {
          selectedPaymentOption.value = 'PO';
        }
      } else {
        selectedPaymentOption.value = 'Safepay';
      }
    }

    // Add validation listeners to all active controllers
    final controllersList = [
      fullNameController,
      addressController,
      cityController,
      postalCodeController,
      phoneController,
      emailController,
      companyNameController,
      ntnController,
      procurementEmailController,
      poNumberController,
    ];

    for (var c in controllersList) {
      c.addListener(validateForm);
    }

    billingSameAsShipping.listen((_) => validateForm());
    selectedPaymentOption.listen((_) => validateForm());

    validateForm();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    companyNameController.dispose();
    ntnController.dispose();
    procurementEmailController.dispose();
    poNumberController.dispose();
    super.onClose();
  }

  // Checkout pricing values based on B2B / B2C pathways
  double get subtotal => isB2B.value ? b2bCart.subtotal : b2cCart.subtotal;
  double get shippingFee => isB2B.value ? 0.0 : b2cCart.deliveryFee;
  double get total => isB2B.value ? b2bCart.subtotal : b2cCart.total;

  void validateForm() {
    // 1. Basic shipping details validation (Required for everyone)
    if (fullNameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        postalCodeController.text.trim().isEmpty ||
        phoneController.text.trim().length < 9 ||
        !GetUtils.isEmail(emailController.text.trim())) {
      isFormValid.value = false;
      return;
    }

    // 2. Mode-specific validation
    if (isB2B.value) {
      if (companyNameController.text.trim().isEmpty ||
          ntnController.text.trim().isEmpty) {
        isFormValid.value = false;
        return;
      }

      if (selectedPaymentOption.value == 'PO' &&
          poNumberController.text.trim().isEmpty) {
        isFormValid.value = false;
        return;
      }
    }

    isFormValid.value = true;
  }

  /// Initialize Safepay transaction session dynamically and securely via Supabase Edge Functions
  Future<Map<String, String>> _initSafepaySession(
    double amount,
    String currency,
  ) async {
    // Invoke secure backend edge function
    final FunctionResponse response = await _supabase.functions.invoke(
      'init-safepay-session',
      body: {'amount': amount, 'currency': currency},
    );

    if (response.status != 200) {
      throw Exception(
        'Failed to initialize Safepay session via Edge Function (Status: ${response.status}): ${response.data}',
      );
    }

    final data = response.data;
    if (data == null || data['tbt'] == null || data['tracker'] == null) {
      throw Exception(
        'Invalid response structure returned from checkout Edge Function.',
      );
    }

    return {
      'tbt': data['tbt'].toString(),
      'tracker': data['tracker'].toString(),
    };
  }

  Future<void> submitCheckout() async {
    if (!isFormValid.value || isProcessing.value) return;

    // Determine if it is B2C Online Payment or B2B Bank Transfer (which triggers Safepay Checkout)
    final bool triggerOnlinePayment = selectedPaymentOption.value == 'Safepay';

    if (!triggerOnlinePayment) {
      // Offline B2B Procurement terms (PO, Net-30, Custom Quote)
      await _completeOrderPlacement(paymentMethod: selectedPaymentOption.value);
    } else {
      // Safepay Gateway Integration Flow
      isProcessing.value = true;
      try {
        // Detect currency (default to PKR, fallback to USD if configured)
        final String currency = 'PKR';
        final double orderAmount = total;

        // Fetch Safepay Session Tokens (TBT + Tracker)
        final session = await _initSafepaySession(orderAmount, currency);
        final String tbt = session['tbt']!;
        final String tracker = session['tracker']!;

        isProcessing.value = false;

        // Launch Safepay Checkout Full-Screen WebView Widget
        Get.to(
          () => SafepayCheckout(
            environment: SafePayEnvironment.sandbox,
            tbt: tbt,
            tracker: tracker,
            successUrl: 'https://velvetmaison.pk/checkout/success',
            failUrl: 'https://velvetmaison.pk/checkout/fail',
            onPaymentFailed: () {
              Get.back();
              Get.snackbar(
                'Payment Failed',
                'Safepay transaction was cancelled or declined.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                colorText: AppColors.error,
              );
            },
            onPaymentCompleted: () {
              Get.back();
              _completeOrderPlacement(
                paymentMethod: 'Safepay',
                trackerToken: tracker,
              );
            },
          ),
        );
      } catch (e) {
        isProcessing.value = false;
        Get.snackbar(
          'Payment Error',
          'Unable to initialize Safepay session: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
      }
    }
  }

  /// Helper to complete database and state updates after payment authorization/terms submission
  Future<void> _completeOrderPlacement({
    required String paymentMethod,
    String? trackerToken,
  }) async {
    isProcessing.value = true;

    try {
      final String orderIdStr =
          '#ORD-${_uuid.v4().substring(0, 4).toUpperCase()}';

      // Assemble final Supabase payload
      final orderPayload = {
        'id': orderIdStr,
        'customer_name': isB2B.value
            ? companyNameController.text.trim()
            : fullNameController.text.trim(),
        'customer_email': emailController.text.trim(),
        'customer_phone': phoneController.text.trim(),
        'shipping_address':
            '${addressController.text.trim()}, ${cityController.text.trim()}, ${postalCodeController.text.trim()}',
        'amount': total,
        'is_b2b': isB2B.value,
        'status': (paymentMethod == 'Safepay') ? 'Paid' : 'Pending',
        'payment_method': paymentMethod,
        'created_at': DateTime.now().toIso8601String(),
        'safepay_tracker': trackerToken,
        if (isB2B.value) ...{
          'company_name': companyNameController.text.trim(),
          'ntn_number': ntnController.text.trim(),
          'procurement_email': procurementEmailController.text.trim(),
          'po_number': paymentMethod == 'PO'
              ? poNumberController.text.trim()
              : null,
        },
      };

      debugPrint(
        'Inserting Order Payload into Supabase [public.orders]: $orderPayload',
      );

      // STUB: Insert order items payload
      final itemsPayload = (isB2B.value ? b2bCart.cartItems : b2cCart.cartItems)
          .map(
            (item) => {
              'order_id': orderIdStr,
              'product_id': item.id,
              'product_name': item.name,
              'quantity': item.quantity,
              'unit_price': item.price,
              'size': item.size,
              'color': item.color,
              'image_url': item.imageUrl,
            },
          )
          .toList();

      debugPrint(
        'Inserting Order Items Payload into Supabase [public.order_items]: $itemsPayload',
      );

      // Insert securely into Supabase PostgreSQL (Commented out in sandbox mock view)
      /*
      await _supabase.from('orders').insert(orderPayload);
      await _supabase.from('order_items').insert(itemsPayload);
      */

      // Link to local vendor order system for real-time frontend verification in the prototype
      final List<VendorOrderItem> vendorItems =
          (isB2B.value ? b2bCart.cartItems : b2cCart.cartItems).map((item) {
            return VendorOrderItem(
              id: item.id,
              name: item.name,
              quantity: item.quantity,
              unitPrice: item.price,
              size: item.size,
              color: item.color,
              imageUrl: item.imageUrl,
            );
          }).toList();

      final String timelineTitle = (paymentMethod == 'Safepay')
          ? 'Payment Complete'
          : 'Order Received';
      final String timelineDesc = (paymentMethod == 'Safepay')
          ? 'Authorized securely via Safepay Checkout.'
          : 'Pending terms confirmation: $paymentMethod.';

      Map<String, Map<String, int>>? b2bMatrix;
      List<String>? b2bSizes;
      List<String>? b2bColors;

      if (isB2B.value) {
        b2bMatrix = {};
        b2bSizes = [];
        b2bColors = [];
        for (var item in b2bCart.cartItems) {
          final size = item.size ?? 'M';
          final color = item.color ?? 'Classic Sand';
          if (!b2bSizes.contains(size)) b2bSizes.add(size);
          if (!b2bColors.contains(color)) b2bColors.add(color);

          if (!b2bMatrix.containsKey(color)) {
            b2bMatrix[color] = {};
          }
          b2bMatrix[color]![size] = item.quantity;
        }
      }

      final newOrder = VendorOrder(
        id: orderIdStr,
        customerName: isB2B.value
            ? companyNameController.text.trim()
            : fullNameController.text.trim(),
        amount: total,
        status: (paymentMethod == 'Safepay') ? 'Paid' : 'Pending',
        orderDate: DateTime.now(),
        isB2B: isB2B.value,
        items: vendorItems,
        shippingAddress:
            '${addressController.text.trim()}, ${cityController.text.trim()}, ${postalCodeController.text.trim()}',
        customerPhone: phoneController.text.trim(),
        timeline: [
          OrderTimelineStep(
            title: timelineTitle,
            description: timelineDesc,
            timestamp: DateTime.now(),
            isCompleted: true,
          ),
          const OrderTimelineStep(
            title: 'Processing',
            description: 'Order confirmed. Brand vendor preparing dispatch.',
            isCompleted: false,
          ),
        ],
        b2bMatrix: b2bMatrix,
        b2bSizes: b2bSizes,
        b2bColors: b2bColors,
      );

      final vendorOrderCtrl = Get.find<VendorOrderController>();
      vendorOrderCtrl.orders.insert(0, newOrder);

      // Clear cart
      if (isB2B.value) {
        b2bCart.clearCart();
      } else {
        b2cCart.clearCart();
      }

      isProcessing.value = false;

      final double sw = Get.context != null ? Get.context!.width : 375.0;
      _showSuccessDialog(orderIdStr, sw);
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar(
        'Order Error',
        'Could not complete checkout flow: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }

  void _showSuccessDialog(String orderId, double sw) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sw * 0.02,
          ),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: sw * 0.15,
                height: sw * 0.15,
                decoration: const BoxDecoration(
                  color: AppColors.camel,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: sw * 0.08,
                ),
              ),
              SizedBox(height: sw * 0.03),
              Text(
                'ORDER PLACED',
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.05,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: sw * 0.02),
              Text(
                'Your order $orderId has been submitted successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppColors.ink,
                  fontSize: sw * 0.035,
                ),
              ),
              SizedBox(height: sw * 0.05),
              CustomButton(
                text: 'Track Order',
                buttonColor: AppColors.charcoal,
                textColor: Colors.white,
                width: double.infinity,
                borderRadius: 10,
                onPressed: () {
                  final String homeRoute = isB2B.value
                      ? '/b2b-portal'
                      : '/home';
                  Get.until(
                    (route) =>
                        route.settings.name == homeRoute || route.isFirst,
                  );
                  Get.toNamed('/customer-tracking');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
