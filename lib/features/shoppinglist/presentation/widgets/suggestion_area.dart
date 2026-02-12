import 'package:flutter/material.dart';
import 'package:mealtrack/features/shoppinglist/presentation/widgets/suggestion_chip.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class SuggestionArea extends StatefulWidget {
  final void Function(String name) onSuggestionTap;
  final List<String> suggestions;
  final String? title;
  final IconData icon;
  final int maxVisibleSuggestions;

  const SuggestionArea({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.title,
    this.icon = Icons.lightbulb_outline,
    this.maxVisibleSuggestions = 6,
  });

  @override
  State<SuggestionArea> createState() => _SuggestionAreaState();
}

class _SuggestionAreaState extends State<SuggestionArea> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final title = widget.title ?? l10n.suggestions;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(widget.icon, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _buildSuggestions(
                  widget.suggestions
                      .take(widget.maxVisibleSuggestions)
                      .toList(),
                ),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSuggestions(List<String> suggestions) {
    return suggestions.map((s) {
      return SuggestionChip(label: s, onTap: () => widget.onSuggestionTap(s));
    }).toList();
  }
}
