import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/l10n/l10n.dart';

void main() {
  group('Static constants', () {
    test('AppLocalizations constants are accessible', () {
      expect(L10n.noAvailableProducts, isNotEmpty);
      expect(L10n.noAvailableItems, isNotEmpty);
      expect(L10n.noItemsFound, isNotEmpty);
      expect(L10n.debugHiveReset, isNotEmpty);
      expect(L10n.debugDataDeleted, isNotEmpty);
      expect(L10n.imageUploading, isNotEmpty);
      expect(L10n.noTextFromAi, isNotEmpty);
      expect(L10n.aiResult, isNotEmpty);
      expect(L10n.aiRequestError, isNotEmpty);
      expect(L10n.emptyJsonString, isNotEmpty);
      expect(L10n.sanitizedJsonEmpty, isNotEmpty);
      expect(L10n.unexpectedJsonFormat, isNotEmpty);
      expect(L10n.jsonParsingError, isNotEmpty);
      expect(L10n.unknownStorename, isNotEmpty);
      expect(L10n.unknownArticle, isNotEmpty);
      expect(L10n.defaultStoreName, isNotEmpty);
      expect(L10n.pleaseSelectPdf, isNotEmpty);
      expect(L10n.digitalFridge, isNotEmpty);
      expect(L10n.imageFromGallery, isNotEmpty);
      expect(L10n.imageFromCamera, isNotEmpty);
      expect(L10n.imageFromPdf, isNotEmpty);
      expect(L10n.receiptReadErrorFormat, isNotEmpty);
      expect(L10n.errorOccurred, isNotEmpty);
      expect(L10n.quantityUpdateFailed, isNotEmpty);
      expect(L10n.loading, isNotEmpty);
    });

    test('Additional constants are accessible', () {
      expect(L10n.addReceipt, isNotEmpty);
      expect(L10n.selectOption, isNotEmpty);
      expect(L10n.archive, isNotEmpty);
      expect(L10n.filterAll, isNotEmpty);
      expect(L10n.filterAvailable, isNotEmpty);
      expect(L10n.filterEmpty, isNotEmpty);
      expect(L10n.verifyScan, isNotEmpty);
      expect(L10n.positions, isNotEmpty);
      expect(L10n.amountAbbr, isNotEmpty);
      expect(L10n.brandDescription, isNotEmpty);
      expect(L10n.weight, isNotEmpty);
      expect(L10n.price, isNotEmpty);
      expect(L10n.save, isNotEmpty);
      expect(L10n.total, isNotEmpty);
      expect(L10n.initializingApp, isNotEmpty);
      expect(L10n.retry, isNotEmpty);
    });
  });

  group('Dynamic methods', () {
    test('purchases returns formatted string with count', () {
      expect(L10n.purchases(0), '0 Einkäufe');
      expect(L10n.purchases(1), '1 Einkäufe');
      expect(L10n.purchases(5), '5 Einkäufe');
    });

    test('items returns formatted string with count', () {
      expect(L10n.items(0), '0 Teile');
      expect(L10n.items(1), '1 Teile');
      expect(L10n.items(10), '10 Teile');
    });

    test('entries returns formatted string with count', () {
      expect(L10n.entries(0), '0 Einträge');
      expect(L10n.entries(1), '1 Einträge');
      expect(L10n.entries(3), '3 Einträge');
    });

    test('articles returns formatted string with count', () {
      expect(L10n.articles(0), '0 Artikel');
      expect(L10n.articles(1), '1 Artikel');
      expect(L10n.articles(7), '7 Artikel');
    });

    test('errorInitializing returns formatted error message', () {
      expect(
        L10n.errorInitializing('Network error'),
        'Fehler beim Initialisieren der App: Network error',
      );
      expect(L10n.errorInitializing(Exception('test')), contains('Exception'));
    });
  });
}
