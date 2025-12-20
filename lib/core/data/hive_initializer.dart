import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Eine abstrakte Klasse, die die Schnittstelle für die Hive-Initialisierung definiert.
abstract class HiveInitializer {
  Future<void> init();
}

/// Die konkrete Implementierung für die Flutter-Anwendung.
/// Verwendet `path_provider` und `Hive.initFlutter`.
class AppHiveInitializer implements HiveInitializer {
  @override
  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }
}
