class AppLocalizations {
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
}
