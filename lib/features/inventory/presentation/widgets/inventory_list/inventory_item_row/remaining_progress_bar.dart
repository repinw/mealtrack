import 'package:flutter/material.dart';

class RemainingProgressBar extends StatelessWidget {
  const RemainingProgressBar({
    super.key,
    required this.ratio,
    required this.stockLabel,
    required this.segmentedByUnits,
    required this.totalUnits,
    required this.remainingUnits,
  });

  final double ratio;
  final String stockLabel;
  final bool segmentedByUnits;
  final int totalUnits;
  final int remainingUnits;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trackColor = colorScheme.surfaceContainerHighest;
    final consumedRatio = (1 - ratio).clamp(0.0, 1.0);
    final fillColor =
        Color.lerp(colorScheme.primary, colorScheme.error, consumedRatio) ??
        colorScheme.primary;

    final percentage = (ratio.clamp(0.0, 1.0) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: segmentedByUnits
                  ? _buildSegmentedBar(trackColor, fillColor)
                  : _buildSingleBar(trackColor, fillColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              stockLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleBar(Color trackColor, Color fillColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: ratio,
        minHeight: 10,
        backgroundColor: trackColor,
        valueColor: AlwaysStoppedAnimation<Color>(fillColor),
      ),
    );
  }

  Widget _buildSegmentedBar(Color trackColor, Color fillColor) {
    final safeTotal = totalUnits < 1 ? 1 : totalUnits;
    final effectiveRatio = ratio.clamp(0.0, 1.0);
    final exactFilledByRatio = effectiveRatio * safeTotal;
    final exactFilledByUnits = remainingUnits.clamp(0, safeTotal).toDouble();
    final exactFilled = exactFilledByRatio < exactFilledByUnits
        ? exactFilledByRatio
        : exactFilledByUnits;

    return Row(
      children: List.generate(safeTotal, (index) {
        final fillValue = _segmentFillValue(index, exactFilled);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == safeTotal - 1 ? 0 : 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fillValue,
                minHeight: 10,
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation<Color>(fillColor),
              ),
            ),
          ),
        );
      }),
    );
  }

  double _segmentFillValue(int segmentIndex, double exactFilled) {
    if (segmentIndex + 1 <= exactFilled) return 1.0;
    if (segmentIndex >= exactFilled) return 0.0;
    return (exactFilled - segmentIndex).clamp(0.0, 1.0);
  }
}
