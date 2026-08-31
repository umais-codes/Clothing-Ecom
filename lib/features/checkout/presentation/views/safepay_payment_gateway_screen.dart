import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class SafepayPaymentGatewayScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final String customerEmail;
  final Function(String trackerToken) onPaymentSuccess;

  const SafepayPaymentGatewayScreen({
    super.key,
    required this.amount,
    required this.orderId,
    required this.customerEmail,
    required this.onPaymentSuccess,
  });

  @override
  State<SafepayPaymentGatewayScreen> createState() =>
      _SafepayPaymentGatewayScreenState();
}

class _SafepayPaymentGatewayScreenState
    extends State<SafepayPaymentGatewayScreen> {
  int _selectedTabIndex = 0; // 0: Card, 1: Raast, 2: Wallets
  final _cardNumberController = TextEditingController(
    text: '4242 4242 4242 4242',
  );
  final _cardHolderController = TextEditingController(text: 'Valued Customer');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '123');

  final _raastIdController = TextEditingController(text: '03001234567');
  final _walletNumberController = TextEditingController(text: '03001234567');
  String _selectedWallet = 'EasyPaisa';

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _raastIdController.dispose();
    _walletNumberController.dispose();
    super.dispose();
  }

  void _startPaymentFlow() {
    // Open 3D Secure / OTP Verification Dialog
    _show3DSecureDialog();
  }

  void _show3DSecureDialog() {
    final double sw = context.screenWidth;
    final otpController = TextEditingController(text: '123456');
    final focusNode = FocusNode();
    int secondsRemaining = 60;
    Timer? countdownTimer;

    Get.dialog(
      StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (
            timer,
          ) {
            if (secondsRemaining > 0) {
              setDialogState(() {
                secondsRemaining--;
              });
            } else {
              timer.cancel();
            }
          });

          final currentOtp = otpController.text;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05),
            child: Container(
              padding: EdgeInsets.all(sw * 0.05),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(sw * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D Secure Bank Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.camel.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.security_rounded,
                              color: AppColors.camel,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Safepay 3D Secure",
                                style: GoogleFonts.outfit(
                                  fontSize: sw * 0.036,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              Text(
                                "Verified by Visa / Mastercard ID Check",
                                style: GoogleFonts.outfit(
                                  fontSize: sw * 0.024,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.grey),
                        onPressed: () {
                          countdownTimer?.cancel();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Info message
                  Text(
                    "A 6-digit verification passcode (OTP) has been sent to your registered number ending in **567.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.028,
                      color: AppColors.charcoal,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: sw * 0.04),

                  // Interactive OTP Segment Display with Hidden Keyboard Input
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hidden Native TextField to capture hardware/software keyboard
                      Opacity(
                        opacity: 0.0,
                        child: TextField(
                          controller: otpController,
                          focusNode: focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onChanged: (val) {
                            setDialogState(() {});
                          },
                        ),
                      ),

                      // Visual 6-Box Segment Row
                      GestureDetector(
                        onTap: () => focusNode.requestFocus(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            final bool hasChar = index < currentOtp.length;
                            final bool isFocused = index == currentOtp.length;
                            final String char = hasChar
                                ? currentOtp[index]
                                : '';

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: sw * 0.11,
                              height: sw * 0.13,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: hasChar
                                    ? AppColors.white
                                    : AppColors.offWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isFocused
                                      ? AppColors.camel
                                      : (hasChar
                                            ? AppColors.charcoal
                                            : AppColors.greyLight),
                                  width: isFocused ? 2.0 : 1.2,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: AppColors.camel.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                char,
                                style: GoogleFonts.outfit(
                                  fontSize: sw * 0.055,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.025),

                  // Quick Auto-fill button & timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          otpController.text = "123456";
                          setDialogState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.camel.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Auto-Fill (123456)",
                            style: GoogleFonts.outfit(
                              fontSize: sw * 0.025,
                              fontWeight: FontWeight.w700,
                              color: AppColors.camelDark,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        secondsRemaining > 0
                            ? "Expires: 00:${secondsRemaining.toString().padLeft(2, '0')}"
                            : "Expired",
                        style: GoogleFonts.outfit(
                          fontSize: sw * 0.026,
                          color: secondsRemaining > 0
                              ? AppColors.grey
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.05),

                  // Confirm Payment Button
                  CustomButton(
                    text: "Authorize & Confirm Payment",
                    width: double.infinity,
                    height: sw * 0.12,
                    buttonColor: AppColors.camel,
                    textColor: AppColors.white,
                    onPressed: () async {
                      countdownTimer?.cancel();
                      Get.back(); // close dialog
                      setState(() {
                        _isProcessing = true;
                      });

                      // Simulate Gateway authorization network delay
                      await Future.delayed(const Duration(milliseconds: 1200));

                      final trackerToken =
                          'track_sp_${DateTime.now().millisecondsSinceEpoch}';
                      if (mounted) {
                        Get.back(); // close gateway screen
                        widget.onPaymentSuccess(trackerToken);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = context.screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.camel,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Safepay",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.camel.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.camel.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  "SANDBOX",
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.camel,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(sw * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Summary Card
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.greyLight.withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "VELVET MAISON",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.camelDark,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Order ${widget.orderId}",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Total Amount",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            "\$${widget.amount.toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sw * 0.04),

                // 2. Tab Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEBED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTabBtn(
                        "Credit/Debit Card",
                        0,
                        Icons.credit_card_rounded,
                      ),
                      _buildTabBtn("Raast Pay", 1, Icons.bolt_rounded),
                      _buildTabBtn(
                        "Wallets",
                        2,
                        Icons.account_balance_wallet_rounded,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sw * 0.04),

                // 3. Tab Content
                if (_selectedTabIndex == 0) _buildCardForm(sw),
                if (_selectedTabIndex == 1) _buildRaastForm(sw),
                if (_selectedTabIndex == 2) _buildWalletForm(sw),

                SizedBox(height: sw * 0.06),

                // 4. Pay Button
                CustomButton(
                  text: "Pay Securely \$${widget.amount.toStringAsFixed(2)}",
                  width: double.infinity,
                  height: sw * 0.13,
                  buttonColor: AppColors.charcoal,
                  textColor: AppColors.white,
                  onPressed: _startPaymentFlow,
                ),
                SizedBox(height: sw * 0.03),

                // Security trust badge
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "End-to-end encrypted via Safepay Checkout Terminal",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sw * 0.05),
              ],
            ),
          ),

          // Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.camel),
                      const SizedBox(height: 16),
                      Text(
                        "Processing Safepay Payment...",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBtn(String title, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.camel : AppColors.grey,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.charcoal : AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Virtual Card Preview Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF232526), Color(0xFF414345)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SAFEPAY SECURE",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.camel,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Icon(
                      Icons.contactless_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _cardNumberController.text.isEmpty
                      ? "•••• •••• •••• ••••"
                      : _cardNumberController.text,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CARDHOLDER",
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            color: Colors.white60,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          _cardHolderController.text.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "EXPIRES",
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            color: Colors.white60,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          _expiryController.text,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: sw * 0.04),

          // Inputs
          _buildInputField(
            label: "Card Number",
            controller: _cardNumberController,
            hint: "4242 4242 4242 4242",
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: sw * 0.03),

          _buildInputField(
            label: "Cardholder Name",
            controller: _cardHolderController,
            hint: "Name as on card",
            icon: Icons.person_outline_rounded,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: sw * 0.03),

          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: "Expiry Date",
                  controller: _expiryController,
                  hint: "MM/YY",
                  icon: Icons.calendar_today_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: "CVV / CVC",
                  controller: _cvvController,
                  hint: "123",
                  icon: Icons.lock_outline_rounded,
                  keyboardType: TextInputType.number,
                  obscure: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRaastForm(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Raast Instant Payment",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      "State Bank of Pakistan Instant Settlement",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _buildInputField(
            label: "Registered Raast ID / Mobile Number",
            controller: _raastIdController,
            hint: "03001234567 or IBAN",
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Text(
            "You will receive an authorization prompt on your banking app to approve this transaction.",
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.grey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletForm(double sw) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Mobile Wallet",
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildWalletOption("EasyPaisa", Icons.account_balance_wallet),
              const SizedBox(width: 10),
              _buildWalletOption("JazzCash", Icons.phone_iphone),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: "$_selectedWallet Mobile Number",
            controller: _walletNumberController,
            hint: "03001234567",
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOption(String name, IconData icon) {
    final isSelected = _selectedWallet == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedWallet = name),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.camel.withValues(alpha: 0.1)
                : AppColors.offWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.camel : AppColors.greyLight,
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.camel : AppColors.charcoal,
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.camelDark : AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.6),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            onChanged: onChanged,
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.charcoal),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.grey,
              ),
              prefixIcon: Icon(icon, size: 18, color: AppColors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
