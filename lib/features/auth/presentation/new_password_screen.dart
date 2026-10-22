import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import 'auth_form_helpers.dart';
import 'auth_providers.dart';

/// Aberta pelo app quando chega o evento `passwordRecovery` (a pessoa tocou no
/// link do e-mail). A sessão já existe; só falta gravar a senha nova.
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authControllerProvider.notifier).updatePassword(_password.text);
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha atualizada.')));
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    listenAuthErrors(context, ref);
    final busy = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Nova senha',
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova senha (mínimo 6)'),
                validator: validatePassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Repita a senha'),
                validator: (v) => v != _password.text ? 'As senhas não batem.' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: busy ? null : _submit, child: const Text('Salvar')),
      ],
    );
  }
}
