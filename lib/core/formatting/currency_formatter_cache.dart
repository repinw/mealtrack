import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyFormatterCache {
  CurrencyFormatterCache._();

  static final Map<String, NumberFormat> _eurFormattersByLocale = {};

  static NumberFormat eurFormatterForLocale(Locale locale) {
    final localeName = locale.toString();
    return _eurFormattersByLocale.putIfAbsent(
      localeName,
      () => NumberFormat.simpleCurrency(locale: localeName, name: 'EUR'),
    );
  }

  static String formatEur(BuildContext context, num value) {
    final locale = Localizations.localeOf(context);
    return eurFormatterForLocale(locale).format(value);
  }
}
