/// Static German strings for non-widget classes that don't have BuildContext.
/// This provides the same strings as AppLocalizations but without requiring context.
/// Use AppLocalizations.of(context) in widgets where context is available.
class L10n {
  L10n._();

  static const String noAvailableProducts = 'Keine Produkte erkannt';
  static const String addReceipt = 'Kassenbon hinzufügen';
  static const String selectOption = 'Option wählen';
  static String purchases(int count) => '$count Einkäufe';
  static String items(int count) => '$count Teile';
  static const String archive = 'Archivieren';
  static String entries(int count) => '$count Einträge';

  static const String filterAll = 'Alle';
  static const String filterAvailable = 'Vorrat';
  static const String filterEmpty = 'Verbraucht';

  static const String verifyScan = 'SCAN ÜBERPRÜFEN';
  static const String positions = 'POSITIONEN';
  static String articles(int count) => '$count Artikel';
  static const String amountAbbr = 'ANZ';
  static const String brandDescription = 'MARKE / BESCHREIBUNG';
  static const String weight = 'GEWICHT';
  static const String price = 'PREIS';
  static const String save = 'Speichern';
  static const String total = 'GESAMT';

  static const String noAvailableItems = 'Keine verfügbaren Artikel';
  static const String noItemsFound = 'Keine Artikel gefunden';
  static const String debugHiveReset = 'Debug: Hive Reset';
  static const String debugDataDeleted = 'Debug: Alle Daten gelöscht';

  static const String imageUploading =
      'Bild wird hochgeladen und analysiert...';
  static const String noTextFromAi = 'Kein Text von der KI erhalten.';
  static const String aiResult = 'KI Ergebnis: ';
  static const String aiRequestError = 'Fehler bei der KI-Anfrage: ';

  static const String emptyJsonString = 'Leerer JSON-String empfangen.';
  static const String sanitizedJsonEmpty = 'Bereinigter JSON-String ist leer.';
  static const String unexpectedJsonFormat =
      'Unerwartetes JSON-Format empfangen: ';
  static const String jsonParsingError = 'Fehler beim Parsen des JSON: ';
  static const String unknownStorename = 'Unbekannter Laden';
  static const String unknownArticle = 'Unbekannter Artikel';

  static const String defaultStoreName = 'Ladenname';
  static const String pleaseSelectPdf = 'Bitte wähle eine PDF-Datei.';

  static const String digitalFridge = 'Digitaler Kühlschrank';
  static const String imageFromGallery = 'Bild aus Galerie';
  static const String imageFromCamera = 'Bild aufnehmen';
  static const String imageFromPdf = 'Aus PDF';
  static const String receiptReadErrorFormat =
      'Der Kassenbon konnte nicht gelesen werden (Format-Fehler).';
  static const String errorOccurred = 'Ein Fehler ist aufgetreten: ';
  static const String quantityUpdateFailed =
      'Menge konnte nicht aktualisiert werden. Bitte erneut versuchen.';
  static const String loading = 'Lädt...';

  static const String initializingApp = 'App wird initialisiert...';
  static String errorInitializing(Object error) =>
      'Fehler beim Initialisieren der App: $error';
  static const String retry = 'Erneut versuchen';

  // Account & Guest Mode
  static const String guestMode = 'Gast-Modus';
  static const String guestModeDescription =
      'Sie nutzen die App derzeit als Gast. Verknüpfen Sie Ihr Konto mit einer E-Mail oder Google, um Ihre Daten zu sichern und auf mehreren Geräten zu synchronisieren.';
  static const String linkAccount = 'Konto verknüpfen';
  static const String createNewAccount = 'Neues Konto erstellen';
  static const String useExistingAccount = 'Bestehendes Konto nutzen';
  static const String linkAccountSuccess = 'Konto erfolgreich verknüpft!';

  static const String warning = 'Achtung';
  static const String linkAccountExistingWarning =
      'Wenn Sie sich mit einem bestehenden Konto anmelden möchten, '
      'werden alle Daten Ihres aktuellen Gast-Kontos gelöscht.\n\n'
      'Sie werden zur Startseite weitergeleitet, wo Sie sich einloggen können.';
  static const String proceed = 'Fortfahren';
  static const String cancel = 'Abbrechen';
  static const String delete = 'Löschen';

  static const String userAccount = 'Benutzerkonto';
  static const String name = 'Name';
  static const String email = 'E-Mail';
  static const String id = 'ID';
  static const String notAvailable = 'Nicht verfügbar';
  static const String logout = 'Abmelden';

  static const String deleteAccount = 'Account löschen';
  static const String deleteAccountQuestion = 'Account löschen?';
  static const String deleteAccountWarning =
      'Diese Aktion kann nicht rückgängig gemacht werden. '
      'Alle Ihre Daten werden unwiderruflich gelöscht.\n\n'
      'Möchten Sie Ihren Account wirklich löschen?';
  static const String deleteAccountError = 'Fehler beim Löschen: ';

  // Guest Name Page
  static const String howShouldWeCallYou = 'Wie möchtest du genannt werden?';
  static const String yourName = 'Dein Name';
  static const String next = 'Weiter';
  static const String errorLabel = 'Fehler: ';

  // Welcome Page
  static const String welcomeTitle = 'Willkommen bei MealTrack!';
  static const String welcomeSubtitle =
      'Behalte den Überblick über deine Lebensmittel';
  static const String loginBtn = 'Einloggen';
  static const String continueGuestBtn = 'Als Gast fortsetzen';

  // MySignInScreen
  static const String existingAccountFound = 'Bestehendes Konto gefunden';
  static const String existingAccountFoundDescription =
      'Dieses Konto ist bereits registriert. Wenn Sie fortfahren, gehen alle Daten Ihres aktuellen Gast-Kontos verloren.\n\nMöchten Sie sich trotzdem mit dem bestehenden Konto anmelden?';
  static const String signedInWithExistingAccount =
      'Sie wurden mit Ihrem bestehenden Konto angemeldet.';
  static const String signInErrorPrefix = 'Fehler bei der Anmeldung: ';
  static const String signInSubtitle =
      'Bitte melden Sie sich an, um fortzufahren.';
  static const String signUpSubtitle =
      'Bitte erstellen Sie ein Konto, um fortzufahren';
  static const String signInAction = 'anmelden';
  static const String signUpAction = 'registrieren';
  static String tosDisclaimer(String action) =>
      'Durch $action stimmen Sie unseren Nutzungsbedingungen zu.';

  // Inventory & Settings
  static const String settings = 'Einstellungen';
  static const String stockValue = 'VORRATSWERT';
}
