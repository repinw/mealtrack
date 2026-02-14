import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/presentation/widgets/feature_sliver_app_bar.dart';
import 'package:mealtrack/core/theme/feature_sliver_app_bar_defaults.dart';

void main() {
  const backgroundKey = ValueKey('feature-appbar-bg');

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              FeatureSliverAppBar(
                expandedHeight: 180,
                backgroundBuilder: (context, state) => Container(
                  key: backgroundKey,
                  width: 88,
                  height: 88,
                  color: Colors.black,
                ),
                flexibleSpaceBuilder: (context, state) =>
                    const SizedBox.shrink(),
              ),
            ];
          },
          body: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) =>
                SizedBox(height: 56, child: Text('Row $index')),
          ),
        ),
      ),
    );
  }

  group('FeatureSliverAppBar', () {
    testWidgets(
      'uses centered rotated decorative background with no semantics',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byKey(backgroundKey), findsOneWidget);

        final alignFinder = find.ancestor(
          of: find.byKey(backgroundKey),
          matching: find.byWidgetPredicate(
            (widget) => widget is Align && widget.child is Transform,
          ),
        );
        final alignWidget = tester.widget<Align>(alignFinder.first);
        expect(
          alignWidget.alignment,
          FeatureSliverAppBarDefaults.backgroundAlignment,
        );

        final transformFinder = find.ancestor(
          of: find.byKey(backgroundKey),
          matching: find.byType(Transform),
        );
        final transformWidget = tester.widget<Transform>(transformFinder.first);
        final angle = math.atan2(
          transformWidget.transform[1],
          transformWidget.transform[0],
        );
        expect(
          angle,
          closeTo(FeatureSliverAppBarDefaults.backgroundRotationRadians, 0.001),
        );

        final semanticsFinder = find.ancestor(
          of: find.byKey(backgroundKey),
          matching: find.byType(ExcludeSemantics),
        );
        expect(semanticsFinder, findsOneWidget);
      },
    );

    testWidgets('fades decorative background out when collapsed', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final opacityFinder = find.ancestor(
        of: find.byKey(backgroundKey),
        matching: find.byType(Opacity),
      );
      final opacityAtTop = tester.widget<Opacity>(opacityFinder.first).opacity;
      expect(opacityAtTop, greaterThan(0.1));

      await tester.drag(find.byType(NestedScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.byKey(backgroundKey), findsNothing);
    });
  });
}
