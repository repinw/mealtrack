import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealtrack/features/inventory/data/fridge_item.dart';

/// Dies ist eine testbare Version der `_bootstrap`-Funktion aus `main.dart`.
/// Sie akzeptiert einen optionalen `path` für die Hive-Initialisierung,
/// um in einer reinen Dart-Testumgebung ohne `path_provider` zu funktionieren.
/// Der Parameter `forceError` wird verwendet, um einen Fehler zu simulieren.
Future<bool> bootstrapForTest({required String path, bool forceError = false}) async {
  try {
    // Im Test verwenden wir einen manuellen Pfad, in der echten App `initFlutter`.
    // Wenn path null ist, wird initFlutter aufgerufen (simuliert den App-Start).
    // Wenn path nicht null ist, wird init(path) aufgerufen (für den Test).
    Hive.init(path);

    // Wir registrieren den Adapter nur, wenn er nicht bereits registriert ist.
    if (!Hive.isAdapterRegistered(FridgeItemAdapter().typeId)) {
      Hive.registerAdapter(FridgeItemAdapter());
    }

    // Simuliert einen Fehler für den Fehlerfall-Test.
    if (forceError) {
      throw Exception('Simulierter Initialisierungsfehler');
    }

    await Hive.openBox<FridgeItem>('inventory');
    return true;
  } catch (e, stackTrace) {
    debugPrint('Fehler bei der Initialisierung im Test: $e');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}

void main() {
  // Für jeden Test wird ein temporäres Verzeichnis für die Hive-Box erstellt.
  late Directory tempDir;

  setUp(() async {
    // Erstellt ein einzigartiges temporäres Verzeichnis für den Test.
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
        final result = await bootstrapForTest(path: tempDir.path);

        // Assert: Überprüfe, ob das Ergebnis true ist.
        expect(result, isTrue);
        // Überprüfe, ob die Box tatsächlich geöffnet wurde.
        expect(Hive.isBoxOpen('inventory'), isTrue);
      },
    );

    test(
      'sollte false zurückgeben, wenn ein Fehler bei der Initialisierung auftritt',
      () async {
        // Act: Führe die Bootstrap-Funktion aus und zwinge sie, einen Fehler auszulösen.
        final result = await bootstrapForTest(
          path: tempDir.path,
          forceError: true,
        );

        // Assert: Überprüfe, ob das Ergebnis aufgrund des Fehlers false ist.
        expect(result, isFalse);
      },
    );
  });
}
