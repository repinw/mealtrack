import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/features/sharing/provider/sharing_provider.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class JoinSection extends ConsumerStatefulWidget {
  const JoinSection({super.key});

  @override
  ConsumerState<JoinSection> createState() => _JoinSectionState();
}

class _JoinSectionState extends ConsumerState<JoinSection> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sharingState = ref.watch(sharingViewModelProvider);

    ref.listen(sharingViewModelProvider, (previous, next) {
      if (next.value == 'JOINED') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.joinHousehold)));
        _codeController.clear();
      }
      if (next.hasError) {
        final error = next.error.toString();
        final message = error.contains('Code Expired')
            ? l10n.codeExpired
            : error.contains('Cannot Join Own Household')
            ? l10n.cannotJoinOwnHousehold
            : l10n.invalidCode;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.joinHousehold,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: l10n.enterSharingCode,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  counterText: "",
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _codeController,
              builder: (context, value, _) {
                final isReady = value.text.length == 6;
                return ElevatedButton(
                  onPressed: sharingState.isLoading || !isReady
                      ? null
                      : () => ref
                            .read(sharingViewModelProvider.notifier)
                            .joinHousehold(_codeController.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: sharingState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
