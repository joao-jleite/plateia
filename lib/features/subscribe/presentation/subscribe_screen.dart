import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../catalog/domain/catalog_models.dart';
import '../domain/recommendation.dart';
import 'subscribe_providers.dart';

/// Aba Assinar (SPEC §J5): a frase final, a conta aberta por streaming, o que
/// fica de fora, aluguel/compra à parte, "sem dados" e a data dos preços.
class SubscribeScreen extends ConsumerWidget {
  const SubscribeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rec = ref.watch(recommendationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinar'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(Routes.mySubscriptions),
            icon: const Icon(Icons.subscriptions_outlined),
            label: const Text('Meus streamings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(providerPricesProvider);
          ref.invalidate(recommendationProvider);
          try {
            await ref.read(recommendationProvider.future);
          } catch (_) {
            // o estado de erro já aparece na tela
          }
        },
        child: AsyncView<Recommendation>(
          value: rec,
          onRetry: () => ref.invalidate(recommendationProvider),
          isEmpty: (r) => r.isEmpty,
          empty: ListView(
            children: [
              EmptyView(
                icon: Icons.subscriptions_outlined,
                title: 'Sua lista está vazia',
                subtitle: 'Marque títulos como "Quero ver" e a gente diz qual streaming vale assinar este mês.',
                action: FilledButton.icon(
                  onPressed: () => context.go(Routes.search),
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar títulos'),
                ),
              ),
            ],
          ),
          data: (r) => _RecommendationView(r),
        ),
      ),
    );
  }
}

class _RecommendationView extends ConsumerWidget {
  const _RecommendationView(this.r);

  final Recommendation r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final acceptAds = ref.watch(acceptAdsProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _HeadlineCard(r),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.campaign_outlined),
          title: const Text('Aceito plano com anúncios'),
          subtitle: const Text('Usa o preço do plano com anúncios quando o streaming tem um.'),
          value: acceptAds,
          onChanged: (v) => ref.read(acceptAdsProvider.notifier).set(v),
        ),
        _PricesLine(r),
        if (r.ranking.isNotEmpty) ...[
          const _SectionTitle('A conta'),
          for (final s in r.ranking)
            _ScoreCard(
              score: s,
              highlight: s == r.best || s == r.combo,
              totalMine: r.totalMine,
            ),
        ],
        if (r.resolvingNothing.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              '${_joinNames(r.resolvingNothing.map((p) => p.name))} não ${r.resolvingNothing.length == 1 ? 'tem' : 'têm'} nenhum dos seus títulos.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        if (r.leftOut.isNotEmpty) ...[
          const _SectionTitle('Ficam de fora'),
          for (final l in r.leftOut)
            _CandidateTile(l.candidate, trailing: _joinNames(l.providers.map((p) => p.name), max: 2)),
        ],
        if (r.rentOnly.isNotEmpty) ...[
          _SectionTitle('Só para alugar ou comprar', count: r.rentOnly.length),
          for (final c in r.rentOnly) _CandidateTile(c),
        ],
        if (r.freeOnly.isNotEmpty) ...[
          _SectionTitle('Já dá para ver grátis', count: r.freeOnly.length),
          for (final c in r.freeOnly) _CandidateTile(c),
        ],
        if (r.elsewhere.isNotEmpty) ...[
          _SectionTitle('Em outro streaming', count: r.elsewhere.length, hint: 'Fora da lista de preços; abra o título para ver onde.'),
          for (final c in r.elsewhere) _CandidateTile(c),
        ],
        if (r.unavailable.isNotEmpty) ...[
          _SectionTitle('Em nenhum streaming no Brasil', count: r.unavailable.length),
          for (final c in r.unavailable) _CandidateTile(c),
        ],
        if (r.noData.isNotEmpty) ...[
          _SectionTitle('Sem dados', count: r.noData.length, hint: 'Ainda não sabemos onde estão. Abra o título para a gente buscar.'),
          for (final c in r.noData) _CandidateTile(c, trailing: 'sem dados'),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text(
            [
              if (r.totalFriends > 0)
                '${r.totalFriends == 1 ? '1 título vem' : '${r.totalFriends} títulos vêm'} de quem você segue (assistiu ou avaliou com 4+ nos últimos 30 dias) e ${r.totalFriends == 1 ? 'conta' : 'contam'} 0,3 cada; os seus contam 1.',
              'Só assinatura entra na conta; aluguel e compra ficam à parte. Onde assistir: dados da JustWatch via TMDB.',
            ].join('\n'),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// "Este mês, assine a HBO Max: …" em destaque.
class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard(this.r);

  final Recommendation r;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = r.best;
    return Card(
      color: best == null ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (best != null)
              PosterImage(
                url: TmdbImages.logo(best.provider.logoPath),
                width: 48,
                height: 48,
                borderRadius: 12,
                fallbackIcon: Icons.live_tv_outlined,
              )
            else
              Icon(Icons.info_outline, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                r.headline ?? '',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: best == null ? theme.colorScheme.onSurface : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Preços de 22/10/2026 · estimativa" com explicação ao toque.
class _PricesLine extends StatelessWidget {
  const _PricesLine(this.r);

  final Recommendation r;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = r.pricesUpdatedAt;
    final text = [
      if (date != null) 'Preços de ${shortDatePtBr(date)}' else 'Sem preços de referência',
      if (r.anyEstimate) 'estimativa',
    ].join(' · ');
    return ListTile(
      dense: true,
      leading: const Icon(Icons.sell_outlined),
      title: Text(text, style: theme.textTheme.bodyMedium),
      trailing: const Icon(Icons.info_outline, size: 18),
      onTap: () => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('De onde vêm os preços'),
          content: const Text(
            'São os preços mensais de tabela de cada streaming, conferidos à mão e anotados com a data. '
            '"Estimativa" quer dizer que o valor ainda não foi confirmado no site do streaming e pode estar diferente. '
            'Preço com mais de 60 dias ganha um aviso no cartão.\n\n'
            'Por padrão a conta usa o plano Padrão; com "Aceito plano com anúncios" ela usa o plano com anúncios quando existe.',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendi'))],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.count, this.hint});

  final String title;
  final int? count;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count == null ? title : '$title ($count)', style: theme.textTheme.titleMedium),
          if (hint != null) Text(hint!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Um streaming na conta: logo, quantos resolve, preço do plano, custo por
/// título, avisos; expande para listar os títulos.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score, required this.highlight, required this.totalMine});

  final ProviderScore score;
  final bool highlight;
  final int totalMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = score;
    final mine = s.resolvedMine;
    final friends = s.resolvedFriends;
    final resolves = [
      if (totalMine > 0) 'Resolve $mine dos seus $totalMine',
      if (friends > 0) '${totalMine > 0 ? '+ ' : ''}$friends dos amigos',
    ].join(' ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        shape: highlight
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              )
            : null,
        child: ExpansionTile(
          shape: const Border(),
          leading: PosterImage(
            url: TmdbImages.logo(s.provider.logoPath),
            width: 44,
            height: 44,
            borderRadius: 10,
            fallbackIcon: Icons.live_tv_outlined,
          ),
          title: Row(
            children: [
              Flexible(child: Text(s.provider.name, style: theme.textTheme.titleSmall)),
              if (s.alreadySubscribed) ...[
                const SizedBox(width: 8),
                _Chip('você assina', color: theme.colorScheme.secondaryContainer),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resolves),
              Text(
                '${formatBrl(s.price.priceCents)}/mês (${s.price.planLabel}) · ${formatBrl(s.costPerTitleCents)} por título',
                style: theme.textTheme.bodySmall,
              ),
              if (s.priceStale)
                Text(
                  'Preço de ${shortDatePtBr(s.price.updatedAt)}: pode ter mudado.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
            ],
          ),
          children: [for (final c in s.resolved) _CandidateTile(c)],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      );
}

/// Linha de título: pôster, nome, de quem veio, e onde está (quando faz sentido).
class _CandidateTile extends StatelessWidget {
  const _CandidateTile(this.c, {this.trailing});

  final Candidate c;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = c.mediaType;
    final id = c.tmdbId;
    final from = c.isMine
        ? null
        : (c.friendUsername != null ? '@${c.friendUsername} assistiu' : 'dos amigos');
    return ListTile(
      dense: true,
      leading: PosterImage(url: TmdbImages.poster(c.posterPath, size: 'w92'), width: 32, height: 48, borderRadius: 4, fallbackLabel: ''),
      title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: from == null ? null : Text(from, style: theme.textTheme.bodySmall),
      trailing: trailing == null
          ? null
          : Text(trailing!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      onTap: (type == null || id == null) ? null : () => context.push(Routes.title(type, id)),
    );
  }
}

/// "Netflix, Prime Video e Disney+" (com teto opcional: "Netflix, Prime Video e mais 2").
String _joinNames(Iterable<String> names, {int? max}) {
  final list = names.toList();
  if (list.isEmpty) return '';
  if (max != null && list.length > max) {
    return '${list.take(max).join(', ')} e mais ${list.length - max}';
  }
  if (list.length == 1) return list.single;
  return '${list.sublist(0, list.length - 1).join(', ')} e ${list.last}';
}

/// Só para o teste conferir a formação dos nomes sem subir a tela.
@visibleForTesting
String joinProviderNames(Iterable<StreamingProvider> providers, {int? max}) => _joinNames(providers.map((p) => p.name), max: max);
