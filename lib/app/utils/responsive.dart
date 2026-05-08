import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobileView => screenWidth < 700;
  bool get isTabletView => screenWidth >= 700 && screenWidth < 1100;
  bool get isDesktopView => screenWidth >= 1100;

  double wp(double percentage) => screenWidth * (percentage / 100);

  double hp(double percentage) => screenHeight * (percentage / 100);

  double sp(double size) => (screenWidth / 375) * size;
}
