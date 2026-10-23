import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Esqueletos de carregamento (fase 08): a tela mostra a forma do que vai
/// chegar em vez de um spinner no meio. Cada um imita o layout real com
/// `Bone`s dentro de `Skeletonizer.zone`, que anima o brilho sozinho.
///
/// Todos são `ExcludeSemantics` + rótulo "Carregando": o leitor de tela não
/// precisa ler dezenas de caixas cinzas.
class _Zone extends StatelessWidget {
  const _Zone({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando',
      liveRegion: true,
      child: ExcludeSemantics(child: Skeletonizer.zone(child: child)),
    );
  }
}

/// Início: duas seções de pôsteres (título + fileira).
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key, this.sections = 3});

  final int sections;

  @override
  Widget build(BuildContext context) {
    return _Zone(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [for (var i = 0; i < sections; i++) const PosterRowSkeleton()],
      ),
    );
  }
}

class PosterRowSkeleton extends StatelessWidget {
  const PosterRowSkeleton({super.key, this.posterWidth = 120});

  final double posterWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Bone.text(words: 3, fontSize: 16)),
          const SizedBox(height: 10),
          SizedBox(
            height: posterWidth * 1.5 + 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => SizedBox(
                width: posterWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(width: posterWidth, height: posterWidth * 1.5, borderRadius: BorderRadius.circular(12)),
                    const SizedBox(height: 6),
                    const Bone.text(words: 2),
                    const SizedBox(height: 4),
                    const Bone.text(words: 1, fontSize: 11),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feed: cartões com avatar, duas linhas e um pôster pequeno.
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key, this.cards = 3});

  final int cards;

  @override
  Widget build(BuildContext context) {
    return _Zone(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 6),
        children: [
          for (var i = 0; i < cards; i++)
            const Card(
              margin: EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Bone.circle(size: 36),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Bone.text(words: 2), SizedBox(height: 4), Bone.text(words: 3, fontSize: 11)],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Bone(width: 48, height: 72, borderRadius: BorderRadius.all(Radius.circular(8))),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Bone.text(words: 4), SizedBox(height: 6), Bone.text(words: 6, fontSize: 12)],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Grade de pôsteres (perfil): 3 colunas.
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.count = 9});

  final int count;

  @override
  Widget build(BuildContext context) {
    return _Zone(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2 / 3.45,
        ),
        itemCount: count,
        itemBuilder: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Bone(borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 4),
            const Bone.text(words: 2, fontSize: 11),
          ],
        ),
      ),
    );
  }
}

/// Detalhe do título: pôster, metadados, botão e dois cartões de "onde assistir".
class TitleSkeleton extends StatelessWidget {
  const TitleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Zone(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone(width: 120, height: 180, borderRadius: BorderRadius.circular(12)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(words: 3, fontSize: 20),
                    SizedBox(height: 8),
                    Bone.text(words: 4, fontSize: 12),
                    SizedBox(height: 16),
                    Bone.button(width: 160),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Bone.multiText(lines: 3),
          const SizedBox(height: 24),
          const Bone.text(words: 2, fontSize: 16),
          const SizedBox(height: 10),
          for (var i = 0; i < 2; i++) ...[
            Bone(height: 72, borderRadius: BorderRadius.circular(12)),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Listas de linhas (busca, notificações, pessoas).
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 8, this.leadingSize = 44, this.round = false});

  final int rows;
  final double leadingSize;
  final bool round;

  @override
  Widget build(BuildContext context) {
    return _Zone(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows,
        itemBuilder: (_, _) => ListTile(
          leading: round
              ? Bone.circle(size: leadingSize)
              : Bone(width: leadingSize, height: leadingSize * 1.5, borderRadius: BorderRadius.circular(8)),
          title: const Bone.text(words: 3),
          subtitle: const Bone.text(words: 2, fontSize: 12),
        ),
      ),
    );
  }
}
