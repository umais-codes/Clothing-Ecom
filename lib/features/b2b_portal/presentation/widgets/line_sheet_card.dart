import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../domain/entities/line_sheet_entity.dart';
import '../../../wishlist/domain/models/product_model.dart';

class LineSheetCard extends StatelessWidget {
  final LineSheetEntity item;
  final VoidCallback onTap;

  const LineSheetCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '/product-details',
          arguments: Product(
            id: item.id,
            name: item.name,
            vendorName: 'Corporate Sourcing',
            price: item.price,
            imageUrl: item.imageUrl,
            description: item.composition,
            isB2B: true,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: Border.all(color: AppColors.greyLight.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.04)),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(color: AppColors.offWhite),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(sw * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: sw * 0.035,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sw * 0.01),
                  Text(
                    item.composition,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: sw * 0.028,
                    ),
                  ),
                  SizedBox(height: sw * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${item.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.camel,
                          fontSize: sw * 0.038,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.005),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(sw * 0.01),
                        ),
                        child: Text(
                          "MIN ${item.minQty}",
                          style: TextStyle(
                            color: AppColors.charcoal,
                            fontSize: sw * 0.022,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
