import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealtrack/bootstrap.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  // Für jeden Test wird ein temporäres Verzeichnis für die Hive-Box erstellt.
  late Directory tempDir;

  setUp(() async {
    // Erstellt ein einzigartiges temporäres Verzeichnis für den Test.
    // Dies ist der empfohlene Weg, um die MissingPluginException zu vermeiden.
    TestWidgetsFlutterBinding.ensureInitialized();
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
  });

  tearDown(() async {
    await Hive.close();
    // WICHTIG: Löscht die Hive-Dateien vom Datenträger, um saubere Tests zu gewährleisten.
    await Hive.deleteFromDisk();
    // Löscht das temporäre Verzeichnis und alle Inhalte nach dem Test.
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('_bootstrap', () {
    test(
      'sollte true zurückgeben, wenn die Initialisierung erfolgreich ist',
      () async {
        // Act: Führe die Bootstrap-Funktion mit dem Pfad des temporären Verzeichnisses aus.
        final result = await bootstrap(path: tempDir.path);

        // Assert: Überprüfe, ob das Ergebnis true ist.
        expect(result, isTrue);
        // Überprüfe, ob die Box tatsächlich geöffnet wurde.
        expect(Hive.isBoxOpen('inventory'), isTrue);
      },
    );

    test(
      'sollte false zurückgeben, wenn ein Fehler bei der Initialisierung auftritt',
      () async {
        // Arrange: Erzeuge eine Fehlersituation, indem der Adapter bereits registriert wird.
        // Da die bootstrap-Funktion nicht prüft, ob der Adapter schon existiert,
        // wird der erneute Aufruf von registerAdapter eine Exception auslösen.
        Hive.registerAdapter(FridgeItemAdapter());

        // Act: Führe die Bootstrap-Funktion aus, die nun fehlschlagen wird.
        final result = await bootstrap(path: tempDir.path);
        // Assert: Überprüfe, ob das Ergebnis aufgrund des Fehlers false ist.
        expect(result, isFalse);
      },
    );
  });
}
