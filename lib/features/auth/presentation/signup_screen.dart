import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth_user.dart';
import 'auth_form_helpers.dart';
import 'auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final outcome = await ref.read(authControllerProvider.notifier).signUp(
          email: _email.text,
          password: _password.text,
          displayName: _name.text,
        );
    if (!mounted) return;
    if (outcome == SignUpOutcome.needsEmailConfirmation) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    listenAuthErrors(context, ref);
    final busy = ref.watch(authControllerProvider).isLoading;

    if (_sent) {
      return AuthScaffold(
        title: 'Confirme seu e-mail',
        children: [
          const Icon(Icons.mark_email_read_outlined, size: 56),
          const SizedBox(height: 16),
          Text(
            'Enviamos um link para ${_email.text.trim()}. Abra o e-mail e toque no link para ativar a conta.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: () => context.pop(), child: const Text('Voltar para entrar')),
        ],
      );
    }

    return AuthScaffold(
      title: 'Criar conta',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Nome (opcional)'),
                maxLength: 50,
              ),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(labelText: 'Senha (mínimo 6)'),
                validator: validatePassword,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: busy ? null : _submit, child: const Text('Criar conta')),
      ],
    );
  }
}
