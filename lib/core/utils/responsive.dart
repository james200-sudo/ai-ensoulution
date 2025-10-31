import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 768 &&
      MediaQuery.sizeOf(context).width < 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 768;

  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 400;
    if (isTablet(context)) return 500;
    return double.infinity;
  }

  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.25,
      );
    }
    if (isTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.15,
      );
    }
    return EdgeInsets.symmetric(horizontal: 20.w);
  }

  static double getFontSize(BuildContext context, double mobileSize) {
    if (isDesktop(context)) return mobileSize + 2;
    if (isTablet(context)) return mobileSize + 1;
    return mobileSize;
  }

  static double getCardElevation(BuildContext context) {
    if (isDesktop(context)) return 8;
    if (isTablet(context)) return 6;
    return 4;
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context) && desktop != null) {
      return desktop!;
    }
    if (ResponsiveUtils.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool centerContent;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobile: Scaffold(
        body: child,
      ),
      tablet: Scaffold(
        body: centerContent
            ? Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: child,
                ),
              )
            : child,
      ),
      desktop: Scaffold(
        body: centerContent
            ? Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: ResponsiveUtils.getCardElevation(context),
                    child: child,
                  ),
                ),
              )
            : child,
      ),
    );
  }
}
