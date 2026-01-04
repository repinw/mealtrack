import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';

void main() {
  group('Static constants', () {
    test('AppLocalizations constants are accessible', () {
      expect(AppLocalizations.noAvailableProducts, isNotEmpty);
      expect(AppLocalizations.noAvailableItems, isNotEmpty);
      expect(AppLocalizations.noItemsFound, isNotEmpty);
      expect(AppLocalizations.debugHiveReset, isNotEmpty);
      expect(AppLocalizations.debugDataDeleted, isNotEmpty);
      expect(AppLocalizations.imageUploading, isNotEmpty);
      expect(AppLocalizations.noTextFromAi, isNotEmpty);
      expect(AppLocalizations.aiResult, isNotEmpty);
      expect(AppLocalizations.aiRequestError, isNotEmpty);
      expect(AppLocalizations.emptyJsonString, isNotEmpty);
      expect(AppLocalizations.sanitizedJsonEmpty, isNotEmpty);
      expect(AppLocalizations.unexpectedJsonFormat, isNotEmpty);
      expect(AppLocalizations.jsonParsingError, isNotEmpty);
      expect(AppLocalizations.unknownStorename, isNotEmpty);
      expect(AppLocalizations.unknownArticle, isNotEmpty);
      expect(AppLocalizations.defaultStoreName, isNotEmpty);
      expect(AppLocalizations.pleaseSelectPdf, isNotEmpty);
      expect(AppLocalizations.digitalFridge, isNotEmpty);
      expect(AppLocalizations.imageFromGallery, isNotEmpty);
      expect(AppLocalizations.imageFromCamera, isNotEmpty);
      expect(AppLocalizations.imageFromPdf, isNotEmpty);
      expect(AppLocalizations.receiptReadErrorFormat, isNotEmpty);
      expect(AppLocalizations.errorOccurred, isNotEmpty);
      expect(AppLocalizations.quantityUpdateFailed, isNotEmpty);
      expect(AppLocalizations.loading, isNotEmpty);
    });

    test('Additional constants are accessible', () {
      expect(AppLocalizations.addReceipt, isNotEmpty);
      expect(AppLocalizations.selectOption, isNotEmpty);
      expect(AppLocalizations.archive, isNotEmpty);
      expect(AppLocalizations.filterAll, isNotEmpty);
      expect(AppLocalizations.filterAvailable, isNotEmpty);
      expect(AppLocalizations.filterEmpty, isNotEmpty);
      expect(AppLocalizations.verifyScan, isNotEmpty);
      expect(AppLocalizations.positions, isNotEmpty);
      expect(AppLocalizations.amountAbbr, isNotEmpty);
      expect(AppLocalizations.brandDescription, isNotEmpty);
      expect(AppLocalizations.weight, isNotEmpty);
      expect(AppLocalizations.price, isNotEmpty);
      expect(AppLocalizations.save, isNotEmpty);
      expect(AppLocalizations.total, isNotEmpty);
      expect(AppLocalizations.initializingApp, isNotEmpty);
      expect(AppLocalizations.retry, isNotEmpty);
    });
  });

  group('Dynamic methods', () {
    test('purchases returns formatted string with count', () {
      expect(AppLocalizations.purchases(0), '0 Einkäufe');
      expect(AppLocalizations.purchases(1), '1 Einkäufe');
      expect(AppLocalizations.purchases(5), '5 Einkäufe');
    });

    test('items returns formatted string with count', () {
      expect(AppLocalizations.items(0), '0 Teile');
      expect(AppLocalizations.items(1), '1 Teile');
      expect(AppLocalizations.items(10), '10 Teile');
    });

    test('entries returns formatted string with count', () {
      expect(AppLocalizations.entries(0), '0 Einträge');
      expect(AppLocalizations.entries(1), '1 Einträge');
      expect(AppLocalizations.entries(3), '3 Einträge');
    });

    test('articles returns formatted string with count', () {
      expect(AppLocalizations.articles(0), '0 Artikel');
      expect(AppLocalizations.articles(1), '1 Artikel');
      expect(AppLocalizations.articles(7), '7 Artikel');
    });

    test('errorInitializing returns formatted error message', () {
      expect(
        AppLocalizations.errorInitializing('Network error'),
        'Fehler beim Initialisieren der App: Network error',
      );
      expect(
        AppLocalizations.errorInitializing(Exception('test')),
        contains('Exception'),
      );
    });
  });

  test('AppLocalizations can be instantiated', () {
    final loc = AppLocalizations();
    expect(loc, isNotNull);
  });
}
