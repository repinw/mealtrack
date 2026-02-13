import 'package:flutter/material.dart';

class ScrollSpacing {
  ScrollSpacing._();

  // Home chrome overlay: nav container (60) + outer bottom margin (20).
  static const double _homeNavigationOverlayHeight = 80.0;

  // Additional breathing room so the last row is tappable above FAB/nav overlap.
  static const double _contentTouchClearance = 64.0;

  static double homeContentBottomPadding(BuildContext context) {
    return MediaQuery.viewPaddingOf(context).bottom +
        _homeNavigationOverlayHeight +
        _contentTouchClearance;
  }
}
