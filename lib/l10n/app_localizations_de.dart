// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get noAvailableProducts => 'Keine Produkte erkannt';

  @override
  String get addReceipt => 'Kassenbon hinzufügen';

  @override
  String get selectOption => 'Option wählen';

  @override
  String purchases(int count) {
    return '$count Einkäufe';
  }

  @override
  String items(int count) {
    return '$count Teile';
  }

  @override
  String get archive => 'Archivieren';

  @override
  String get archived => 'Archiviert';

  @override
  String archivedCount(int count) {
    return '$count archivierte Kassenbons';
  }

  @override
  String get unarchive => 'Reaktivieren';

  @override
  String entries(int count) {
    return '$count Einträge';
  }

  @override
  String get filterAll => 'Alle';

  @override
  String get filterAvailable => 'Vorrat';

  @override
  String get filterEmpty => 'Verbraucht';

  @override
  String get verifyScan => 'SCAN ÜBERPRÜFEN';

  @override
  String get positions => 'POSITIONEN';

  @override
  String articles(int count) {
    return '$count Artikel';
  }

  @override
  String get amountAbbr => 'ANZ';

  @override
  String get brandDescription => 'MARKE / BESCHREIBUNG';

  @override
  String get weight => 'GEWICHT';

  @override
  String get price => 'PREIS';

  @override
  String get save => 'Speichern';

  @override
  String get total => 'GESAMT';

  @override
  String get noAvailableItems => 'Keine verfügbaren Artikel';

  @override
  String get noItemsFound => 'Keine Artikel gefunden';

  @override
  String get debugHiveReset => 'Debug: Hive Reset';

  @override
  String get debugDataDeleted => 'Debug: Alle Daten gelöscht';

  @override
  String get imageUploading => 'Bild wird hochgeladen und analysiert...';

  @override
  String get noTextFromAi => 'Kein Text von der KI erhalten.';

  @override
  String get aiResult => 'KI Ergebnis: ';

  @override
  String get aiRequestError => 'Fehler bei der KI-Anfrage: ';

  @override
  String get emptyJsonString => 'Leerer JSON-String empfangen.';

  @override
  String get sanitizedJsonEmpty => 'Bereinigter JSON-String ist leer.';

  @override
  String get unexpectedJsonFormat => 'Unerwartetes JSON-Format empfangen: ';

  @override
  String get jsonParsingError => 'Fehler beim Parsen des JSON: ';

  @override
  String get unknownStorename => 'Unbekannter Laden';

  @override
  String get unknownArticle => 'Unbekannter Artikel';

  @override
  String get defaultStoreName => 'Ladenname';

  @override
  String get pleaseSelectPdf => 'Bitte wähle eine PDF-Datei.';

  @override
  String get digitalFridge => 'Digitaler Kühlschrank';

  @override
  String get imageFromGallery => 'Bild aus Galerie';

  @override
  String get imageFromCamera => 'Bild aufnehmen';

  @override
  String get imageFromPdf => 'Aus PDF';

  @override
  String get receiptReadErrorFormat =>
      'Der Kassenbon konnte nicht gelesen werden (Format-Fehler).';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten: ';

  @override
  String get quantityUpdateFailed =>
      'Menge konnte nicht aktualisiert werden. Bitte erneut versuchen.';

  @override
  String get loading => 'Lädt...';

  @override
  String get initializingApp => 'App wird initialisiert...';

  @override
  String errorInitializing(String error) {
    return 'Fehler beim Initialisieren der App: $error';
  }

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get guestMode => 'Gast-Modus';

  @override
  String get guestModeDescription =>
      'Sie nutzen die App derzeit als Gast. Verknüpfen Sie Ihr Konto mit einer E-Mail oder Google, um Ihre Daten zu sichern und auf mehreren Geräten zu synchronisieren.';

  @override
  String get linkAccount => 'Konto verknüpfen';

  @override
  String get createNewAccount => 'Neues Konto erstellen';

  @override
  String get useExistingAccount => 'Bestehendes Konto nutzen';

  @override
  String get linkAccountSuccess => 'Konto erfolgreich verknüpft!';

  @override
  String get warning => 'Achtung';

  @override
  String get linkAccountExistingWarning =>
      'Wenn Sie sich mit einem bestehenden Konto anmelden möchten, werden alle Daten Ihres aktuellen Gast-Kontos gelöscht.\n\nSie werden zur Startseite weitergeleitet, wo Sie sich einloggen können.';

  @override
  String get proceed => 'Fortfahren';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get userAccount => 'Benutzerkonto';

  @override
  String get name => 'Name';

  @override
  String get email => 'E-Mail';

  @override
  String get id => 'ID';

  @override
  String get notAvailable => 'Nicht verfügbar';

  @override
  String get logout => 'Abmelden';

  @override
  String get deleteAccount => 'Account löschen';

  @override
  String get deleteAccountQuestion => 'Account löschen?';

  @override
  String get deleteAccountWarning =>
      'Diese Aktion kann nicht rückgängig gemacht werden. Alle Ihre Daten werden unwiderruflich gelöscht.\n\nMöchten Sie Ihren Account wirklich löschen?';

  @override
  String get deleteAccountError => 'Fehler beim Löschen: ';

  @override
  String get howShouldWeCallYou => 'Wie möchtest du genannt werden?';

  @override
  String get yourName => 'Dein Name';

  @override
  String get enterValidName => 'Bitte gib einen Namen ein';

  @override
  String get next => 'Weiter';

  @override
  String get errorLabel => 'Fehler: ';

  @override
  String get welcomeTitle => 'Willkommen bei MealTrack!';

  @override
  String get welcomeSubtitle => 'Behalte den Überblick über deine Lebensmittel';

  @override
  String get loginBtn => 'Einloggen';

  @override
  String get continueGuestBtn => 'Als Gast fortsetzen';

  @override
  String get existingAccountFound => 'Bestehendes Konto gefunden';

  @override
  String get existingAccountFoundDescription =>
      'Dieses Konto ist bereits registriert. Wenn Sie fortfahren, gehen alle Daten Ihres aktuellen Gast-Kontos verloren.\n\nMöchten Sie sich trotzdem mit dem bestehenden Konto anmelden?';

  @override
  String get signedInWithExistingAccount =>
      'Sie wurden mit Ihrem bestehenden Konto angemeldet.';

  @override
  String get signInErrorPrefix => 'Fehler bei der Anmeldung: ';

  @override
  String get signInSubtitle => 'Bitte melden Sie sich an, um fortzufahren.';

  @override
  String get signUpSubtitle => 'Bitte erstellen Sie ein Konto, um fortzufahren';

  @override
  String get signInAction => 'anmelden';

  @override
  String get signUpAction => 'registrieren';

  @override
  String tosDisclaimer(String action) {
    return 'Durch $action stimmen Sie unseren Nutzungsbedingungen zu.';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get stockValue => 'VORRATSWERT';

  @override
  String get sharing => 'Teilen';

  @override
  String get invite => 'Einladen';

  @override
  String get join => 'Beitreten';

  @override
  String get generateCode => 'Code generieren';

  @override
  String get sharingCode => 'Dein Sharing-Code';

  @override
  String get sharingCodeDescription =>
      'Teile diesen Code, um deine Vorräte gemeinsam mit anderen zu verwalten.';

  @override
  String get enterSharingCode => 'Sharing-Code eingeben';

  @override
  String get joinHousehold => 'Haushalt beitreten';

  @override
  String get invalidCode => 'Ungültiger Code';

  @override
  String get codeExpired => 'Code abgelaufen';

  @override
  String get codeValidDuration => 'Code ist für 24 Stunden gültig';

  @override
  String get copyCode => 'Code kopieren';

  @override
  String get codeCopied => 'Code kopiert!';

  @override
  String get convertAccountToShare =>
      'Bitte verknüpfen Sie Ihr Konto, um einen Haushalt erstellen zu können.';

  @override
  String get householdMembers => 'Haushaltsmitglieder';

  @override
  String get you => 'Du';

  @override
  String get removeMember => 'Mitglied entfernen';

  @override
  String get removeMemberConfirmation =>
      'Möchten Sie dieses Mitglied wirklich aus dem Haushalt entfernen?';

  @override
  String get remove => 'Entfernen';

  @override
  String get cannotJoinOwnHousehold =>
      'Sie können nicht Ihrem eigenen Haushalt beitreten.';

  @override
  String get leaveHousehold => 'Haushalt verlassen';

  @override
  String get leaveHouseholdConfirmation =>
      'Möchten Sie den Haushalt wirklich verlassen?';

  @override
  String get leave => 'Verlassen';

  @override
  String get inventory => 'Vorrat';

  @override
  String get shoppinglist => 'Einkaufsliste';

  @override
  String get calories => 'Kalorien';

  @override
  String get statistics => 'Statistik';

  @override
  String get featureInProgress => 'Diese Funktion ist noch in Arbeit 🚧';

  @override
  String get addItemNotImplemented => 'Hinzufügen - Noch nicht implementiert';

  @override
  String itemAddedToShoppingList(String name) {
    return '$name zur Einkaufsliste hinzugefügt';
  }

  @override
  String unitPriceLabel(String price) {
    return '$price€ / Stk';
  }

  @override
  String get shoppingListEmpty => 'Keine Einträge';

  @override
  String get shoppingListClearTitle => 'Liste leeren?';

  @override
  String get shoppingListClearConfirmation =>
      'Möchtest du wirklich alle Einträge löschen?';

  @override
  String errorDisplay(String error) {
    return 'Fehler: $error';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get addItemTitle => 'Artikel hinzufügen';

  @override
  String get addItemHint => 'z.B. Milch';

  @override
  String get approximateCostLabel => 'UNGEFÄHRE KOSTEN';

  @override
  String get firstLoginRequiresInternet =>
      'Erste Anmeldung benötigt eine Internetverbindung. Versuche es erneut, sobald die Verbindung hergestellt ist.';

  @override
  String get scanReceiptDialogTitle => 'Beleg scannen?';

  @override
  String get scanReceiptDialogContent =>
      'Möchtest du dieses Dokument als Kassenbon scannen?';

  @override
  String get yes => 'Ja';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get includedDiscounts => 'Enthaltene Rabatte';

  @override
  String get brandHint => 'Marke';

  @override
  String get itemNameHint => 'Artikelname';

  @override
  String get ok => 'OK';

  @override
  String get merchantLabel => 'HÄNDLER';

  @override
  String get merchantHint => 'Händlername';

  @override
  String get dateLabel => 'DATUM';

  @override
  String get dateHint => 'Datum';

  @override
  String get deleteItemConfirmation => 'Artikel wirklich löschen?';
}
