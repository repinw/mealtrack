import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_app_bar.dart';

import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockLocalStorageService();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(mockStorageService),
      ],
      child: const MaterialApp(
        home: Scaffold(
          appBar: InventoryAppBar(title: 'Test Title'),
          body: SizedBox.shrink(),
        ),
      ),
    );
  }

  group('InventoryAppBar', () {
    testWidgets('displays the title', (tester) async {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays a switch for filtering', (tester) async {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('switch toggles filter state', (tester) async {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Initially the switch should be off (show all items)
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);

      // Tap the switch to toggle
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Now the switch should be on
      final switchWidgetAfter = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidgetAfter.value, true);
    });

    testWidgets('displays debug delete button in debug mode', (tester) async {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // In debug mode, the delete button should be visible
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('debug delete button clears all items and shows snackbar', (
      tester,
    ) async {
      final item = FridgeItem.create(
        name: 'Test Item',
        storeName: 'Store',
        quantity: 1,
        unitPrice: 1.0,
      );
      when(
        () => mockStorageService.loadItems(),
      ).thenAnswer((_) async => [item]);
      when(() => mockStorageService.deleteAllItems()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the delete button
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      // Verify deleteAllItems was called
      verify(() => mockStorageService.deleteAllItems()).called(1);

      // Verify snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
