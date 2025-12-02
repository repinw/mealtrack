import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealtrack/core/config/bootstrap.dart';
import 'package:mealtrack/core/data/hive_initializer.dart';
import 'package:mocktail/mocktail.dart';

/// Eine Test-Implementierung des [HiveInitializer], die ein temporäres
/// Verzeichnis verwendet und die test-sichere `Hive.init()`-Methode aufruft.
class TestHiveInitializer implements HiveInitializer {
  TestHiveInitializer(this.path);
  final String path;

  @override
  Future<void> init() async => Hive.init(path);
}

class MockHiveInitializer extends Mock implements HiveInitializer {}

void main() {
  // Für jeden Test wird ein temporäres Verzeichnis für die Hive-Box erstellt.
  late Directory tempDir;

  setUp(() async {
    // Erstellt ein einzigartiges temporäres Verzeichnis für den Test.
    // Dies ist der empfohlene Weg, um die MissingPluginException zu vermeiden.
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
  });

  tearDown(() async {
    await Hive.close();
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
        final result = await bootstrap(TestHiveInitializer(tempDir.path));

        // Assert: Überprüfe, ob das Ergebnis true ist.
        expect(result, isTrue);
        // Überprüfe, ob die Box tatsächlich geöffnet wurde.
        expect(Hive.isBoxOpen('inventory'), isTrue);
      },
    );
    test(
      'sollte false zurückgeben, wenn hiveInitializer.init eine Exception wirft',
      () async {
        // Arrange: Erstelle einen Mock, der einen Fehler wirft.
        final mockInitializer = MockHiveInitializer();
        when(
          () => mockInitializer.init(),
        ).thenThrow(Exception('Festplatte voll'));

        // Act: Führe die Bootstrap-Funktion aus.
        final result = await bootstrap(mockInitializer);

        // Assert: Überprüfe, ob das Ergebnis false ist.
        expect(result, isFalse);
      },
    );
  });
}
