import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_network_image.dart';

class PdpCarousel extends StatelessWidget {
  final double sw;
  final List<String> images;

  PdpCarousel({
    super.key,
    required this.sw,
    required this.images,
  });

  final RxInt currentIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    final imageList = images.isNotEmpty
        ? images
        : [
            'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop'
          ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: sw * 0.70,
            viewportFraction: 1.0,
            enableInfiniteScroll: imageList.length > 1,
            onPageChanged: (index, reason) {
              currentIndex.value = index;
            },
          ),
          items: imageList.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return CustomNetworkImage(
                  imageUrl: url,
                  width: sw,
                  fit: BoxFit.cover,
                );
              },
            );
          }).toList(),
        ),
        if (imageList.length > 1)
          Positioned(
            bottom: sw * 0.03,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageList.length, (i) {
                  final bool isActive = currentIndex.value == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isActive ? sw * 0.045 : sw * 0.015,
                    height: sw * 0.015,
                    margin: EdgeInsets.symmetric(horizontal: sw * 0.008),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(sw * 0.01),
                      color: isActive
                          ? AppColors.camel
                          : AppColors.charcoal.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }
}
