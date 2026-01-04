import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mealtrack/core/l10n/app_localizations.dart';
import 'package:mealtrack/features/settings/presentation/widgets/account_section_header.dart';

void main() {
  group('AccountSectionHeader', () {
    testWidgets('renders account heading text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AccountSectionHeader())),
      );

      // Assert
      expect(find.text(AppLocalizations.account), findsOneWidget);
    });

    testWidgets('renders account description text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AccountSectionHeader())),
      );

      // Assert
      expect(find.text(AppLocalizations.accountDescription), findsOneWidget);
    });

    testWidgets('renders as Column with proper alignment', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AccountSectionHeader())),
      );

      // Assert
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });
  });
}
