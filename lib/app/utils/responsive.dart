import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobileMax = 700;
  static const double tabletMax = 1100;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobileView => screenWidth < ResponsiveBreakpoints.mobileMax;

  bool get isTabletView =>
      screenWidth >= ResponsiveBreakpoints.mobileMax &&
      screenWidth < ResponsiveBreakpoints.tabletMax;

  bool get isDesktopView => screenWidth >= ResponsiveBreakpoints.tabletMax;

  double wp(double percentage) => screenWidth * (percentage / 100);

  double hp(double percentage) => screenHeight * (percentage / 100);

  double sp(double size, {double? maxScale}) {
    final scale = screenWidth / 375;
    final scaledSize = scale * size;
    if (maxScale != null) {
      return scaledSize.clamp(size, size * maxScale);
    }
    if (isDesktopView) {
      return size * 1.25;
    } else if (isTabletView) {
      return size * 1.15;
    }
    return scaledSize;
  }

  double get paddingTop => MediaQuery.paddingOf(this).top;
  double get paddingBottom => MediaQuery.paddingOf(this).bottom;

  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktopView && desktop != null) return desktop;
    if (isTabletView && tablet != null) return tablet;
    return mobile;
  }
}

/// A widget that builds different layouts based on screen width breakpoints.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.tabletMax &&
            desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= ResponsiveBreakpoints.mobileMax &&
            tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
