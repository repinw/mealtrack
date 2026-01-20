import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtrack/core/errors/firebase_error_codes.dart';
import 'package:mealtrack/features/auth/presentation/auth_gate.dart';
import 'package:mealtrack/features/auth/presentation/viewmodel/guest_name_viewmodel.dart';
import 'package:mealtrack/l10n/app_localizations.dart';

class GuestNamePage extends ConsumerStatefulWidget {
  final User? user;

  const GuestNamePage({super.key, this.user});

  @override
  ConsumerState<GuestNamePage> createState() => _GuestNamePageState();
}

class _GuestNamePageState extends ConsumerState<GuestNamePage> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    ref
        .read(guestNameViewModelProvider.notifier)
        .submit(name: name, user: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(guestNameViewModelProvider);

    ref.listen(guestNameViewModelProvider, (_, next) {
      if (!next.isLoading && !next.hasError) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    });

    final errorMessage = _getErrorMessage(state.error, l10n);
    final isLoading = state.isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    l10n.howShouldWeCallYou,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.yourName,
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.enterValidName;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(errorMessage != null ? l10n.retry : l10n.next),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _getErrorMessage(Object? error, AppLocalizations l10n) {
    if (error == null) return null;
    if (error is FirebaseAuthException) {
      if (isNetworkError(error.code)) {
        return l10n.firstLoginRequiresInternet;
      }
      return '${l10n.errorLabel}${error.message}';
    }
    return '${l10n.errorLabel}$error';
  }
}
