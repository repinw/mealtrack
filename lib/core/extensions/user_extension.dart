import 'package:firebase_auth/firebase_auth.dart';

extension UserExtension on User {
  Future<void> updateDisplayNameAndReload(String name) async {
    await updateDisplayName(name);
    await reload();
  }

  Future<void> updateDisplayNameFromProvider() async {
    if (displayName != null && displayName!.isNotEmpty) return;

    for (final provider in providerData) {
      final name = provider.displayName;
      if (name != null && name.isNotEmpty) {
        await updateDisplayNameAndReload(name);
        return;
      }
    }
  }
}
