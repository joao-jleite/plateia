import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Testes de widget desligam as imagens de rede (override para `false`):
/// o `HttpClient` do flutter_test responde 400 e sujaria o log de erros.
final imagesEnabledProvider = Provider<bool>((ref) => true);

/// Pôster/logo/foto do TMDB com cache em disco e placeholder sem rede.
class PosterImage extends ConsumerWidget {
  const PosterImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
    this.fallbackLabel,
    this.fallbackIcon = Icons.movie_outlined,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  /// Texto do placeholder (ex.: o nome do título) quando não há imagem.
  final String? fallbackLabel;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(imagesEnabledProvider);
    final Widget child;
    if (url == null || !enabled) {
      child = _Fallback(label: fallbackLabel, icon: fallbackIcon);
    } else {
      child = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => const _Shimmer(),
        errorWidget: (_, _, _) => _Fallback(label: fallbackLabel, icon: fallbackIcon),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.label, required this.icon});

  final String? label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: scheme.outline, size: 22),
            if (label != null && label!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                label!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHigh);
}
