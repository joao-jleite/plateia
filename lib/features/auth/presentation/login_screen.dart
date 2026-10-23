import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import 'auth_form_helpers.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
    // O redirect do router leva para o onboarding/Início ao detectar a sessão.
  }

  @override
  Widget build(BuildContext context) {
    listenAuthErrors(context, ref);
    final busy = ref.watch(authControllerProvider).isLoading;
    final fixtureLogin = ref.watch(fixtureLoginProvider);
    final theme = Theme.of(context);

    return AuthScaffold(
      title: 'Entrar',
      showBack: false,
      children: [
        Text('Plateia', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'O que você assiste, onde está no Brasil e o que seus amigos acham.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 28),
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: validatePassword,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: busy ? null : _submit,
          child: busy
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Entrar'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: busy ? null : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: const Text('Entrar com Google'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: busy ? null : () => context.push(Routes.reset),
          child: const Text('Esqueci a senha'),
        ),
        TextButton(
          onPressed: busy ? null : () => context.push(Routes.signup),
          child: const Text('Criar conta'),
        ),
        // Só com BACKEND=fixtures: entrar como um dos perfis de amostra para
        // demonstrar as duas pontas da rede social (fase 06).
        if (fixtureLogin != null) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text('Entrar como (dados de amostra)', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final u in fixtureLogin.users)
                ActionChip(
                  key: Key('fixture-login-${u.username}'),
                  avatar: Icon(u.isPrivate ? Icons.lock_outline : Icons.person_outline, size: 16),
                  label: Text('@${u.username}'),
                  onPressed: busy ? null : () => fixtureLogin.signIn(u),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
