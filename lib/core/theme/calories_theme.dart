import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mealtrack/core/theme/app_theme.dart';

/// Central style tokens for the Calories feature.
class CaloriesTheme extends ThemeExtension<CaloriesTheme> {
  const CaloriesTheme({
    required this.pagePadding,
    required this.cardPadding,
    required this.sectionSpacing,
    required this.blockSpacing,
    required this.inlineSpacing,
    required this.cardRadius,
    required this.summaryKcalColor,
    required this.subduedTextColor,
    required this.summaryKcalTextStyle,
    required this.sectionTitleTextStyle,
  });

  final EdgeInsets pagePadding;
  final EdgeInsets cardPadding;
  final double sectionSpacing;
  final double blockSpacing;
  final double inlineSpacing;
  final BorderRadius cardRadius;
  final Color summaryKcalColor;
  final Color subduedTextColor;
  final TextStyle summaryKcalTextStyle;
  final TextStyle sectionTitleTextStyle;

  static const CaloriesTheme fallback = CaloriesTheme(
    pagePadding: EdgeInsets.all(16),
    cardPadding: EdgeInsets.all(16),
    sectionSpacing: 12,
    blockSpacing: 16,
    inlineSpacing: 8,
    cardRadius: BorderRadius.all(Radius.circular(14)),
    summaryKcalColor: AppTheme.primaryColor,
    subduedTextColor: Color(0xFF757575),
    summaryKcalTextStyle: TextStyle(
      fontWeight: FontWeight.w700,
      color: AppTheme.primaryColor,
    ),
    sectionTitleTextStyle: TextStyle(
      fontWeight: FontWeight.w700,
      color: AppTheme.primaryColor,
    ),
  );

  static CaloriesTheme of(BuildContext context) {
    return Theme.of(context).extension<CaloriesTheme>() ?? fallback;
  }

  @override
  CaloriesTheme copyWith({
    EdgeInsets? pagePadding,
    EdgeInsets? cardPadding,
    double? sectionSpacing,
    double? blockSpacing,
    double? inlineSpacing,
    BorderRadius? cardRadius,
    Color? summaryKcalColor,
    Color? subduedTextColor,
    TextStyle? summaryKcalTextStyle,
    TextStyle? sectionTitleTextStyle,
  }) {
    return CaloriesTheme(
      pagePadding: pagePadding ?? this.pagePadding,
      cardPadding: cardPadding ?? this.cardPadding,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      blockSpacing: blockSpacing ?? this.blockSpacing,
      inlineSpacing: inlineSpacing ?? this.inlineSpacing,
      cardRadius: cardRadius ?? this.cardRadius,
      summaryKcalColor: summaryKcalColor ?? this.summaryKcalColor,
      subduedTextColor: subduedTextColor ?? this.subduedTextColor,
      summaryKcalTextStyle: summaryKcalTextStyle ?? this.summaryKcalTextStyle,
      sectionTitleTextStyle:
          sectionTitleTextStyle ?? this.sectionTitleTextStyle,
    );
  }

  @override
  CaloriesTheme lerp(ThemeExtension<CaloriesTheme>? other, double t) {
    if (other is! CaloriesTheme) return this;

    return CaloriesTheme(
      pagePadding: EdgeInsets.lerp(pagePadding, other.pagePadding, t)!,
      cardPadding: EdgeInsets.lerp(cardPadding, other.cardPadding, t)!,
      sectionSpacing:
          lerpDouble(sectionSpacing, other.sectionSpacing, t) ?? sectionSpacing,
      blockSpacing:
          lerpDouble(blockSpacing, other.blockSpacing, t) ?? blockSpacing,
      inlineSpacing:
          lerpDouble(inlineSpacing, other.inlineSpacing, t) ?? inlineSpacing,
      cardRadius: BorderRadius.lerp(cardRadius, other.cardRadius, t)!,
      summaryKcalColor:
          Color.lerp(summaryKcalColor, other.summaryKcalColor, t) ??
          summaryKcalColor,
      subduedTextColor:
          Color.lerp(subduedTextColor, other.subduedTextColor, t) ??
          subduedTextColor,
      summaryKcalTextStyle:
          TextStyle.lerp(summaryKcalTextStyle, other.summaryKcalTextStyle, t) ??
          summaryKcalTextStyle,
      sectionTitleTextStyle:
          TextStyle.lerp(
            sectionTitleTextStyle,
            other.sectionTitleTextStyle,
            t,
          ) ??
          sectionTitleTextStyle,
    );
  }
}
