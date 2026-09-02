import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';
import 'package:ecom_app/app/widgets/custom_button.dart';

class SafepayPaymentGatewayScreen extends StatelessWidget {
  final double amount;
  final String orderId;
  final String customerEmail;
  final Function(String trackerToken) onPaymentSuccess;

  SafepayPaymentGatewayScreen({
    super.key,
    required this.amount,
    required this.orderId,
    required this.customerEmail,
    required this.onPaymentSuccess,
  });

  final RxInt selectedTabIndex = 0.obs; // 0: Card, 1: Raast, 2: Wallets
  final TextEditingController _cardNumberController = TextEditingController(
    text: '4242 4242 4242 4242',
  );
  final TextEditingController _cardHolderController = TextEditingController(
    text: 'Valued Customer',
  );
  final TextEditingController _expiryController = TextEditingController(
    text: '12/28',
  );
  final TextEditingController _cvvController = TextEditingController(
    text: '123',
  );

  final TextEditingController _raastIdController = TextEditingController(
    text: '03001234567',
  );
  final TextEditingController _walletNumberController = TextEditingController(
    text: '03001234567',
  );
  final RxString selectedWallet = 'EasyPaisa'.obs;

  final RxBool isProcessing = false.obs;

  void _startPaymentFlow(BuildContext context) {
    _show3DSecureDialog(context);
  }

  void _show3DSecureDialog(BuildContext context) {
    final double sw = context.screenWidth;
    final otpController = TextEditingController(text: '123456');
    final focusNode = FocusNode();
    final RxInt secondsRemaining = 60.obs;
    final RxString currentOtp = '123456'.obs;
    Timer? countdownTimer;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });

    Get.dialog(
      Dialog(
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
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      countdownTimer?.cancel();
                      Get.back();
                    },
                  ),
                ],
              ),
              const Divider(height: 24),

              // Transaction Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.greyLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Merchant",
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.028,
                            color: AppColors.grey,
                          ),
                        ),
                        Text(
                          "Velvet Maison Luxury",
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount",
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.028,
                            color: AppColors.grey,
                          ),
                        ),
                        Text(
                          "\$${amount.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.032,
                            fontWeight: FontWeight.w800,
                            color: AppColors.camelDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.04),

              Text(
                "A one-time verification passcode has been simulated for your authentication session.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: sw * 0.028,
                  color: AppColors.ink,
                  height: 1.3,
                ),
              ),
              SizedBox(height: sw * 0.04),

              // Simulated OTP Input
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.0,
                    child: TextField(
                      controller: otpController,
                      focusNode: focusNode,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofocus: true,
                      onChanged: (val) {
                        currentOtp.value = val;
                      },
                    ),
                  ),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final char =
                            index < currentOtp.value.length
                                ? currentOtp.value[index]
                                : "";
                        final isFocused =
                            focusNode.hasFocus &&
                            (index == currentOtp.value.length ||
                                (index == 5 && currentOtp.value.length == 6));
                        final hasChar = char.isNotEmpty;

                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: sw * 0.01),
                          width: sw * 0.11,
                          height: sw * 0.13,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                hasChar ? AppColors.white : AppColors.offWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isFocused
                                      ? AppColors.camel
                                      : (hasChar
                                          ? AppColors.charcoal
                                          : AppColors.greyLight),
                              width: isFocused ? 2.0 : 1.2,
                            ),
                            boxShadow:
                                isFocused
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
                      currentOtp.value = "123456";
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
                  Obx(
                    () => Text(
                      secondsRemaining.value > 0
                          ? "Expires: 00:${secondsRemaining.value.toString().padLeft(2, '0')}"
                          : "Expired",
                      style: GoogleFonts.outfit(
                        fontSize: sw * 0.026,
                        color:
                            secondsRemaining.value > 0
                                ? AppColors.grey
                                : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
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
                  isProcessing.value = true;

                  // Simulate Gateway authorization network delay
                  await Future.delayed(const Duration(milliseconds: 1200));

                  final trackerToken =
                      'track_sp_${DateTime.now().millisecondsSinceEpoch}';
                  Get.back(); // close gateway screen
                  onPaymentSuccess(trackerToken);
                },
              ),
            ],
          ),
        ),
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
                            "Order $orderId",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            customerEmail,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Total Payable",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            "\$${amount.toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
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
                Obx(() {
                  if (selectedTabIndex.value == 0) return _buildCardForm(sw);
                  if (selectedTabIndex.value == 1) return _buildRaastForm(sw);
                  return _buildWalletForm(sw);
                }),

                SizedBox(height: sw * 0.06),

                // 4. Pay Button
                CustomButton(
                  text: "Pay Securely \$${amount.toStringAsFixed(2)}",
                  width: double.infinity,
                  height: sw * 0.13,
                  buttonColor: AppColors.charcoal,
                  textColor: AppColors.white,
                  onPressed: () => _startPaymentFlow(context),
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
          Obx(() {
            if (!isProcessing.value) return const SizedBox.shrink();
            return Container(
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabBtn(String title, int index, IconData icon) {
    return Expanded(
      child: Obx(() {
        final isSelected = selectedTabIndex.value == index;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            selectedTabIndex.value = index;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow:
                  isSelected
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
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.charcoal : AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
                          "CARD HOLDER",
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyLight,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          _cardHolderController.text.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "EXPIRES",
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyLight,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          _expiryController.text,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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

          _buildInputField(
            label: "Card Number",
            controller: _cardNumberController,
            hint: "4242 •••• •••• 4242",
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            label: "Cardholder Name",
            controller: _cardHolderController,
            hint: "e.g. John Doe",
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: "Expiry Date",
                  controller: _expiryController,
                  hint: "MM/YY",
                  icon: Icons.calendar_today_rounded,
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: "CVV / CVC",
                  controller: _cvvController,
                  hint: "123",
                  icon: Icons.security_rounded,
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
                  color: const Color(0xFF007A3D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFF007A3D),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "State Bank of Pakistan Raast",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    "Instant 0% fee peer-to-merchant clearing",
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: "Raast ID (Registered Mobile / IBAN)",
            controller: _raastIdController,
            hint: "03001234567 or PK00RAST...",
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          Text(
            "Upon confirmation, you will receive an in-app push request from your Raast-linked banking app.",
            style: GoogleFonts.outfit(
              fontSize: 11,
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
          Obx(
            () => _buildInputField(
              label: "${selectedWallet.value} Mobile Number",
              controller: _walletNumberController,
              hint: "03001234567",
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOption(String name, IconData icon) {
    return Expanded(
      child: Obx(() {
        final isSelected = selectedWallet.value == name;
        return GestureDetector(
          onTap: () => selectedWallet.value = name,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isSelected
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
                    color:
                        isSelected ? AppColors.camelDark : AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
