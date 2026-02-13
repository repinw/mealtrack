import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/sharing/provider/sharing_provider.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class InviteSection extends ConsumerWidget {
  const InviteSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sharingState = ref.watch(sharingViewModelProvider);
    final code = sharingState.value != 'JOINED' ? sharingState.value : null;

    ref.listen(sharingViewModelProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorLabel}${next.error}')),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.invite, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (code == null)
          ElevatedButton.icon(
            onPressed: sharingState.isLoading
                ? null
                : () => ref
                      .read(sharingViewModelProvider.notifier)
                      .generateCode(),
            icon: sharingState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.qr_code, size: 18),
            label: Text(l10n.generateCode),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          )
        else
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primaryContainer),
                ),
                child: Column(
                  children: [
                    Text(
                      code,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.codeValidDuration,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.codeCopied)),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(l10n.copyCode),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => ref
                        .read(sharingViewModelProvider.notifier)
                        .generateCode(),
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.retry,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
