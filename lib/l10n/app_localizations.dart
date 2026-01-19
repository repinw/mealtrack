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

  /// No description provided for @noAvailableProducts.
  ///
  /// In de, this message translates to:
  /// **'Keine Produkte erkannt'**
  String get noAvailableProducts;

  /// No description provided for @addReceipt.
  ///
  /// In de, this message translates to:
  /// **'Kassenbon hinzufügen'**
  String get addReceipt;

  /// No description provided for @selectOption.
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

  /// No description provided for @archive.
  ///
  /// In de, this message translates to:
  /// **'Archivieren'**
  String get archive;

  /// No description provided for @archived.
  ///
  /// In de, this message translates to:
  /// **'Archiviert'**
  String get archived;

  /// No description provided for @archivedCount.
  ///
  /// In de, this message translates to:
  /// **'{count} archivierte Kassenbons'**
  String archivedCount(int count);

  /// No description provided for @unarchive.
  ///
  /// In de, this message translates to:
  /// **'Reaktivieren'**
  String get unarchive;

  /// No description provided for @entries.
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge'**
  String entries(int count);

  /// No description provided for @filterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get filterAll;

  /// No description provided for @filterAvailable.
  ///
  /// In de, this message translates to:
  /// **'Vorrat'**
  String get filterAvailable;

  /// No description provided for @filterEmpty.
  ///
  /// In de, this message translates to:
  /// **'Verbraucht'**
  String get filterEmpty;

  /// No description provided for @verifyScan.
  ///
  /// In de, this message translates to:
  /// **'SCAN ÜBERPRÜFEN'**
  String get verifyScan;

  /// No description provided for @positions.
  ///
  /// In de, this message translates to:
  /// **'POSITIONEN'**
  String get positions;

  /// No description provided for @articles.
  ///
  /// In de, this message translates to:
  /// **'{count} Artikel'**
  String articles(int count);

  /// No description provided for @amountAbbr.
  ///
  /// In de, this message translates to:
  /// **'ANZ'**
  String get amountAbbr;

  /// No description provided for @brandDescription.
  ///
  /// In de, this message translates to:
  /// **'MARKE / BESCHREIBUNG'**
  String get brandDescription;

  /// No description provided for @weight.
  ///
  /// In de, this message translates to:
  /// **'GEWICHT'**
  String get weight;

  /// No description provided for @price.
  ///
  /// In de, this message translates to:
  /// **'PREIS'**
  String get price;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @total.
  ///
  /// In de, this message translates to:
  /// **'GESAMT'**
  String get total;

  /// No description provided for @noAvailableItems.
  ///
  /// In de, this message translates to:
  /// **'Keine verfügbaren Artikel'**
  String get noAvailableItems;

  /// No description provided for @noItemsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Artikel gefunden'**
  String get noItemsFound;

  /// No description provided for @debugHiveReset.
  ///
  /// In de, this message translates to:
  /// **'Debug: Hive Reset'**
  String get debugHiveReset;

  /// No description provided for @debugDataDeleted.
  ///
  /// In de, this message translates to:
  /// **'Debug: Alle Daten gelöscht'**
  String get debugDataDeleted;

  /// No description provided for @imageUploading.
  ///
  /// In de, this message translates to:
  /// **'Bild wird hochgeladen und analysiert...'**
  String get imageUploading;

  /// No description provided for @noTextFromAi.
  ///
  /// In de, this message translates to:
  /// **'Kein Text von der KI erhalten.'**
  String get noTextFromAi;

  /// No description provided for @aiResult.
  ///
  /// In de, this message translates to:
  /// **'KI Ergebnis: '**
  String get aiResult;

  /// No description provided for @aiRequestError.
  ///
  /// In de, this message translates to:
  /// **'Fehler bei der KI-Anfrage: '**
  String get aiRequestError;

  /// No description provided for @emptyJsonString.
  ///
  /// In de, this message translates to:
  /// **'Leerer JSON-String empfangen.'**
  String get emptyJsonString;

  /// No description provided for @sanitizedJsonEmpty.
  ///
  /// In de, this message translates to:
  /// **'Bereinigter JSON-String ist leer.'**
  String get sanitizedJsonEmpty;

  /// No description provided for @unexpectedJsonFormat.
  ///
  /// In de, this message translates to:
  /// **'Unerwartetes JSON-Format empfangen: '**
  String get unexpectedJsonFormat;

  /// No description provided for @jsonParsingError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Parsen des JSON: '**
  String get jsonParsingError;

  /// No description provided for @unknownStorename.
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Laden'**
  String get unknownStorename;

  /// No description provided for @unknownArticle.
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Artikel'**
  String get unknownArticle;

  /// No description provided for @defaultStoreName.
  ///
  /// In de, this message translates to:
  /// **'Ladenname'**
  String get defaultStoreName;

  /// No description provided for @pleaseSelectPdf.
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle eine PDF-Datei.'**
  String get pleaseSelectPdf;

  /// No description provided for @digitalFridge.
  ///
  /// In de, this message translates to:
  /// **'Digitaler Kühlschrank'**
  String get digitalFridge;

  /// No description provided for @imageFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Bild aus Galerie'**
  String get imageFromGallery;

  /// No description provided for @imageFromCamera.
  ///
  /// In de, this message translates to:
  /// **'Bild aufnehmen'**
  String get imageFromCamera;

  /// No description provided for @imageFromPdf.
  ///
  /// In de, this message translates to:
  /// **'Aus PDF'**
  String get imageFromPdf;

  /// No description provided for @receiptReadErrorFormat.
  ///
  /// In de, this message translates to:
  /// **'Der Kassenbon konnte nicht gelesen werden (Format-Fehler).'**
  String get receiptReadErrorFormat;

  /// No description provided for @errorOccurred.
  ///
  /// In de, this message translates to:
  /// **'Ein Fehler ist aufgetreten: '**
  String get errorOccurred;

  /// No description provided for @quantityUpdateFailed.
  ///
  /// In de, this message translates to:
  /// **'Menge konnte nicht aktualisiert werden. Bitte erneut versuchen.'**
  String get quantityUpdateFailed;

  /// No description provided for @loading.
  ///
  /// In de, this message translates to:
  /// **'Lädt...'**
  String get loading;

  /// No description provided for @initializingApp.
  ///
  /// In de, this message translates to:
  /// **'App wird initialisiert...'**
  String get initializingApp;

  /// No description provided for @errorInitializing.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Initialisieren der App: {error}'**
  String errorInitializing(Object error);

  /// No description provided for @retry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get retry;

  /// No description provided for @guestMode.
  ///
  /// In de, this message translates to:
  /// **'Gast-Modus'**
  String get guestMode;

  /// No description provided for @guestModeDescription.
  ///
  /// In de, this message translates to:
  /// **'Sie nutzen die App derzeit als Gast. Verknüpfen Sie Ihr Konto mit einer E-Mail oder Google, um Ihre Daten zu sichern und auf mehreren Geräten zu synchronisieren.'**
  String get guestModeDescription;

  /// No description provided for @linkAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto verknüpfen'**
  String get linkAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In de, this message translates to:
  /// **'Neues Konto erstellen'**
  String get createNewAccount;

  /// No description provided for @useExistingAccount.
  ///
  /// In de, this message translates to:
  /// **'Bestehendes Konto nutzen'**
  String get useExistingAccount;

  /// No description provided for @linkAccountSuccess.
  ///
  /// In de, this message translates to:
  /// **'Konto erfolgreich verknüpft!'**
  String get linkAccountSuccess;

  /// No description provided for @warning.
  ///
  /// In de, this message translates to:
  /// **'Achtung'**
  String get warning;

  /// No description provided for @linkAccountExistingWarning.
  ///
  /// In de, this message translates to:
  /// **'Wenn Sie sich mit einem bestehenden Konto anmelden möchten, werden alle Daten Ihres aktuellen Gast-Kontos gelöscht.\n\nSie werden zur Startseite weitergeleitet, wo Sie sich einloggen können.'**
  String get linkAccountExistingWarning;

  /// No description provided for @proceed.
  ///
  /// In de, this message translates to:
  /// **'Fortfahren'**
  String get proceed;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @userAccount.
  ///
  /// In de, this message translates to:
  /// **'Benutzerkonto'**
  String get userAccount;

  /// No description provided for @name.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// No description provided for @id.
  ///
  /// In de, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @notAvailable.
  ///
  /// In de, this message translates to:
  /// **'Nicht verfügbar'**
  String get notAvailable;

  /// No description provided for @logout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In de, this message translates to:
  /// **'Account löschen'**
  String get deleteAccount;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In de, this message translates to:
  /// **'Account löschen?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In de, this message translates to:
  /// **'Diese Aktion kann nicht rückgängig gemacht werden. Alle Ihre Daten werden unwiderruflich gelöscht.\n\nMöchten Sie Ihren Account wirklich löschen?'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen: '**
  String get deleteAccountError;

  /// No description provided for @howShouldWeCallYou.
  ///
  /// In de, this message translates to:
  /// **'Wie möchtest du genannt werden?'**
  String get howShouldWeCallYou;

  /// No description provided for @yourName.
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get yourName;

  /// No description provided for @next.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// No description provided for @errorLabel.
  ///
  /// In de, this message translates to:
  /// **'Fehler: '**
  String get errorLabel;

  /// No description provided for @welcomeTitle.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei MealTrack!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Behalte den Überblick über deine Lebensmittel'**
  String get welcomeSubtitle;

  /// No description provided for @loginBtn.
  ///
  /// In de, this message translates to:
  /// **'Einloggen'**
  String get loginBtn;

  /// No description provided for @continueGuestBtn.
  ///
  /// In de, this message translates to:
  /// **'Als Gast fortsetzen'**
  String get continueGuestBtn;

  /// No description provided for @existingAccountFound.
  ///
  /// In de, this message translates to:
  /// **'Bestehendes Konto gefunden'**
  String get existingAccountFound;

  /// No description provided for @existingAccountFoundDescription.
  ///
  /// In de, this message translates to:
  /// **'Dieses Konto ist bereits registriert. Wenn Sie fortfahren, gehen alle Daten Ihres aktuellen Gast-Kontos verloren.\n\nMöchten Sie sich trotzdem mit dem bestehenden Konto anmelden?'**
  String get existingAccountFoundDescription;

  /// No description provided for @signedInWithExistingAccount.
  ///
  /// In de, this message translates to:
  /// **'Sie wurden mit Ihrem bestehenden Konto angemeldet.'**
  String get signedInWithExistingAccount;

  /// No description provided for @signInErrorPrefix.
  ///
  /// In de, this message translates to:
  /// **'Fehler bei der Anmeldung: '**
  String get signInErrorPrefix;

  /// No description provided for @signInSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bitte melden Sie sich an, um fortzufahren.'**
  String get signInSubtitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bitte erstellen Sie ein Konto, um fortzufahren'**
  String get signUpSubtitle;

  /// No description provided for @signInAction.
  ///
  /// In de, this message translates to:
  /// **'anmelden'**
  String get signInAction;

  /// No description provided for @signUpAction.
  ///
  /// In de, this message translates to:
  /// **'registrieren'**
  String get signUpAction;

  /// No description provided for @tosDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Durch {action} stimmen Sie unseren Nutzungsbedingungen zu.'**
  String tosDisclaimer(String action);

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @stockValue.
  ///
  /// In de, this message translates to:
  /// **'VORRATSWERT'**
  String get stockValue;

  /// No description provided for @sharing.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get sharing;

  /// No description provided for @invite.
  ///
  /// In de, this message translates to:
  /// **'Einladen'**
  String get invite;

  /// No description provided for @join.
  ///
  /// In de, this message translates to:
  /// **'Beitreten'**
  String get join;

  /// No description provided for @generateCode.
  ///
  /// In de, this message translates to:
  /// **'Code generieren'**
  String get generateCode;

  /// No description provided for @sharingCode.
  ///
  /// In de, this message translates to:
  /// **'Dein Sharing-Code'**
  String get sharingCode;

  /// No description provided for @sharingCodeDescription.
  ///
  /// In de, this message translates to:
  /// **'Teile diesen Code, um deine Vorräte gemeinsam mit anderen zu verwalten.'**
  String get sharingCodeDescription;

  /// No description provided for @enterSharingCode.
  ///
  /// In de, this message translates to:
  /// **'Sharing-Code eingeben'**
  String get enterSharingCode;

  /// No description provided for @joinHousehold.
  ///
  /// In de, this message translates to:
  /// **'Haushalt beitreten'**
  String get joinHousehold;

  /// No description provided for @invalidCode.
  ///
  /// In de, this message translates to:
  /// **'Ungültiger Code'**
  String get invalidCode;

  /// No description provided for @codeExpired.
  ///
  /// In de, this message translates to:
  /// **'Code abgelaufen'**
  String get codeExpired;

  /// No description provided for @codeValidDuration.
  ///
  /// In de, this message translates to:
  /// **'Code ist für 24 Stunden gültig'**
  String get codeValidDuration;

  /// No description provided for @copyCode.
  ///
  /// In de, this message translates to:
  /// **'Code kopieren'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In de, this message translates to:
  /// **'Code kopiert!'**
  String get codeCopied;

  /// No description provided for @convertAccountToShare.
  ///
  /// In de, this message translates to:
  /// **'Bitte verknüpfen Sie Ihr Konto, um einen Haushalt erstellen zu können.'**
  String get convertAccountToShare;

  /// No description provided for @householdMembers.
  ///
  /// In de, this message translates to:
  /// **'Haushaltsmitglieder'**
  String get householdMembers;

  /// No description provided for @you.
  ///
  /// In de, this message translates to:
  /// **'Du'**
  String get you;

  /// No description provided for @removeMember.
  ///
  /// In de, this message translates to:
  /// **'Mitglied entfernen'**
  String get removeMember;

  /// No description provided for @removeMemberConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie dieses Mitglied wirklich aus dem Haushalt entfernen?'**
  String get removeMemberConfirmation;

  /// No description provided for @remove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get remove;

  /// No description provided for @cannotJoinOwnHousehold.
  ///
  /// In de, this message translates to:
  /// **'Sie können nicht Ihrem eigenen Haushalt beitreten.'**
  String get cannotJoinOwnHousehold;

  /// No description provided for @leaveHousehold.
  ///
  /// In de, this message translates to:
  /// **'Haushalt verlassen'**
  String get leaveHousehold;

  /// No description provided for @leaveHouseholdConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie den Haushalt wirklich verlassen?'**
  String get leaveHouseholdConfirmation;

  /// No description provided for @leave.
  ///
  /// In de, this message translates to:
  /// **'Verlassen'**
  String get leave;

  /// No description provided for @inventory.
  ///
  /// In de, this message translates to:
  /// **'Vorrat'**
  String get inventory;

  /// No description provided for @shoppinglist.
  ///
  /// In de, this message translates to:
  /// **'Einkaufsliste'**
  String get shoppinglist;

  /// No description provided for @calories.
  ///
  /// In de, this message translates to:
  /// **'Kalorien'**
  String get calories;

  /// No description provided for @statistics.
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get statistics;

  /// No description provided for @featureInProgress.
  ///
  /// In de, this message translates to:
  /// **'Diese Funktion ist noch in Arbeit 🚧'**
  String get featureInProgress;

  /// No description provided for @addItemNotImplemented.
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

  /// No description provided for @shoppingListEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge'**
  String get shoppingListEmpty;

  /// No description provided for @shoppingListClearTitle.
  ///
  /// In de, this message translates to:
  /// **'Liste leeren?'**
  String get shoppingListClearTitle;

  /// No description provided for @shoppingListClearConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du wirklich alle Einträge löschen?'**
  String get shoppingListClearConfirmation;

  /// No description provided for @errorDisplay.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorDisplay(Object error);

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @addItemTitle.
  ///
  /// In de, this message translates to:
  /// **'Artikel hinzufügen'**
  String get addItemTitle;

  /// No description provided for @addItemHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Milch'**
  String get addItemHint;
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
