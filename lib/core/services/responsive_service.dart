import 'package:flutter/material.dart';

abstract class ResponsiveService {
  bool isMobile(BuildContext context);
  bool isTablet(BuildContext context);
  bool isDesktop(BuildContext context);
  double screenWidth(BuildContext context);
  double screenHeight(BuildContext context);
}

class ResponsiveServiceImpl implements ResponsiveService {
  const ResponsiveServiceImpl();

  @override
  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  @override
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

  @override
  bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  @override
  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  @override
  double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}
