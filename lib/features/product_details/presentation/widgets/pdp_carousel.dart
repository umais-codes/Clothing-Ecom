import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_app/app/theme/app_colors.dart';

class PdpCarousel extends StatelessWidget {
  final double sw;
  final String imageUrl;

  const PdpCarousel({super.key, required this.sw, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: sw * 0.75,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
      ),
      items: [imageUrl, imageUrl, imageUrl].map((url) {
        return Builder(
          builder: (BuildContext context) {
            return CachedNetworkImage(
              imageUrl: url,
              width: sw,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.offWhite),
            );
          },
        );
      }).toList(),
    );
  }
}
