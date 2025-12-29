import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/l10n/app_localizations.dart';

void main() {
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

  test('AppLocalizations can be instantiated', () {
    final loc = AppLocalizations();
    expect(loc, isNotNull);
  });
}
