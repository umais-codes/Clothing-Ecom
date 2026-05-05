import 'package:flutter/material.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
          borderRadius: .circular(sw * 0.04),
          border: .all(
            color: AppColors.greyLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: .vertical(top: .circular(sw * 0.04)),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: .cover,
                  width: .infinity,
                  placeholder: (context, url) =>
                      Container(color: AppColors.offWhite),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: .all(sw * 0.03),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.035,
                      fontWeight: .w700,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  SizedBox(height: sw * 0.01),
                  Text(
                    item.composition,
                    style: GoogleFonts.outfit(
                      fontSize: sw * 0.028,
                      color: AppColors.grey,
                      fontWeight: .w500,
                    ),
                  ),
                  SizedBox(height: sw * 0.02),
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        "\$${item.price.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontWeight: .w700,
                          color: AppColors.camel,
                          fontSize: sw * 0.035,
                        ),
                      ),
                      Container(
                        padding: .symmetric(
                          horizontal: sw * 0.02,
                          vertical: sw * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(sw * 0.01),
                        ),
                        child: Text(
                          "MIN ${item.minQty}",
                          style: GoogleFonts.outfit(
                            fontSize: sw * 0.022,
                            color: AppColors.grey,
                            fontWeight: .w700,
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
