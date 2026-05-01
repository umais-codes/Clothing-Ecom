import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';

class BulkUploadSheet extends StatefulWidget {
  final double sw;
  const BulkUploadSheet({super.key, required this.sw});

  @override
  State<BulkUploadSheet> createState() => _BulkUploadSheetState();
}

class _BulkUploadSheetState extends State<BulkUploadSheet> {
  bool isUploading = false;
  double progress = 0.0;

  void simulateUpload() async {
    setState(() {
      isUploading = true;
    });

    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        progress = i / 100;
      });
    }

    setState(() {
      isUploading = false;
    });
    Get.back();
    Get.snackbar('Success', 'CSV uploaded successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.sw * 0.05),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.sw * 0.15,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: widget.sw * 0.06),
          Text(
            'Bulk Upload CSV',
            style: GoogleFonts.outfit(
              fontSize: widget.sw * 0.05,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          SizedBox(height: widget.sw * 0.04),
          GestureDetector(
            onTap: isUploading ? null : simulateUpload,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: widget.sw * 0.1),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.camel, style: BorderStyle.solid, width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: widget.sw * 0.12, color: AppColors.camel),
                  SizedBox(height: widget.sw * 0.02),
                  Text(
                    'Tap to select CSV file',
                    style: GoogleFonts.outfit(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUploading) ...[
            SizedBox(height: widget.sw * 0.06),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.camelLight,
              color: AppColors.camel,
            ),
            SizedBox(height: widget.sw * 0.02),
            Text(
              '${(progress * 100).toInt()}% uploaded',
              style: GoogleFonts.outfit(color: AppColors.grey),
            ),
          ],
          SizedBox(height: widget.sw * 0.06),
        ],
      ),
    );
  }
}
