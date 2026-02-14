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

  static const double _hideShareSettingsStart = 0.60;
  static const double _hideShareSettingsEnd = 0.85;
  final double collapseProgress;
  final VoidCallback? onOpenSharing;
  final VoidCallback? onOpenSettings;

  static double shareSettingsVisibility(double collapseProgress) {
    if (collapseProgress <= _hideShareSettingsStart) {
      return 1.0;
    }

    if (collapseProgress >= _hideShareSettingsEnd) {
      return 0.0;
    }

    return (_hideShareSettingsEnd - collapseProgress) /
        (_hideShareSettingsEnd - _hideShareSettingsStart);
  }

  static double trailingActionsSpace(
    double collapseProgress, {
    required bool hasSharingAction,
    required bool hasSettingsAction,
  }) {
    final fixedSlots = 1 + (kDebugMode ? 1 : 0);
    final optionalActionCount =
        (hasSharingAction ? 1 : 0) + (hasSettingsAction ? 1 : 0);
    final optionalSlots =
        optionalActionCount * shareSettingsVisibility(collapseProgress);
    return ((fixedSlots + optionalSlots) * kToolbarHeight) + 8;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final visibility = shareSettingsVisibility(collapseProgress);
    final hasSharingAction = onOpenSharing != null;
    final hasSettingsAction = onOpenSettings != null;
    final hasOptionalActions = hasSharingAction || hasSettingsAction;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: l10n.debugHiveReset,
            onPressed: () async {
              await ref.read(fridgeItemsProvider.notifier).deleteAll();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.debugDataDeleted)));
              }
            },
          ),
        if (hasOptionalActions)
          ClipRect(
            child: Align(
              alignment: Alignment.centerRight,
              widthFactor: visibility,
              child: IgnorePointer(
                ignoring: visibility < 0.2,
                child: Opacity(
                  opacity: visibility,
                  child: Transform.translate(
                    offset: Offset((1 - visibility) * 12, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasSharingAction)
                          IconButton(
                            onPressed: onOpenSharing,
                            icon: const Icon(Icons.people_outline),
                          ),
                        if (hasSettingsAction)
                          IconButton(
                            icon: const Icon(Icons.settings),
                            tooltip: l10n.settings,
                            onPressed: onOpenSettings,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
