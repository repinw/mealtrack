import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/l10n/l10n.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:mealtrack/core/theme/app_theme.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/inventory_bottom_bar.dart';
import 'package:mealtrack/features/scanner/presentation/viewmodel/scanner_viewmodel.dart';

class MockScannerViewModelNotLoading extends ScannerViewModel {
  @override
  Future<List<FridgeItem>> build() async => [];
}

void main() {
  group('InventoryBottomBar', () {
    testWidgets('renders add receipt button when not loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModelNotLoading(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.theme,
            home: const Scaffold(body: InventoryBottomBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(L10n.addReceipt), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('button is enabled when not loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModelNotLoading(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.theme,
            home: const Scaffold(body: InventoryBottomBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('has correct icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModelNotLoading(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.theme,
            home: const Scaffold(body: InventoryBottomBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.center_focus_weak), findsOneWidget);
    });

    testWidgets('has correct styling', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scannerViewModelProvider.overrideWith(
              () => MockScannerViewModelNotLoading(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.theme,
            home: const Scaffold(body: InventoryBottomBar()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
