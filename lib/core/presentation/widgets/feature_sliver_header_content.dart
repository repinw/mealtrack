import 'package:flutter/material.dart';

typedef FeatureSliverHeaderTitleBuilder =
    Widget Function(BuildContext context, FeatureSliverHeaderTitleState state);

typedef FeatureSliverHeaderBodyBuilder =
    Widget Function(BuildContext context, FeatureSliverHeaderState state);

@immutable
class FeatureSliverHeaderTitleState {
  const FeatureSliverHeaderTitleState({
    required this.collapseProgress,
    required this.titleOpacity,
  });

  final double collapseProgress;
  final double titleOpacity;
}

@immutable
class FeatureSliverHeaderState {
  const FeatureSliverHeaderState({
    required this.collapseProgress,
    required this.titleOpacity,
    required this.expandedContentOpacity,
    required this.collapsedContentOpacity,
    required this.hasRoomForExpandedSummary,
    required this.useCompactSummary,
    required this.hideMetaLine,
    required this.expandedBottomPadding,
    required this.collapsedBottomPadding,
  });

  final double collapseProgress;
  final double titleOpacity;
  final double expandedContentOpacity;
  final double collapsedContentOpacity;
  final bool hasRoomForExpandedSummary;
  final bool useCompactSummary;
  final bool hideMetaLine;
  final double expandedBottomPadding;
  final double collapsedBottomPadding;
}

class FeatureSliverHeaderContent extends StatelessWidget {
  const FeatureSliverHeaderContent({
    super.key,
    required this.collapseProgress,
    required this.titleBuilder,
    required this.bodyBuilder,
    this.minimumSummaryHeight = 64.0,
    this.expandedTitleFadeFactor = 1.55,
    this.expandedSummaryFadeFactor = 1.45,
    this.collapsedStatsStart = 0.18,
    this.collapsedStatsSpan = 0.82,
  });

  final double collapseProgress;
  final FeatureSliverHeaderTitleBuilder titleBuilder;
  final FeatureSliverHeaderBodyBuilder bodyBuilder;
  final double minimumSummaryHeight;
  final double expandedTitleFadeFactor;
  final double expandedSummaryFadeFactor;
  final double collapsedStatsStart;
  final double collapsedStatsSpan;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = collapseProgress.clamp(0.0, 1.0).toDouble();
    final titleOpacity = (1 - (normalizedProgress * expandedTitleFadeFactor))
        .clamp(0.0, 1.0);
    final expandedContentOpacity =
        (1 - (normalizedProgress * expandedSummaryFadeFactor)).clamp(0.0, 1.0);
    final collapsedContentOpacity =
        ((normalizedProgress - collapsedStatsStart) / collapsedStatsSpan).clamp(
          0.0,
          1.0,
        );

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: titleOpacity,
              child: SizedBox(
                height: kToolbarHeight,
                child: titleBuilder(
                  context,
                  FeatureSliverHeaderTitleState(
                    collapseProgress: normalizedProgress,
                    titleOpacity: titleOpacity,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hasRoomForExpandedSummary =
                    constraints.maxHeight >= minimumSummaryHeight;
                final useCompactSummary = constraints.maxHeight < 104;
                final hideMetaLine = constraints.maxHeight < 84;
                final expandedBottomPadding = (constraints.maxHeight * 0.06)
                    .clamp(0.0, 6.0)
                    .toDouble();
                final collapsedBottomPadding =
                    2 + (collapsedContentOpacity * 3);
                final state = FeatureSliverHeaderState(
                  collapseProgress: normalizedProgress,
                  titleOpacity: titleOpacity,
                  expandedContentOpacity: expandedContentOpacity,
                  collapsedContentOpacity: collapsedContentOpacity,
                  hasRoomForExpandedSummary: hasRoomForExpandedSummary,
                  useCompactSummary: useCompactSummary,
                  hideMetaLine: hideMetaLine,
                  expandedBottomPadding: expandedBottomPadding,
                  collapsedBottomPadding: collapsedBottomPadding,
                );
                return IgnorePointer(child: bodyBuilder(context, state));
              },
            ),
          ),
        ],
      ),
    );
  }
}
