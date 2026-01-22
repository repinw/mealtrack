import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// Message shown when no products are detected.
  ///
  /// In de, this message translates to:
  /// **'Keine Produkte erkannt'**
  String get noAvailableProducts;

  /// Translation for addReceipt
  ///
  /// In de, this message translates to:
  /// **'Kassenbon hinzufügen'**
  String get addReceipt;

  /// Translation for selectOption
  ///
  /// In de, this message translates to:
  /// **'Option wählen'**
  String get selectOption;

  /// No description provided for @purchases.
  ///
  /// In de, this message translates to:
  /// **'{count} Einkäufe'**
  String purchases(int count);

  /// No description provided for @items.
  ///
  /// In de, this message translates to:
  /// **'{count} Teile'**
  String items(int count);

  /// Translation for archive
  ///
  /// In de, this message translates to:
  /// **'Archivieren'**
  String get archive;

  /// Translation for archived
  ///
  /// In de, this message translates to:
  /// **'Archiviert'**
  String get archived;

  /// No description provided for @archivedCount.
  ///
  /// In de, this message translates to:
  /// **'{count} archivierte Kassenbons'**
  String archivedCount(int count);

  /// Translation for unarchive
  ///
  /// In de, this message translates to:
  /// **'Reaktivieren'**
  String get unarchive;

  /// No description provided for @entries.
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge'**
  String entries(int count);

  /// Translation for filterAll
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get filterAll;

  /// Translation for filterAvailable
  ///
  /// In de, this message translates to:
  /// **'Vorrat'**
  String get filterAvailable;

  /// Translation for filterEmpty
  ///
  /// In de, this message translates to:
  /// **'Verbraucht'**
  String get filterEmpty;

  /// Translation for verifyScan
  ///
  /// In de, this message translates to:
  /// **'SCAN ÜBERPRÜFEN'**
  String get verifyScan;

  /// Translation for positions
  ///
  /// In de, this message translates to:
  /// **'POSITIONEN'**
  String get positions;

  /// No description provided for @articles.
  ///
  /// In de, this message translates to:
  /// **'{count} Artikel'**
  String articles(int count);

  /// Translation for amountAbbr
  ///
  /// In de, this message translates to:
  /// **'ANZ'**
  String get amountAbbr;

  /// Translation for brandDescription
  ///
  /// In de, this message translates to:
  /// **'MARKE / BESCHREIBUNG'**
  String get brandDescription;

  /// Translation for weight
  ///
  /// In de, this message translates to:
  /// **'GEWICHT'**
  String get weight;

  /// Translation for price
  ///
  /// In de, this message translates to:
  /// **'PREIS'**
  String get price;

  /// Translation for save
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// Translation for total
  ///
  /// In de, this message translates to:
  /// **'GESAMT'**
  String get total;

  /// Translation for noAvailableItems
  ///
  /// In de, this message translates to:
  /// **'Keine verfügbaren Artikel'**
  String get noAvailableItems;

  /// Translation for noItemsFound
  ///
  /// In de, this message translates to:
  /// **'Keine Artikel gefunden'**
  String get noItemsFound;

  /// Translation for debugHiveReset
  ///
  /// In de, this message translates to:
  /// **'Debug: Hive Reset'**
  String get debugHiveReset;

  /// Translation for debugDataDeleted
  ///
  /// In de, this message translates to:
  /// **'Debug: Alle Daten gelöscht'**
  String get debugDataDeleted;

  /// Translation for imageUploading
  ///
  /// In de, this message translates to:
  /// **'Bild wird hochgeladen und analysiert...'**
  String get imageUploading;

  /// Translation for noTextFromAi
  ///
  /// In de, this message translates to:
  /// **'Kein Text von der KI erhalten.'**
  String get noTextFromAi;

  /// Translation for aiResult
  ///
  /// In de, this message translates to:
  /// **'KI Ergebnis: '**
  String get aiResult;

  /// Translation for aiRequestError
  ///
  /// In de, this message translates to:
  /// **'Fehler bei der KI-Anfrage: '**
  String get aiRequestError;

  /// Translation for emptyJsonString
  ///
  /// In de, this message translates to:
  /// **'Leerer JSON-String empfangen.'**
  String get emptyJsonString;

  /// Translation for sanitizedJsonEmpty
  ///
  /// In de, this message translates to:
  /// **'Bereinigter JSON-String ist leer.'**
  String get sanitizedJsonEmpty;

  /// Translation for unexpectedJsonFormat
  ///
  /// In de, this message translates to:
  /// **'Unerwartetes JSON-Format empfangen: '**
  String get unexpectedJsonFormat;

  /// Translation for jsonParsingError
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Parsen des JSON: '**
  String get jsonParsingError;

  /// Translation for unknownStorename
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Laden'**
  String get unknownStorename;

  /// Translation for unknownArticle
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Artikel'**
  String get unknownArticle;

  /// Translation for defaultStoreName
  ///
  /// In de, this message translates to:
  /// **'Ladenname'**
  String get defaultStoreName;

  /// Translation for pleaseSelectPdf
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle eine PDF-Datei.'**
  String get pleaseSelectPdf;

  /// Translation for digitalFridge
  ///
  /// In de, this message translates to:
  /// **'Digitaler Kühlschrank'**
  String get digitalFridge;

  /// Translation for imageFromGallery
  ///
  /// In de, this message translates to:
  /// **'Bild aus Galerie'**
  String get imageFromGallery;

  /// Translation for imageFromCamera
  ///
  /// In de, this message translates to:
  /// **'Bild aufnehmen'**
  String get imageFromCamera;

  /// Translation for imageFromPdf
  ///
  /// In de, this message translates to:
  /// **'Aus PDF'**
  String get imageFromPdf;

  /// Translation for receiptReadErrorFormat
  ///
  /// In de, this message translates to:
  /// **'Der Kassenbon konnte nicht gelesen werden (Format-Fehler).'**
  String get receiptReadErrorFormat;

  /// Translation for errorOccurred
  ///
  /// In de, this message translates to:
  /// **'Ein Fehler ist aufgetreten: '**
  String get errorOccurred;

  /// Translation for quantityUpdateFailed
  ///
  /// In de, this message translates to:
  /// **'Menge konnte nicht aktualisiert werden. Bitte erneut versuchen.'**
  String get quantityUpdateFailed;

  /// Translation for loading
  ///
  /// In de, this message translates to:
  /// **'Lädt...'**
  String get loading;

  /// Translation for initializingApp
  ///
  /// In de, this message translates to:
  /// **'App wird initialisiert...'**
  String get initializingApp;

  /// No description provided for @errorInitializing.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Initialisieren der App: {error}'**
  String errorInitializing(String error);

  /// Translation for retry
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get retry;

  /// Translation for guestMode
  ///
  /// In de, this message translates to:
  /// **'Gast-Modus'**
  String get guestMode;

  /// Translation for guestModeDescription
  ///
  /// In de, this message translates to:
  /// **'Sie nutzen die App derzeit als Gast. Verknüpfen Sie Ihr Konto mit einer E-Mail oder Google, um Ihre Daten zu sichern und auf mehreren Geräten zu synchronisieren.'**
  String get guestModeDescription;

  /// Translation for linkAccount
  ///
  /// In de, this message translates to:
  /// **'Konto verknüpfen'**
  String get linkAccount;

  /// Translation for createNewAccount
  ///
  /// In de, this message translates to:
  /// **'Neues Konto erstellen'**
  String get createNewAccount;

  /// Translation for useExistingAccount
  ///
  /// In de, this message translates to:
  /// **'Bestehendes Konto nutzen'**
  String get useExistingAccount;

  /// Translation for linkAccountSuccess
  ///
  /// In de, this message translates to:
  /// **'Konto erfolgreich verknüpft!'**
  String get linkAccountSuccess;

  /// Translation for warning
  ///
  /// In de, this message translates to:
  /// **'Achtung'**
  String get warning;

  /// Translation for linkAccountExistingWarning
  ///
  /// In de, this message translates to:
  /// **'Wenn Sie sich mit einem bestehenden Konto anmelden möchten, werden alle Daten Ihres aktuellen Gast-Kontos gelöscht.\n\nSie werden zur Startseite weitergeleitet, wo Sie sich einloggen können.'**
  String get linkAccountExistingWarning;

  /// Translation for proceed
  ///
  /// In de, this message translates to:
  /// **'Fortfahren'**
  String get proceed;

  /// Translation for cancel
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// Translation for delete
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// Translation for userAccount
  ///
  /// In de, this message translates to:
  /// **'Benutzerkonto'**
  String get userAccount;

  /// Translation for name
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name;

  /// Translation for email
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// Translation for id
  ///
  /// In de, this message translates to:
  /// **'ID'**
  String get id;

  /// Translation for notAvailable
  ///
  /// In de, this message translates to:
  /// **'Nicht verfügbar'**
  String get notAvailable;

  /// Translation for logout
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// Translation for deleteAccount
  ///
  /// In de, this message translates to:
  /// **'Account löschen'**
  String get deleteAccount;

  /// Translation for deleteAccountQuestion
  ///
  /// In de, this message translates to:
  /// **'Account löschen?'**
  String get deleteAccountQuestion;

  /// Translation for deleteAccountWarning
  ///
  /// In de, this message translates to:
  /// **'Diese Aktion kann nicht rückgängig gemacht werden. Alle Ihre Daten werden unwiderruflich gelöscht.\n\nMöchten Sie Ihren Account wirklich löschen?'**
  String get deleteAccountWarning;

  /// Translation for deleteAccountError
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen: '**
  String get deleteAccountError;

  /// Translation for howShouldWeCallYou
  ///
  /// In de, this message translates to:
  /// **'Wie möchtest du genannt werden?'**
  String get howShouldWeCallYou;

  /// Translation for yourName
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get yourName;

  /// Translation for enterValidName
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Namen ein'**
  String get enterValidName;

  /// Translation for next
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// Translation for errorLabel
  ///
  /// In de, this message translates to:
  /// **'Fehler: '**
  String get errorLabel;

  /// Translation for welcomeTitle
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei MealTrack!'**
  String get welcomeTitle;

  /// Translation for welcomeSubtitle
  ///
  /// In de, this message translates to:
  /// **'Behalte den Überblick über deine Lebensmittel'**
  String get welcomeSubtitle;

  /// Translation for loginBtn
  ///
  /// In de, this message translates to:
  /// **'Einloggen'**
  String get loginBtn;

  /// Translation for continueGuestBtn
  ///
  /// In de, this message translates to:
  /// **'Als Gast fortsetzen'**
  String get continueGuestBtn;

  /// Translation for existingAccountFound
  ///
  /// In de, this message translates to:
  /// **'Bestehendes Konto gefunden'**
  String get existingAccountFound;

  /// Translation for existingAccountFoundDescription
  ///
  /// In de, this message translates to:
  /// **'Dieses Konto ist bereits registriert. Wenn Sie fortfahren, gehen alle Daten Ihres aktuellen Gast-Kontos verloren.\n\nMöchten Sie sich trotzdem mit dem bestehenden Konto anmelden?'**
  String get existingAccountFoundDescription;

  /// Translation for signedInWithExistingAccount
  ///
  /// In de, this message translates to:
  /// **'Sie wurden mit Ihrem bestehenden Konto angemeldet.'**
  String get signedInWithExistingAccount;

  /// Translation for signInErrorPrefix
  ///
  /// In de, this message translates to:
  /// **'Fehler bei der Anmeldung: '**
  String get signInErrorPrefix;

  /// Translation for signInSubtitle
  ///
  /// In de, this message translates to:
  /// **'Bitte melden Sie sich an, um fortzufahren.'**
  String get signInSubtitle;

  /// Translation for signUpSubtitle
  ///
  /// In de, this message translates to:
  /// **'Bitte erstellen Sie ein Konto, um fortzufahren'**
  String get signUpSubtitle;

  /// Translation for signInAction
  ///
  /// In de, this message translates to:
  /// **'anmelden'**
  String get signInAction;

  /// Translation for signUpAction
  ///
  /// In de, this message translates to:
  /// **'registrieren'**
  String get signUpAction;

  /// No description provided for @tosDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Durch {action} stimmen Sie unseren Nutzungsbedingungen zu.'**
  String tosDisclaimer(String action);

  /// Translation for settings
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// Translation for stockValue
  ///
  /// In de, this message translates to:
  /// **'VORRATSWERT'**
  String get stockValue;

  /// Translation for sharing
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get sharing;

  /// Translation for invite
  ///
  /// In de, this message translates to:
  /// **'Einladen'**
  String get invite;

  /// Translation for join
  ///
  /// In de, this message translates to:
  /// **'Beitreten'**
  String get join;

  /// Translation for generateCode
  ///
  /// In de, this message translates to:
  /// **'Code generieren'**
  String get generateCode;

  /// Translation for sharingCode
  ///
  /// In de, this message translates to:
  /// **'Dein Sharing-Code'**
  String get sharingCode;

  /// Translation for sharingCodeDescription
  ///
  /// In de, this message translates to:
  /// **'Teile diesen Code, um deine Vorräte gemeinsam mit anderen zu verwalten.'**
  String get sharingCodeDescription;

  /// Translation for enterSharingCode
  ///
  /// In de, this message translates to:
  /// **'Sharing-Code eingeben'**
  String get enterSharingCode;

  /// Translation for joinHousehold
  ///
  /// In de, this message translates to:
  /// **'Haushalt beitreten'**
  String get joinHousehold;

  /// Translation for invalidCode
  ///
  /// In de, this message translates to:
  /// **'Ungültiger Code'**
  String get invalidCode;

  /// Translation for codeExpired
  ///
  /// In de, this message translates to:
  /// **'Code abgelaufen'**
  String get codeExpired;

  /// Translation for codeValidDuration
  ///
  /// In de, this message translates to:
  /// **'Code ist für 24 Stunden gültig'**
  String get codeValidDuration;

  /// Translation for copyCode
  ///
  /// In de, this message translates to:
  /// **'Code kopieren'**
  String get copyCode;

  /// Translation for codeCopied
  ///
  /// In de, this message translates to:
  /// **'Code kopiert!'**
  String get codeCopied;

  /// Translation for convertAccountToShare
  ///
  /// In de, this message translates to:
  /// **'Bitte verknüpfen Sie Ihr Konto, um einen Haushalt erstellen zu können.'**
  String get convertAccountToShare;

  /// Translation for householdMembers
  ///
  /// In de, this message translates to:
  /// **'Haushaltsmitglieder'**
  String get householdMembers;

  /// Translation for you
  ///
  /// In de, this message translates to:
  /// **'Du'**
  String get you;

  /// Translation for removeMember
  ///
  /// In de, this message translates to:
  /// **'Mitglied entfernen'**
  String get removeMember;

  /// Translation for removeMemberConfirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie dieses Mitglied wirklich aus dem Haushalt entfernen?'**
  String get removeMemberConfirmation;

  /// Translation for remove
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get remove;

  /// Translation for cannotJoinOwnHousehold
  ///
  /// In de, this message translates to:
  /// **'Sie können nicht Ihrem eigenen Haushalt beitreten.'**
  String get cannotJoinOwnHousehold;

  /// Translation for leaveHousehold
  ///
  /// In de, this message translates to:
  /// **'Haushalt verlassen'**
  String get leaveHousehold;

  /// Translation for leaveHouseholdConfirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie den Haushalt wirklich verlassen?'**
  String get leaveHouseholdConfirmation;

  /// Translation for leave
  ///
  /// In de, this message translates to:
  /// **'Verlassen'**
  String get leave;

  /// Translation for inventory
  ///
  /// In de, this message translates to:
  /// **'Vorrat'**
  String get inventory;

  /// Translation for shoppinglist
  ///
  /// In de, this message translates to:
  /// **'Einkaufsliste'**
  String get shoppinglist;

  /// Translation for calories
  ///
  /// In de, this message translates to:
  /// **'Kalorien'**
  String get calories;

  /// Translation for statistics
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get statistics;

  /// Translation for featureInProgress
  ///
  /// In de, this message translates to:
  /// **'Diese Funktion ist noch in Arbeit 🚧'**
  String get featureInProgress;

  /// Translation for addItemNotImplemented
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen - Noch nicht implementiert'**
  String get addItemNotImplemented;

  /// No description provided for @itemAddedToShoppingList.
  ///
  /// In de, this message translates to:
  /// **'{name} zur Einkaufsliste hinzugefügt'**
  String itemAddedToShoppingList(String name);

  /// No description provided for @unitPriceLabel.
  ///
  /// In de, this message translates to:
  /// **'{price}€ / Stk'**
  String unitPriceLabel(String price);

  /// Translation for shoppingListEmpty
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge'**
  String get shoppingListEmpty;

  /// Translation for shoppingListClearTitle
  ///
  /// In de, this message translates to:
  /// **'Liste leeren?'**
  String get shoppingListClearTitle;

  /// Translation for shoppingListClearConfirmation
  ///
  /// In de, this message translates to:
  /// **'Möchtest du wirklich alle Einträge löschen?'**
  String get shoppingListClearConfirmation;

  /// No description provided for @errorDisplay.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorDisplay(String error);

  /// Translation for add
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// Translation for addItemTitle
  ///
  /// In de, this message translates to:
  /// **'Artikel hinzufügen'**
  String get addItemTitle;

  /// Translation for addItemHint
  ///
  /// In de, this message translates to:
  /// **'z.B. Milch'**
  String get addItemHint;

  /// Translation for approximateCostLabel
  ///
  /// In de, this message translates to:
  /// **'UNGEFÄHRE KOSTEN'**
  String get approximateCostLabel;

  /// Translation for firstLoginRequiresInternet
  ///
  /// In de, this message translates to:
  /// **'Erste Anmeldung benötigt eine Internetverbindung. Versuche es erneut, sobald die Verbindung hergestellt ist.'**
  String get firstLoginRequiresInternet;

  /// Translation for scanReceiptDialogTitle
  ///
  /// In de, this message translates to:
  /// **'Beleg scannen?'**
  String get scanReceiptDialogTitle;

  /// Translation for scanReceiptDialogContent
  ///
  /// In de, this message translates to:
  /// **'Möchtest du dieses Dokument als Kassenbon scannen?'**
  String get scanReceiptDialogContent;

  /// Translation for yes
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// Translation for confirm
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get confirm;

  /// Dialog title for showing discounts included in an item
  ///
  /// In de, this message translates to:
  /// **'Enthaltene Rabatte'**
  String get includedDiscounts;

  /// Placeholder hint for brand input field
  ///
  /// In de, this message translates to:
  /// **'Marke'**
  String get brandHint;

  /// Placeholder hint for item name input field
  ///
  /// In de, this message translates to:
  /// **'Artikelname'**
  String get itemNameHint;

  /// Translation for OK button
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// Label for merchant/store name field
  ///
  /// In de, this message translates to:
  /// **'HÄNDLER'**
  String get merchantLabel;

  /// Placeholder hint for merchant name input
  ///
  /// In de, this message translates to:
  /// **'Händlername'**
  String get merchantHint;

  /// Label for date field
  ///
  /// In de, this message translates to:
  /// **'DATUM'**
  String get dateLabel;

  /// Placeholder hint for date input
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get dateHint;

  /// Confirmation message when deleting an item from receipt
  ///
  /// In de, this message translates to:
  /// **'Artikel wirklich löschen?'**
  String get deleteItemConfirmation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
