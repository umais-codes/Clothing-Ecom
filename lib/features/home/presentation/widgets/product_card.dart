import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;
  final double sw;

  const ProductCard({
    super.key,
    required this.product,
    required this.index,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed('/product-details', arguments: product),
      borderRadius: .circular(sw * 0.04),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          ClipRRect(
            borderRadius: .circular(sw * 0.04),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: index % 2 == 0 ? 0.75 : 1.1,
                  child: CachedNetworkImage(
                    imageUrl: product['image'],
                    fit: .cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.cream),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.cream,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
                if (product['isNew'])
                  Positioned(
                    top: sw * 0.015,
                    left: sw * 0.015,
                    child: Container(
                      padding: .symmetric(
                        horizontal: sw * 0.015,
                        vertical: sw * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.camel,
                        borderRadius: BorderRadius.circular(sw * 0.02),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: sw * 0.025,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: sw * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sw * 0.008),
                Text(
                  '\$${product['price'].toStringAsFixed(0)}',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: sw * 0.034,
                    color: AppColors.camel,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sw * 0.015),
        ],
      ),
    );
  }
}
