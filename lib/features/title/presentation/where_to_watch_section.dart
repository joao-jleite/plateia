import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/poster_image.dart';
import '../../catalog/domain/catalog_models.dart';
import '../domain/watch_action.dart';
import 'streaming_launcher.dart';

/// Seção "Onde assistir" (SPEC §5.7): um cartão por streaming, assinatura
/// primeiro, botão com o texto certo e a atribuição TMDB · JustWatch.
class WhereToWatchSection extends ConsumerWidget {
  const WhereToWatchSection({super.key, required this.detail});

  final TitleDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groups = groupAvailability(detail.availability);
    final sync = detail.sync;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Onde assistir', style: theme.textTheme.titleMedium),
            const Spacer(),
            if (sync.providersFetchedAt != null)
              Text(
                'Atualizado ${relativePtBr(sync.providersFetchedAt)}',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.tv_off_outlined, color: theme.colorScheme.outline),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Não encontramos este título em nenhum streaming no Brasil.')),
                ],
              ),
            ),
          )
        else
          for (final group in groups) ...[
            _ProviderCard(group: group, detail: detail),
            const SizedBox(height: 8),
          ],
        if (sync.linksStatus == 'quota')
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Links diretos indisponíveis este mês; o botão abre a busca do streaming.',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        const SizedBox(height: 8),
        // Atribuição obrigatória (termos do TMDB e da JustWatch).
        Text(
          'Onde assistir: dados da JustWatch via TMDB',
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}

class _ProviderCard extends ConsumerStatefulWidget {
  const _ProviderCard({required this.group, required this.detail});

  final ProviderOffer group;
  final TitleDetail detail;

  @override
  ConsumerState<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends ConsumerState<_ProviderCard> {
  bool _opening = false;

  Future<void> _open(WatchAction action) async {
    setState(() => _opening = true);
    try {
      await ref.read(streamingLauncherProvider).open(action);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não deu para abrir ${widget.group.provider.name}.')),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = widget.group;
    final title = widget.detail.title;
    final action = resolveWatchAction(
      provider: group.provider,
      deepLink: group.deepLink,
      titleName: title.title,
      mediaType: title.mediaType,
      tmdbId: title.tmdbId,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PosterImage(
              url: TmdbImages.logo(group.provider.logoPath),
              width: 44,
              height: 44,
              borderRadius: 10,
              fallbackIcon: Icons.live_tv_outlined,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.provider.name, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final offer in group.offers)
                        _OfferChip(offer: offer, highlight: offer.offerType.isSubscriptionLike),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: _opening ? null : () => _open(action),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              child: Text(action.label, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferChip extends StatelessWidget {
  const _OfferChip({required this.offer, required this.highlight});

  final Availability offer;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final price = offer.priceCents;
    final label = price != null && (offer.offerType == OfferType.rent || offer.offerType == OfferType.buy)
        ? '${offer.offerType.labelPtBr} ${brl(price)}'
        : offer.offerType.labelPtBr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: highlight ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: highlight ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
