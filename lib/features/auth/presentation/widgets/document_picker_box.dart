import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/utils/responsive.dart';

class DocumentPickerBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isUploaded;
  final String? fileName;
  final VoidCallback onTap;

  const DocumentPickerBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isUploaded,
    this.fileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = context.screenWidth;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: .infinity,
        padding: .symmetric(vertical: w * 0.04, horizontal: w * 0.04),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.camelLight.withValues(alpha: 0.15)
              : AppColors.white,
          borderRadius: .circular(w * 0.03),
          border: .all(
            color: isUploaded ? AppColors.camel : AppColors.greyLight,
            width: isUploaded ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(
              isUploaded
                  ? Icons.check_circle_rounded
                  : Icons.cloud_upload_outlined,
              color: isUploaded ? AppColors.camel : AppColors.charcoal,
              size: w * 0.08,
            ),
            SizedBox(height: w * 0.02),
            Text(
              isUploaded ? '$title Selected' : 'Upload $title',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: w * 0.038,
                color: isUploaded ? AppColors.camel : AppColors.charcoal,
                fontWeight: .w700,
              ),
            ),
            if (isUploaded && fileName != null) ...[
              SizedBox(height: w * 0.01),
              Container(
                padding: .symmetric(horizontal: w * 0.02, vertical: w * 0.01),
                decoration: BoxDecoration(
                  color: AppColors.camel.withValues(alpha: 0.1),
                  borderRadius: .circular(w * 0.01),
                ),
                child: Text(
                  fileName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.camel,
                    fontWeight: .w600,
                    fontSize: w * 0.028,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (!isUploaded) ...[
              SizedBox(height: w * 0.012),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                  fontSize: w * 0.028,
                ),
                textAlign: .center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
