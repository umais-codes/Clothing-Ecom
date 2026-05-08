import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/features/super_admin/presentation/controllers/admin_controller.dart';

class AppDownloader extends StatelessWidget {
  AppDownloader({
    super.key,
    required this.url,
    this.fileName = 'asset',
    this.size = 30,
    this.iconSize = 16,
    this.onDownload,
  });

  final String url;
  final String fileName;
  final double size;
  final double iconSize;
  final VoidCallback? onDownload;

  final RxBool _isLoading = false.obs;

  Future<void> _handleDownload() async {
    if (_isLoading.value) return;
    _isLoading.value = true;

    try {
      if (onDownload != null) {
        onDownload!();
      } else {
        final controller = Get.find<AdminController>();
        await controller.downloadFile(url, fileName);
      }
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleDownload,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.charcoal.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Center(
              child: _isLoading.value
                  ? SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Icon(
                      Icons.file_download_outlined,
                      size: iconSize,
                      color: AppColors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
