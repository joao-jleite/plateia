import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/legal_links.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/profile.dart';
import '../domain/username.dart';
import 'my_profile_provider.dart';
import 'onboarding_header.dart';

/// Primeira etapa do onboarding (SPEC §J1.2): o que é o app, escolher o `@`
/// e aceitar os termos (fase 08). Depois segue para "importar a Netflix".
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
  bool _terms = false;
  bool _termsError = false;

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

  bool get _alreadyAccepted => ref.read(myProfileProvider).value?.hasAcceptedTerms ?? false;

  Future<void> _submit() async {
    final formOk = _form.currentState?.validate() ?? false;
    final termsOk = _terms || _alreadyAccepted;
    setState(() => _termsError = !termsOk);
    if (!formOk || !termsOk) return;
    setState(() => _saving = true);
    try {
      await ref.read(myProfileProvider.notifier).saveUsername(
            normalizeUsername(_username.text),
            displayName: _displayName.text,
            acceptTerms: _terms,
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
        title: const Text('Bem-vindo'),
        automaticallyImplyLeading: false,
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
                const OnboardingHeader(
                  step: 1,
                  icon: Icons.theaters_outlined,
                  title: 'Seu diário de filmes, séries e anime',
                  subtitle: 'Registre o que assiste em qualquer streaming, veja onde cada título está no Brasil e '
                      'acompanhe seus amigos. Comece escolhendo como as pessoas vão te encontrar.',
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 8),
                // Aceite dos termos (Play: política de conteúdo gerado por usuário).
                // Quem já aceitou (voltou ao passo 1 para trocar o @) não vê a caixa.
                if (!_alreadyAccepted)
                  TermsCheckbox(
                    value: _terms,
                    onChanged: (v) => setState(() {
                      _terms = v;
                      if (v) _termsError = false;
                    }),
                    error: _termsError ? 'Para continuar, aceite os termos e a política.' : null,
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
