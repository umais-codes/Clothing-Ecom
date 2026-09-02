import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecom_app/app/widgets/custom_snackbar.dart';

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
      final result = await ImageGallerySaverPlus.saveImage(
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
    AppSnackbar.success(
      title: 'Saved to Gallery',
      message: 'Asset "$fileName" has been saved successfully.',
    );
  }

  static void _showError(String message) {
    AppSnackbar.error(
      title: 'Download Error',
      message: message,
    );
  }
}
