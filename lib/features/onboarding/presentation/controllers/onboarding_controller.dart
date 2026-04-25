import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum UserRole { shopper, corporateBuyer, fashionBrand }

class OnboardingController extends GetxController {
  // --- Page Control ---
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxInt carouselPage = 0.obs;

  // --- Role Selection ---
  final Rx<UserRole?> selectedRole = Rx<UserRole?>(null);

  // --- Role Images ---
  final Map<UserRole, String> roleImages = {
    UserRole.shopper:
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=1080&auto=format&fit=crop', // Elegant female fashion
    UserRole.corporateBuyer:
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=1080&auto=format&fit=crop', // High-end suit/business
    UserRole.fashionBrand:
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1080&auto=format&fit=crop', // Minimalist store interior
  };

  // --- Personalization ---
  final RxSet<String> selectedCategories = <String>{}.obs;
  final RxDouble height = 170.0.obs;
  final RxDouble weight = 65.0.obs;
  final RxString selectedFit = 'Regular'.obs;

  // --- Auth ---
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final RxBool otpSent = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool showOtpField = false.obs;

  // --- Carousel Data ---
  final List<Map<String, String>> carouselSlides = [
    {
      'image':
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1080&auto=format&fit=crop',
      'badge': '100% ORIGINAL BRANDS',
      'title': 'Authenticity\nGuaranteed',
      'subtitle':
          'Every brand, every item — verified original. Shop with complete confidence.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?q=80&w=1080&auto=format&fit=crop',
      'badge': 'OPEN PARCEL DELIVERY',
      'title': 'Inspect Before\nYou Accept',
      'subtitle':
          'Check your order before signing off. No more surprises at your door.',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=1080&auto=format&fit=crop',
      'badge': 'AI SIZE PREDICTION',
      'title': 'Your Perfect\nFit Awaits',
      'subtitle':
          'Smart measurements that learn your body. Sizes that fit every time.',
    },
  ];

  final List<String> fitOptions = ['Slim', 'Regular', 'Relaxed'];

  final List<Map<String, dynamic>> categories = [
    {'label': "Men's", 'icon': Icons.man_outlined},
    {'label': "Women's", 'icon': Icons.woman_outlined},
    {'label': 'Modest Wear', 'icon': Icons.favorite_outline},
    {'label': 'Kidswear', 'icon': Icons.child_care_outlined},
    {'label': 'Uniforms', 'icon': Icons.work_outline},
    {'label': 'Accessories', 'icon': Icons.watch_outlined},
  ];

  // --- Actions ---
  void onCarouselPageChanged(int index) => carouselPage.value = index;

  void selectRole(UserRole role) => selectedRole.value = role;

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  void selectFit(String fit) => selectedFit.value = fit;

  void nextPage() {
    if (currentPage.value == 1 && selectedRole.value != UserRole.shopper) {
      pageController.animateToPage(
        3,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
      currentPage.value = 3;
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void prevPage() {
    if (currentPage.value == 3 && selectedRole.value != UserRole.shopper) {
      pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
      currentPage.value = 1;
    } else {
      pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void onPageChanged(int index) => currentPage.value = index;

  void skipOnboarding() => Get.offAllNamed('/home');

  Future<void> sendOtp() async {
    if (phoneController.text.length < 10) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid mobile number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFAF9F6),
        colorText: const Color(0xFF1A1A1A),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulated network call
    isLoading.value = false;
    showOtpField.value = true;
    otpSent.value = true;
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the 6-digit OTP.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFAF9F6),
        colorText: const Color(0xFF1A1A1A),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulated verification
    isLoading.value = false;
    Get.offAllNamed('/home');
  }

  void continueWithGoogle() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.offAllNamed('/home');
    });
  }

  void continueWithApple() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.offAllNamed('/home');
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
