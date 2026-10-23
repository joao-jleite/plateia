import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/legal.dart';

/// "Ao continuar, você concorda com os Termos de uso e a Política de
/// privacidade", com os dois como links que abrem no navegador.
class LegalNotice extends StatefulWidget {
  const LegalNotice({super.key, this.prefix = 'Ao continuar, você concorda com os ', this.textAlign = TextAlign.center});

  final String prefix;
  final TextAlign textAlign;

  @override
  State<LegalNotice> createState() => _LegalNoticeState();
}

class _LegalNoticeState extends State<LegalNotice> {
  // Recognizers precisam de dispose; por isso o widget é stateful.
  late final _terms = TapGestureRecognizer()..onTap = () => openLegal(Legal.termsUrl);
  late final _privacy = TapGestureRecognizer()..onTap = () => openLegal(Legal.privacyUrl);

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final link = base?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: widget.prefix),
          TextSpan(text: 'Termos de uso', style: link, recognizer: _terms, semanticsLabel: 'Termos de uso, link'),
          const TextSpan(text: ' e a '),
          TextSpan(text: 'Política de privacidade', style: link, recognizer: _privacy, semanticsLabel: 'Política de privacidade, link'),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}

/// Caixa "Li e aceito…" do onboarding (exigência da política de conteúdo
/// gerado por usuário da Play: termos aceitos no cadastro).
class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({super.key, required this.value, required this.onChanged, this.error});

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Mensagem em vermelho sob a caixa (tentou continuar sem marcar).
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          key: const Key('terms-checkbox'),
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: const LegalNotice(prefix: 'Li e aceito os ', textAlign: TextAlign.start),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2),
            child: Text(error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          ),
      ],
    );
  }
}

Future<void> openLegal(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
