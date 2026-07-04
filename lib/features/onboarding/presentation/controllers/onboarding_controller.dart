import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

enum UserRole { shopper, corporateBuyer, fashionBrand }

class OnboardingController extends GetxController {
  // --- Page Control ---
  late final PageController pageController;
  final RxInt currentPage = 0.obs;
  final RxInt carouselPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box('settings');
    
    // Restore drafts if onboarding hasn't been completed yet
    final hasSeen = box.get('hasSeenOnboarding', defaultValue: false) as bool;
    
    if (!hasSeen) {
      final savedRoleStr = box.get('onboarding_selectedRole') as String?;
      if (savedRoleStr != null) {
        for (final role in UserRole.values) {
          if (role.name == savedRoleStr) {
            selectedRole.value = role;
            break;
          }
        }
      }

      final savedCategories = box.get('onboarding_selectedCategories') as List?;
      if (savedCategories != null) {
        selectedCategories.addAll(savedCategories.cast<String>());
      }

      final savedHeight = box.get('onboarding_height') as double?;
      if (savedHeight != null) {
        height.value = savedHeight;
      }

      final savedWeight = box.get('onboarding_weight') as double?;
      if (savedWeight != null) {
        weight.value = savedWeight;
      }

      final savedFit = box.get('onboarding_selectedFit') as String?;
      if (savedFit != null) {
        selectedFit.value = savedFit;
      }

      final savedHasPersonalized = box.get('onboarding_hasPersonalized') as bool?;
      if (savedHasPersonalized != null) {
        hasPersonalized.value = savedHasPersonalized;
      }
    }

    final savedPage = box.get('onboarding_currentPage') as int?;
    if (hasSeen) {
      currentPage.value = 3;
      pageController = PageController(initialPage: 3);
    } else if (savedPage != null) {
      currentPage.value = savedPage;
      pageController = PageController(initialPage: savedPage);
    } else {
      pageController = PageController(initialPage: 0);
    }

    // Set up reactive listeners to persist future changes
    ever(currentPage, (int page) => box.put('onboarding_currentPage', page));
    ever(selectedRole, (UserRole? role) => box.put('onboarding_selectedRole', role?.name));
    ever(selectedCategories, (Set<String> cats) => box.put('onboarding_selectedCategories', cats.toList()));
    ever(height, (double val) => box.put('onboarding_height', val));
    ever(weight, (double val) => box.put('onboarding_weight', val));
    ever(selectedFit, (String fit) => box.put('onboarding_selectedFit', fit));
    ever(hasPersonalized, (bool val) => box.put('onboarding_hasPersonalized', val));
  }

  void clearOnboardingDrafts() {
    final box = Hive.box('settings');
    box.delete('onboarding_currentPage');
    box.delete('onboarding_selectedRole');
    box.delete('onboarding_selectedCategories');
    box.delete('onboarding_height');
    box.delete('onboarding_weight');
    box.delete('onboarding_selectedFit');
    box.delete('onboarding_hasPersonalized');
  }

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
  final RxBool hasPersonalized = false.obs;

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
    {'label': 'Workwear', 'icon': Icons.work_outline},
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

  void skipOnboarding() {
    Hive.box('settings').put('hasSeenOnboarding', true);
    Get.offAllNamed('/main-navigation');
  }

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
    Get.offAllNamed('/main-navigation');
  }

  void continueWithGoogle() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.offAllNamed('/main-navigation');
    });
  }

  void continueWithApple() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.offAllNamed('/main-navigation');
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
