import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment alignment;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = .cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.alignment = .center,
  });

  static ImageProvider provider(String url) {
    return CachedNetworkImageProvider(url);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: .circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        placeholder: (context, url) =>
            placeholder ??
            _buildShimmer(
              width: width ?? .infinity,
              height: height ?? .infinity,
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            _buildErrorWidget(
              context: context,
              width: width ?? .infinity,
              height: height ?? .infinity,
            ),
      ),
    );
  }

  Widget _buildShimmer({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: AppColors.greySubtle,
      highlightColor: AppColors.white.withValues(alpha: 0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.greySubtle,
          borderRadius: .circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildErrorWidget({
    required BuildContext context,
    required double width,
    required double height,
  }) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.greySubtle,
        borderRadius: .circular(borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.grey.withValues(alpha: 0.5),
              size: (width < w * 0.1 || height < w * 0.1) ? w * 0.04 : w * 0.06,
            ),
            if (width > 80 && height > 80) ...[
              SizedBox(height: w * 0.01),
              Text(
                'Failed to load',
                style: TextStyle(
                  color: AppColors.grey.withValues(alpha: 0.5),
                  fontSize: w * 0.03,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
