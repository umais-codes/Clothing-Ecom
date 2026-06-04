import 'package:ecom_app/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/auth/controllers/auth_controller.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'admin@velvetmaison.pk',
  );
  final TextEditingController _passCtrl = TextEditingController(
    text: 'Admin@1234',
  );
  final RxBool _obscurePass = true.obs;
  final RxBool _isLoading = false.obs;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  // ── Hardcoded admin credentials (replace with secure backend auth in production) ──
  static const String _adminEmail = 'admin@velvetmaison.pk';
  static const String _adminPassword = 'Admin@1234';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim() != _adminEmail ||
        _passCtrl.text != _adminPassword) {
      Get.snackbar(
        'Access Denied',
        'Invalid admin credentials. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    _isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));

    final authCtrl = Get.find<AuthController>();
    authCtrl.selectedRole.value = AuthRole.admin;
    _isLoading.value = false;

    Get.offAllNamed('/admin-panel');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopView;
    final isTablet = context.isTabletView;
    final isMobile = context.isMobileView;

    final horizontalPadding = isDesktop
        ? context.screenWidth * 0.35
        : (isTablet ? context.screenWidth * 0.25 : 20.0);
    final verticalPadding = isMobile ? 24.0 : 40.0;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo / Brand ──────────────────────────────────────────────
                Center(
                  child: Container(
                    width: isMobile ? 52 : 60,
                    height: isMobile ? 52 : 60,
                    decoration: BoxDecoration(
                      color: AppColors.camel,
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.camel.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.white,
                      size: isMobile ? 26 : 30,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 18 : 24),
                Text(
                  'Platform Administration',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: isMobile ? 26 : 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Restricted access — authorised personnel only.',
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 11.5 : 12.5,
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 28 : 36),

                // ── Card ──────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.greyLight, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email
                      _buildLabel('Admin Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailCtrl,
                        hint: 'admin@velvetmaison.pk',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      Obx(
                        () => _buildTextField(
                          controller: _passCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePass.value,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePass.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.grey,
                            ),
                            onPressed: () =>
                                _obscurePass.value = !_obscurePass.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login button
                      Obx(
                        () => _AdminPrimaryButton(
                          label: 'Access Control Panel',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: _isLoading.value,
                          onPressed: _login,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Secured with 256-bit encryption',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(fontSize: 14, color: AppColors.charcoal),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.grey),
          prefixIcon: Icon(icon, size: 18, color: AppColors.grey),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) => _login(),
      ),
    );
  }
}

// ── Reusable primary button for admin screens ──────────────────────────────────
class _AdminPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  const _AdminPrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.camel,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.camel.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.white.withValues(alpha: 0.1),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, size: 16, color: AppColors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
