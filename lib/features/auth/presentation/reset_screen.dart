import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_form_helpers.dart';
import 'auth_providers.dart';

/// Pede o e-mail e manda o link de redefinição. O link abre o app pelo deep
/// link `login-callback`; o evento `passwordRecovery` leva à tela de nova senha.
class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key});

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final ok = await ref.read(authControllerProvider.notifier).sendPasswordReset(_email.text);
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    listenAuthErrors(context, ref);
    final busy = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Recuperar senha',
      children: _sent
          ? [
              const Icon(Icons.mark_email_read_outlined, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Se existir uma conta com esse e-mail, enviamos um link para criar uma senha nova.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(onPressed: () => context.pop(), child: const Text('Voltar')),
            ]
          : [
              Form(
                key: _form,
                child: TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail da conta'),
                  validator: validateEmail,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: busy ? null : _submit, child: const Text('Enviar link')),
            ],
    );
  }
}
