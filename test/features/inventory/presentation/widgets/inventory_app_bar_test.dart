import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/provider/local_storage_service.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_app_bar.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockFridgeItemsNotifier extends FridgeItems {
  final List<FridgeItem> mockItems;

  MockFridgeItemsNotifier([this.mockItems = const []]);

  @override
  Future<List<FridgeItem>> build() async => mockItems;

  @override
  Future<void> deleteAll() async {}

  @override
  Future<void> addItems(List<FridgeItem> items) async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> updateItem(FridgeItem item) async {}

  @override
  Future<void> updateQuantity(FridgeItem item, int delta) async {}

  @override
  Future<void> deleteItem(String id) async {}
}

void main() {
  late MockLocalStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockLocalStorageService();
  });

  Widget buildTestWidget({List<FridgeItem>? items}) {
    return ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(mockStorageService),
        fridgeItemsProvider.overrideWith(
          () => MockFridgeItemsNotifier(items ?? []),
        ),
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
    testWidgets('displays the title in uppercase', (tester) async {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('TEST TITLE'), findsOneWidget);
    });

    testWidgets('displays VORRATSWERT label', (tester) async {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('VORRATSWERT'), findsOneWidget);
    });

    testWidgets('displays inventory value when items exist', (tester) async {
      final items = [
        FridgeItem.create(
          name: 'Test Item',
          storeName: 'Store',
          quantity: 2,
          unitPrice: 5.0,
        ),
      ];
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => items);

      await tester.pumpWidget(buildTestWidget(items: items));
      await tester.pumpAndSettle();

      expect(find.textContaining('10,00'), findsOneWidget);
    });

    testWidgets('displays debug delete button in debug mode', (tester) async {
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

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

      await tester.pumpWidget(buildTestWidget(items: [item]));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('displays purchases and items count', (tester) async {
      final items = [
        FridgeItem.create(
          name: 'Item 1',
          storeName: 'Store',
          quantity: 3,
          unitPrice: 1.0,
        ).copyWith(receiptId: 'receipt-1'),
        FridgeItem.create(
          name: 'Item 2',
          storeName: 'Store',
          quantity: 2,
          unitPrice: 1.0,
        ).copyWith(receiptId: 'receipt-1'),
      ];
      when(() => mockStorageService.loadItems()).thenAnswer((_) async => items);

      await tester.pumpWidget(buildTestWidget(items: items));
      await tester.pumpAndSettle();

      expect(find.textContaining('1'), findsWidgets);
      expect(find.textContaining('5'), findsWidgets);
    });
  });
}
