import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class AssetDownloaderUtil {
  static final Dio _dio = Dio();

  static Future<bool> saveToGallery({
    required String url,
    required String fileName,
  }) async {
    try {
      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          _showError('Gallery permission is required to save assets.');
          return false;
        }
      }

      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: fileName,
      );

      if (result['isSuccess'] == true) {
        _showSuccess(fileName);
        return true;
      } else {
        throw 'Failed to save asset to gallery.';
      }
    } catch (e) {
      _showError('Download failed: ${e.toString()}');
      return false;
    }
  }

  static void _showSuccess(String fileName) {
    Get.snackbar(
      'Saved to Gallery',
      'Asset "$fileName" has been saved successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.charcoal,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  static void _showError(String message) {
    Get.snackbar(
      'Download Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }
}
