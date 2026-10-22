import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/profile.dart';
import '../domain/username.dart';
import 'my_profile_provider.dart';

/// Primeira etapa do onboarding: escolher o `@` (SPEC §J1.2). Depois segue
/// para a etapa "importar", que até a fase 05 só oferece "Agora não".
class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _displayName;
  Timer? _debounce;
  bool? _available; // null = ainda não checado
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController();
    _displayName = TextEditingController();
    // O perfil pode chegar depois do primeiro frame; preenche a sugestão assim
    // que houver dado e enquanto a pessoa ainda não digitou nada.
    ref.listenManual(myProfileProvider, (_, next) => _suggest(next.value), fireImmediately: true);
  }

  void _suggest(Profile? profile) {
    if (_username.text.isNotEmpty) return;
    final user = ref.read(authStateProvider).value;
    if (profile == null && user == null) return;
    final suggestion = (profile != null && !profile.hasProvisionalUsername)
        ? profile.username
        : suggestUsername(profile?.displayName ?? user?.displayName, user?.email);
    if (suggestion.isEmpty) return;
    _username.text = suggestion;
    if (_displayName.text.isEmpty) _displayName.text = profile?.displayName ?? user?.displayName ?? '';
    _check(suggestion);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _username.dispose();
    _displayName.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    _debounce?.cancel();
    setState(() => _available = null);
    if (validateUsername(raw) != null) return;
    _debounce = Timer(const Duration(milliseconds: 400), () => _check(raw));
  }

  Future<void> _check(String raw) async {
    if (validateUsername(raw) != null) return;
    final normalized = normalizeUsername(raw);
    try {
      final ok = await ref.read(profileRepositoryProvider).isUsernameAvailable(normalized);
      if (mounted && normalizeUsername(_username.text) == normalized) setState(() => _available = ok);
    } catch (_) {
      // Sem rede a checagem fica em branco; o salvar ainda valida no servidor.
    }
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref.read(myProfileProvider.notifier).saveUsername(
            normalizeUsername(_username.text),
            displayName: _displayName.text,
          );
      if (mounted) context.go(Routes.onboardingImport);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final helper = switch (_available) {
      true => 'Disponível',
      false => 'Já está em uso',
      null => 'Letras minúsculas, números e _ (3 a 20)',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu @'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sair'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Como as pessoas vão te encontrar', style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _username,
                  autofocus: true,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nome de usuário',
                    prefixText: '@',
                    helperText: helper,
                    helperStyle: TextStyle(
                      color: _available == false ? theme.colorScheme.error : null,
                    ),
                    suffixIcon: switch (_available) {
                      true => Icon(Icons.check_circle, color: theme.colorScheme.primary),
                      false => Icon(Icons.cancel, color: theme.colorScheme.error),
                      null => null,
                    },
                  ),
                  validator: (v) => validateUsername(v ?? '') ?? (_available == false ? 'Esse @ já está em uso.' : null),
                  onChanged: _onChanged,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayName,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 50,
                  decoration: const InputDecoration(labelText: 'Nome de exibição (opcional)'),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
