import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InventoryAppBarActions extends ConsumerWidget {
  const InventoryAppBarActions({
    super.key,
    required this.collapseProgress,
    this.onOpenSharing,
    this.onOpenSettings,
  });

  final double collapseProgress;
  final VoidCallback? onOpenSharing;
  final VoidCallback? onOpenSettings;
  static const double _hiddenVisibilityThreshold = 0.35;

  static double shareSettingsVisibility(double collapseProgress) {
    return (1 - (collapseProgress * 1.55)).clamp(0.0, 1.0);
  }

  static double effectiveVisibility(double collapseProgress) {
    final raw = shareSettingsVisibility(collapseProgress);
    if (raw < _hiddenVisibilityThreshold) {
      return 0;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final iconColor = Theme.of(context).colorScheme.onSurface;
    final visibility = effectiveVisibility(collapseProgress);
    final hasSharingAction = onOpenSharing != null;
    final hasSettingsAction = onOpenSettings != null;
    final hasAnyActions = kDebugMode || hasSharingAction || hasSettingsAction;

    if (!hasAnyActions) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: Align(
        alignment: Alignment.centerRight,
        widthFactor: visibility,
        child: IgnorePointer(
          ignoring: visibility <= 0,
          child: Opacity(
            opacity: visibility,
            child: Transform.translate(
              offset: Offset((1 - visibility) * 12, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (kDebugMode)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: iconColor),
                      tooltip: l10n.debugHiveReset,
                      onPressed: () async {
                        await ref
                            .read(fridgeItemsProvider.notifier)
                            .deleteAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.debugDataDeleted)),
                          );
                        }
                      },
                    ),
                  if (hasSharingAction)
                    IconButton(
                      onPressed: onOpenSharing,
                      tooltip: l10n.sharing,
                      icon: Icon(Icons.people_outline, color: iconColor),
                    ),
                  if (hasSettingsAction)
                    IconButton(
                      icon: Icon(Icons.settings, color: iconColor),
                      tooltip: l10n.settings,
                      onPressed: onOpenSettings,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
