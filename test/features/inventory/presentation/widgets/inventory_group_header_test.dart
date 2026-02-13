import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/features/inventory/data/fridge_repository.dart';

import 'package:mealtrack/features/inventory/presentation/viewmodel/inventory_display_item.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_list/inventory_group_header.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockFridgeRepository extends Mock implements FridgeRepository {}

void main() {
  late MockFridgeRepository mockFridgeRepository;
  late bool archiveReceiptCalled;
  late String? calledReceiptId;

  setUp(() {
    mockFridgeRepository = MockFridgeRepository();
    archiveReceiptCalled = false;
    calledReceiptId = null;
  });

  Widget createWidget({required InventoryHeaderItem header}) {
    return ProviderScope(
      overrides: [
        fridgeItemsProvider.overrideWith(() {
          final mock = _TrackingMockFridgeItems(
            onArchiveReceipt: (receiptId) {
              archiveReceiptCalled = true;
              calledReceiptId = receiptId;
            },
          );
          return mock;
        }),
        fridgeRepositoryProvider.overrideWithValue(mockFridgeRepository),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: InventoryGroupHeader(header: header)),
      ),
    );
  }

  testWidgets('InventoryGroupHeader displays correct information', (
    tester,
  ) async {
    final date = DateTime(2023, 10, 25);
    final header = InventoryHeaderItem(
      storeName: 'SuperStore',
      entryDate: date,
      itemCount: 5,
      receiptId: 'r1',
      isFullyConsumed: false,
    );

    await tester.pumpWidget(createWidget(header: header));

    expect(find.textContaining('25.10.2023'), findsOneWidget);
    expect(find.textContaining('SuperStore'), findsOneWidget);
    expect(find.byType(InventoryGroupHeader), findsOneWidget);
  });

  testWidgets('Archive button visible only when fully consumed', (
    tester,
  ) async {
    final activeHeader = InventoryHeaderItem(
      storeName: 'A',
      entryDate: DateTime.now(),
      itemCount: 1,
      receiptId: '1',
      isFullyConsumed: false,
    );

    await tester.pumpWidget(createWidget(header: activeHeader));
    expect(find.byIcon(Icons.archive_outlined), findsNothing);

    final consumedHeader = InventoryHeaderItem(
      storeName: 'B',
      entryDate: DateTime.now(),
      itemCount: 1,
      receiptId: '2',
      isFullyConsumed: true,
    );

    await tester.pumpWidget(createWidget(header: consumedHeader));
    expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
  });

  testWidgets('Tapping archive button calls archiveReceipt', (tester) async {
    final header = InventoryHeaderItem(
      storeName: 'B',
      entryDate: DateTime.now(),
      itemCount: 1,
      receiptId: 'receipt_123',
      isFullyConsumed: true,
    );

    await tester.pumpWidget(createWidget(header: header));

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pump();

    expect(archiveReceiptCalled, isTrue);
    expect(calledReceiptId, 'receipt_123');
  });
}

class _TrackingMockFridgeItems extends FridgeItems {
  final void Function(String receiptId) onArchiveReceipt;

  _TrackingMockFridgeItems({required this.onArchiveReceipt});

  @override
  Stream<List<FridgeItem>> build() => Stream.value([]);

  @override
  Future<void> archiveReceipt(String receiptId) async {
    onArchiveReceipt(receiptId);
  }
}
