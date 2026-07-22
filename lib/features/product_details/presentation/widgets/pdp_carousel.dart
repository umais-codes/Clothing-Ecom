import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecom_app/app/theme/app_colors.dart';
import 'package:ecom_app/app/widgets/custom_network_image.dart';

class PdpCarousel extends StatefulWidget {
  final double sw;
  final List<String> images;

  const PdpCarousel({
    super.key,
    required this.sw,
    required this.images,
  });

  @override
  State<PdpCarousel> createState() => _PdpCarouselState();
}

class _PdpCarouselState extends State<PdpCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isNotEmpty
        ? widget.images
        : [
            'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=600&h=600&fit=crop'
          ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.sw * 0.70,
            viewportFraction: 1.0,
            enableInfiniteScroll: images.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: images.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return CustomNetworkImage(
                  imageUrl: url,
                  width: widget.sw,
                  fit: BoxFit.cover,
                );
              },
            );
          }).toList(),
        ),
        if (images.length > 1)
          Positioned(
            bottom: widget.sw * 0.03,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final bool isActive = _currentIndex == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isActive ? widget.sw * 0.045 : widget.sw * 0.015,
                  height: widget.sw * 0.015,
                  margin: EdgeInsets.symmetric(horizontal: widget.sw * 0.008),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.sw * 0.01),
                    color: isActive
                        ? AppColors.camel
                        : AppColors.charcoal.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
