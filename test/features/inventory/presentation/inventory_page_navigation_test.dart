import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/domain/inventory_display_item.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';
import 'package:mealtrack/features/sharing/presentation/sharing_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

class MockFridgeItemsNotifier extends FridgeItems {
  @override
  Stream<List<FridgeItem>> build() => Stream.value(const []);
}

Widget _buildTestWidget(NavigatorObserver observer) {
  return ProviderScope(
    overrides: [
      inventoryDisplayListProvider.overrideWith(
        (ref) => const AsyncValue.data(<InventoryDisplayItem>[]),
      ),
      fridgeItemsProvider.overrideWith(() => MockFridgeItemsNotifier()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      navigatorObservers: [observer],
      home: InventoryPage(
        title: 'Test Inventory',
        sharingPageBuilder: (context) => const SharingPage(),
        settingsPageBuilder: (context) => const SettingsPage(),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  testWidgets('tapping sharing icon pushes SharingPage', (tester) async {
    final observer = MockNavigatorObserver();

    await tester.pumpWidget(_buildTestWidget(observer));
    await tester.pumpAndSettle();
    clearInteractions(observer);

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();

    verify(() => observer.didPush(any(), any())).called(1);
    expect(find.byType(SharingPage), findsOneWidget);
  });

  testWidgets('tapping settings icon pushes SettingsPage', (tester) async {
    final observer = MockNavigatorObserver();

    await tester.pumpWidget(_buildTestWidget(observer));
    await tester.pumpAndSettle();
    clearInteractions(observer);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    verify(() => observer.didPush(any(), any())).called(1);
    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
