import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'my_profile_provider.dart';

/// Etapa "importar a Netflix" do onboarding (SPEC §J1.3). A importação de
/// verdade chega na fase 05; por enquanto só "Agora não", que fecha o
/// onboarding (`onboarded_at`) e deixa o router seguir para o Início.
class ImportPlaceholderScreen extends ConsumerStatefulWidget {
  const ImportPlaceholderScreen({super.key});

  @override
  ConsumerState<ImportPlaceholderScreen> createState() => _ImportPlaceholderScreenState();
}

class _ImportPlaceholderScreenState extends ConsumerState<ImportPlaceholderScreen> {
  bool _busy = false;

  Future<void> _skip() async {
    setState(() => _busy = true);
    try {
      await ref.read(myProfileProvider.notifier).completeOnboarding();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Importar da Netflix')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.upload_file_outlined, size: 56),
              const SizedBox(height: 16),
              Text('Seu perfil pode nascer cheio', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Em breve você vai poder importar o histórico que a Netflix deixa baixar '
                '(Conta → Perfis → Atividade de visualização → Baixar tudo). '
                'O arquivo é lido no seu aparelho e descartado.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton(
                onPressed: _busy ? null : _skip,
                child: _busy
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Agora não'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
