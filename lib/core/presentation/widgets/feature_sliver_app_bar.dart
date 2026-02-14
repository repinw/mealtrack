import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mealtrack/core/theme/feature_sliver_app_bar_defaults.dart';

typedef FeatureSliverAppBarActionsBuilder =
    List<Widget> Function(BuildContext context, FeatureSliverAppBarState state);

typedef FeatureSliverAppBarLeadingBuilder =
    Widget? Function(BuildContext context, FeatureSliverAppBarState state);

typedef FeatureSliverAppBarTitleBuilder =
    Widget? Function(BuildContext context, FeatureSliverAppBarState state);

typedef FeatureSliverAppBarFlexibleSpaceBuilder =
    Widget Function(BuildContext context, FeatureSliverAppBarState state);

typedef FeatureSliverAppBarBackgroundBuilder =
    Widget Function(BuildContext context, FeatureSliverAppBarState state);

@immutable
class FeatureSliverAppBarState {
  const FeatureSliverAppBarState({
    required this.scrollOffset,
    required this.collapseProgress,
    required this.topPadding,
    required this.minHeight,
    required this.maxHeight,
  });

  final double scrollOffset;
  final double collapseProgress;
  final double topPadding;
  final double minHeight;
  final double maxHeight;
}

class FeatureSliverAppBar extends StatelessWidget {
  const FeatureSliverAppBar({
    super.key,
    required this.expandedHeight,
    required this.flexibleSpaceBuilder,
    this.collapsedHeight,
    this.toolbarHeight = kToolbarHeight,
    this.actionsBuilder,
    this.leadingBuilder,
    this.titleBuilder,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.elevation = 0,
    this.automaticallyImplyLeading = false,
    this.centerTitle = false,
    this.backgroundColor,
    this.backgroundBuilder,
    this.backgroundAlignment = FeatureSliverAppBarDefaults.backgroundAlignment,
    this.backgroundRotationRadians =
        FeatureSliverAppBarDefaults.backgroundRotationRadians,
    this.backgroundMaxOpacity =
        FeatureSliverAppBarDefaults.backgroundMaxOpacity,
    this.backgroundFadeCurve = FeatureSliverAppBarDefaults.backgroundFadeCurve,
    this.title,
    this.leading,
    this.bottom,
  });

  final double expandedHeight;
  final double? collapsedHeight;
  final double toolbarHeight;
  final FeatureSliverAppBarActionsBuilder? actionsBuilder;
  final FeatureSliverAppBarLeadingBuilder? leadingBuilder;
  final FeatureSliverAppBarTitleBuilder? titleBuilder;
  final FeatureSliverAppBarFlexibleSpaceBuilder flexibleSpaceBuilder;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double elevation;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final FeatureSliverAppBarBackgroundBuilder? backgroundBuilder;
  final AlignmentGeometry backgroundAlignment;
  final double backgroundRotationRadians;
  final double backgroundMaxOpacity;
  final Curve backgroundFadeCurve;
  final Widget? title;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final useDefaultGradient = backgroundColor == null;
    final resolvedBackgroundColor = backgroundColor ?? Colors.transparent;
    final topPadding = MediaQuery.paddingOf(context).top;
    final resolvedCollapsedHeight =
        collapsedHeight ??
        (toolbarHeight + (bottom?.preferredSize.height ?? 0));
    final minHeight = resolvedCollapsedHeight + topPadding;
    final maxHeight = expandedHeight + topPadding;
    final collapseRange = (maxHeight - minHeight).clamp(1.0, double.infinity);

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final collapseProgress = (constraints.scrollOffset / collapseRange)
            .clamp(0.0, 1.0);
        final state = FeatureSliverAppBarState(
          scrollOffset: constraints.scrollOffset,
          collapseProgress: collapseProgress,
          topPadding: topPadding,
          minHeight: minHeight,
          maxHeight: maxHeight,
        );
        final resolvedLeading = leadingBuilder?.call(context, state) ?? leading;
        final resolvedTitle = titleBuilder?.call(context, state) ?? title;
        final bottomRadius = lerpDouble(24, 0, collapseProgress) ?? 0;

        return SliverAppBar(
          pinned: pinned,
          floating: floating,
          snap: snap,
          expandedHeight: expandedHeight,
          collapsedHeight: collapsedHeight,
          toolbarHeight: toolbarHeight,
          elevation: elevation,
          automaticallyImplyLeading: automaticallyImplyLeading,
          centerTitle: centerTitle,
          backgroundColor: resolvedBackgroundColor,
          surfaceTintColor: Colors.transparent,
          title: resolvedTitle,
          leading: resolvedLeading,
          actions: actionsBuilder?.call(context, state),
          bottom: bottom,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(bottomRadius),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          flexibleSpace: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: useDefaultGradient
                      ? _defaultBackgroundGradient(context)
                      : null,
                  color: useDefaultGradient ? null : resolvedBackgroundColor,
                ),
              ),
              if (backgroundBuilder != null)
                _buildBackgroundLayer(context, state),
              flexibleSpaceBuilder(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundLayer(
    BuildContext context,
    FeatureSliverAppBarState state,
  ) {
    final fadeProgress =
        1 - backgroundFadeCurve.transform(state.collapseProgress);
    final opacity = (fadeProgress.clamp(0.0, 1.0) * backgroundMaxOpacity).clamp(
      0.0,
      1.0,
    );

    if (opacity <= 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Align(
        alignment: backgroundAlignment,
        child: Transform.rotate(
          angle: backgroundRotationRadians,
          child: ExcludeSemantics(
            child: Opacity(
              opacity: opacity,
              child: backgroundBuilder!(context, state),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _defaultBackgroundGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primaryContainer,
        colorScheme.secondaryContainer.withValues(
          alpha: FeatureSliverAppBarDefaults.gradientSecondaryAlpha,
        ),
      ],
    );
  }
}
