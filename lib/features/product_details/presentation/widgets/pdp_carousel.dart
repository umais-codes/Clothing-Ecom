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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: sw * 0.65,
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
        ),
        Positioned(
          bottom: sw * 0.02,
          child: Row(
            mainAxisAlignment: .center,
            children: [0, 1, 2].map((i) {
              return Container(
                width: sw * 0.015,
                height: sw * 0.015,
                margin: .symmetric(horizontal: sw * 0.01),
                decoration: BoxDecoration(
                  shape: .circle,
                  color: i == 0
                      ? AppColors.charcoal
                      : AppColors.greyLight.withValues(alpha: 0.6),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
