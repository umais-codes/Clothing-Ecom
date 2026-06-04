import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_network_image.dart';

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
                  child: CustomNetworkImage(
                    imageUrl: product['image'],
                    fit: .cover,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product['price'].toStringAsFixed(0)}',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: sw * 0.034,
                        color: AppColors.camel,
                      ),
                    ),
                    if (product['isB2B'] != true) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.camel,
                            size: sw * 0.035,
                          ),
                          const SizedBox(width: 1),
                          Text(
                            _getProductRating(product['id'] ?? '').toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${_getProductReviewsCount(product['id'] ?? '')})',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: sw * 0.015),
        ],
      ),
    );
  }

  double _getProductRating(String id) {
    switch (id) {
      case 'b2c_1': return 4.9;
      case 'b2c_2': return 4.8;
      case 'b2c_3': return 4.5;
      case 'b2c_4': return 4.7;
      case 'b2c_5': return 4.6;
      case 'b2c_6': return 4.8;
      case 'b2c_7': return 4.4;
      case 'b2c_8': return 4.9;
      case 'b2c_9': return 4.7;
      case 'b2c_10': return 4.3;
      default: return 4.8;
    }
  }

  int _getProductReviewsCount(String id) {
    switch (id) {
      case 'b2c_1': return 18;
      case 'b2c_2': return 24;
      case 'b2c_3': return 15;
      case 'b2c_4': return 9;
      case 'b2c_5': return 11;
      case 'b2c_6': return 31;
      case 'b2c_7': return 8;
      case 'b2c_8': return 14;
      case 'b2c_9': return 22;
      case 'b2c_10': return 7;
      default: return 12;
    }
  }
}
