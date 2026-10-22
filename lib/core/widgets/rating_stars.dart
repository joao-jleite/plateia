import 'package:flutter/material.dart';

/// Nota em meias estrelas (0,5–5). Só exibição quando [onChanged] é null;
/// interativa com 10 alvos de toque (metade esquerda/direita de cada estrela).
/// Tocar de novo na mesma nota limpa (null).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 20,
    this.color,
  });

  final double? rating;
  final ValueChanged<double?>? onChanged;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.amber;
    final value = rating ?? 0;
    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i ? Icons.star : (value >= i - 0.5 ? Icons.star_half : Icons.star_border),
            size: size,
            color: value >= i - 0.5 ? c : Theme.of(context).colorScheme.outline,
          ),
      ],
    );
    if (onChanged == null) return stars;

    return Semantics(
      label: rating == null ? 'Sem nota' : 'Nota $rating de 5',
      child: Stack(
        children: [
          stars,
          // 10 metades por cima dos ícones: metade n → nota n/2.
          Positioned.fill(
            child: Row(
              children: [
                for (var half = 1; half <= 10; half++)
                  Expanded(
                    child: GestureDetector(
                      key: Key('rating-half-$half'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final next = half / 2;
                        onChanged!(rating == next ? null : next);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "4,5" no padrão brasileiro, para rótulos ao lado das estrelas.
String ratingLabel(double rating) =>
    rating == rating.roundToDouble() ? rating.toInt().toString() : rating.toString().replaceAll('.', ',');
