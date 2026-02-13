import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/inventory/presentation/widgets/filter.dart';
import 'package:mealtrack/features/inventory/provider/inventory_providers.dart';
import 'package:mealtrack/features/settings/presentation/settings_page.dart';
import 'package:mealtrack/features/sharing/presentation/sharing_page.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InventoryAppBarActions extends ConsumerWidget {
  const InventoryAppBarActions({super.key, required this.collapseProgress});

  static const double _hideShareSettingsStart = 0.60;
  static const double _hideShareSettingsEnd = 0.85;
  final double collapseProgress;

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

  static double trailingActionsSpace(double collapseProgress) {
    final fixedSlots = 1 + (kDebugMode ? 1 : 0);
    final optionalSlots = 2 * shareSettingsVisibility(collapseProgress);
    return ((fixedSlots + optionalSlots) * kToolbarHeight) + 8;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final visibility = shareSettingsVisibility(collapseProgress);

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
        const FilterWidget(),
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
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SharingPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people_outline),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        tooltip: l10n.settings,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
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
