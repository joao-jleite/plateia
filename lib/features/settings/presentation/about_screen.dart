import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sobre e atribuições (SPEC §5.7): o TMDB exige o aviso de não endosso e a
/// JustWatch a menção como fonte dos provedores. Os logos dos streamings só
/// indicam onde o título está.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const tmdbNotice =
      'Este produto usa a API do TMDB, mas não é endossado nem certificado pelo TMDB.';
  static const justwatchNotice = 'Onde assistir: dados da JustWatch via TMDB.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Plateia', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Registre o que você assiste em qualquer streaming, veja onde cada título está no Brasil e acompanhe seus amigos. O app não toca vídeo nem entra na sua conta de streaming.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Fontes de dados', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const _Attribution(
            // Marca do TMDB como texto até o João baixar o logo oficial
            // (docs/PENDENCIAS-JOAO.md); o texto obrigatório já está aqui.
            badge: 'TMDB',
            text: tmdbNotice,
            url: 'https://www.themoviedb.org/',
          ),
          const SizedBox(height: 12),
          const _Attribution(
            badge: 'JustWatch',
            text: justwatchNotice,
            url: 'https://www.justwatch.com/br',
          ),
          const SizedBox(height: 24),
          Text(
            'Logos e nomes dos streamings pertencem aos seus donos e aparecem só para indicar onde cada título está disponível.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution({required this.badge, required this.text, required this.url});

  final String badge;
  final String text;
  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badge, style: TextStyle(fontWeight: FontWeight.bold, color: scheme.onSecondaryContainer)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
