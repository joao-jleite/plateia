import 'package:flutter/material.dart';

import '../config/tmdb_images.dart';
import 'poster_image.dart';

/// Cartão de pôster usado nas grades e carrosséis (Início, Busca).
class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.title,
    required this.posterPath,
    this.year,
    this.typeLabel,
    this.width = defaultWidth,
    this.onTap,
  });

  static const double defaultWidth = 120;

  /// Altura de uma fileira de pôsteres com [width] dado: imagem 2:3 + duas
  /// linhas de título + uma de subtítulo, na escala de fonte do sistema
  /// (até 1,3×, limite do app). Evita o estouro de alguns pixels com fonte grande.
  static double heightFor(BuildContext context, {double width = defaultWidth}) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return width * 1.5 + 6 + (2 * 20 + 16) * scale + 4;
  }

  final String title;
  final String? posterPath;
  final int? year;
  final String? typeLabel;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [?year?.toString(), ?typeLabel].join(' · ');
    // Um rótulo só para o leitor de tela ("Duna: Parte Dois, 2024 · Filme"),
    // em vez de imagem sem nome + duas linhas soltas.
    return Semantics(
      button: onTap != null,
      label: subtitle.isEmpty ? title : '$title, $subtitle',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PosterImage(
                  url: TmdbImages.poster(posterPath),
                  width: width,
                  height: width * 1.5,
                  borderRadius: 12,
                  fallbackLabel: title,
                ),
                const SizedBox(height: 6),
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                if (subtitle.isNotEmpty)
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
