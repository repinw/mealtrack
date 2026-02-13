import 'package:flutter/material.dart';
import 'package:mealtrack/core/theme/calories_theme.dart';

class MealSectionCard extends StatefulWidget {
  final String title;
  final Widget? content;
  final String? emptyLabel;
  final bool initiallyExpanded;

  const MealSectionCard({
    super.key,
    required this.title,
    this.content,
    this.emptyLabel,
    this.initiallyExpanded = false,
  });

  @override
  State<MealSectionCard> createState() => _MealSectionCardState();
}

class _MealSectionCardState extends State<MealSectionCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.content == null ? true : widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant MealSectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hadContent = oldWidget.content != null;
    final hasContent = widget.content != null;
    if (hadContent && !hasContent) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caloriesTheme = CaloriesTheme.of(context);
    final hasDetails = widget.content != null;
    final titleStyle = (theme.textTheme.titleMedium ?? const TextStyle()).merge(
      caloriesTheme.sectionTitleTextStyle,
    );
    final emptyStyle = (theme.textTheme.bodyMedium ?? const TextStyle())
        .copyWith(color: caloriesTheme.subduedTextColor);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: caloriesTheme.cardRadius),
      child: Padding(
        padding: caloriesTheme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: hasDetails
                  ? () => setState(() => _expanded = !_expanded)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text(widget.title, style: titleStyle)),
                    if (hasDetails)
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: caloriesTheme.inlineSpacing),
            if (hasDetails)
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  heightFactor: _expanded ? 1 : 0,
                  child: widget.content!,
                ),
              )
            else
              Text(widget.emptyLabel ?? 'No entries yet', style: emptyStyle),
          ],
        ),
      ),
    );
  }
}
