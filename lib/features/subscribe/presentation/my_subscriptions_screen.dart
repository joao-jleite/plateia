import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../catalog/domain/catalog_models.dart';
import '../domain/recommender.dart';
import '../domain/renewal.dart';
import '../domain/subscribe_models.dart';
import 'subscribe_providers.dart';

/// Meus streamings (`/subscribe/mine`, SPEC §J5.5): marcar o que assino,
/// plano, data de renovação e lembrete local 3 dias antes; economia estimada
/// no ano (tudo o que marquei × 12 contra o recomendado × 12).
class MySubscriptionsScreen extends ConsumerWidget {
  const MySubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(mySubscriptionsProvider);
    final providers = ref.watch(featuredProvidersProvider);
    final prices = ref.watch(providerPricesProvider).value ?? const [];
    final best = ref.watch(recommendationProvider).value?.best;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus streamings'),
        actions: [
          IconButton(
            tooltip: 'Testar lembrete',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => unawaited(_testReminder(context, ref)),
          ),
        ],
      ),
      body: AsyncView<List<UserSubscription>>(
        value: subs,
        onRetry: () => ref.invalidate(mySubscriptionsProvider),
        data: (mine) => AsyncView<List<StreamingProvider>>(
          value: providers,
          onRetry: () => ref.invalidate(featuredProvidersProvider),
          data: (featured) => ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: _SummaryCard(mine: mine, prices: prices, best: best),
              ),
              for (final p in featured)
                _ProviderRow(
                  provider: p,
                  subscription: mine.where((s) => s.providerId == p.id).firstOrNull,
                  prices: prices.where((x) => x.providerId == p.id).toList(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'O lembrete é uma notificação do próprio celular, $reminderDaysBefore dias antes da renovação, às ${reminderHour}h. '
                  'Nada sai do aparelho. Se a data já passou, a gente projeta a próxima renovação mês a mês.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testReminder(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final scheduler = ref.read(reminderSchedulerProvider);
    final mine = ref.read(mySubscriptionsProvider).value ?? const [];
    final prices = ref.read(providerPricesProvider).value ?? const [];
    final sample = mine.where((s) => s.renewsOn != null).firstOrNull;
    final name = sample?.provider?.name ?? 'Netflix';
    final cents = sample == null ? 4490 : (sample.priceCents ?? monthlyPriceFor(sample, prices) ?? 0);
    final renews = sample?.renewsOn == null
        ? DateTime.now().add(const Duration(days: reminderDaysBefore))
        : nextRenewal(sample!.renewsOn!, DateTime.now());
    final allowed = await scheduler.ensurePermission();
    if (!allowed) {
      messenger.showSnackBar(const SnackBar(content: Text('Sem permissão para notificar. Libere em Configurações do Android › Notificações.')));
      return;
    }
    await scheduler.showTest(providerName: name, priceCents: cents, renewsOn: renews);
    messenger.showSnackBar(const SnackBar(content: Text('Lembrete de teste enviado. Veja a barra de notificações.')));
  }
}

/// Quanto pago por mês e por ano, e a economia estimada contra o recomendado.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.mine, required this.prices, required this.best});

  final List<UserSubscription> mine;
  final List<ProviderPrice> prices;
  final dynamic best; // ProviderScore? (evita importar o modelo inteiro só para o tipo)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthly = monthlyTotalCents(mine, prices);
    final recommended = best == null ? null : (best.price.priceCents as int);
    final savings = yearlySavingsCents(mine: mine, prices: prices, recommendedMonthlyCents: recommended);

    final String savingsText;
    if (mine.isEmpty) {
      savingsText = 'Marque o que você assina para ver quanto dá para economizar.';
    } else if (savings == null) {
      savingsText = 'Sem recomendação ainda: marque títulos como "Quero ver" para comparar.';
    } else if (savings > 0) {
      savingsText = 'Economia estimada no ano: ${formatBrl(savings)}, assinando só o recomendado a cada mês '
          '(hoje, ${best.provider.name} por ${formatBrl(recommended!)}).';
    } else if (savings == 0) {
      savingsText = 'Você já gasta exatamente o recomendado (${best.provider.name}).';
    } else {
      savingsText = 'Você já gasta menos do que o recomendado (${best.provider.name}, ${formatBrl(recommended!)}): nada a cortar.';
    }

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mine.isEmpty ? 'Você não marcou nenhum streaming' : 'Você paga ${formatBrl(monthly)} por mês',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
            ),
            if (mine.isNotEmpty)
              Text('${formatBrl(monthly * 12)} por ano em ${mine.length == 1 ? '1 streaming' : '${mine.length} streamings'}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
            const SizedBox(height: 8),
            Text(savingsText, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}

/// Uma linha por streaming destacado: chave "assino", plano, renovação e lembrete.
class _ProviderRow extends ConsumerWidget {
  const _ProviderRow({required this.provider, required this.subscription, required this.prices});

  final StreamingProvider provider;
  final UserSubscription? subscription;
  final List<ProviderPrice> prices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = subscription;
    final today = DateTime.now();

    String? subtitle;
    if (s != null) {
      final price = s.priceCents ?? monthlyPriceFor(s, prices);
      subtitle = [
        if (s.plan != null) s.plan!.labelPtBr,
        if (price != null) '${formatBrl(price)}/mês',
        if (s.renewsOn != null) '${renewalLabel(s.renewsOn!, today)} (${shortDatePtBr(nextRenewal(s.renewsOn!, today))})',
        if (s.renewsOn != null) s.remindBeforeRenewal ? 'lembrete $reminderDaysBefore dias antes' : 'sem lembrete',
      ].join(' · ');
    }

    Future<void> edit() => showSubscriptionSheet(context, ref, provider: provider, current: s, prices: prices);

    Future<void> remove() async {
      final messenger = ScaffoldMessenger.of(context);
      final removed = s!;
      final error = await ref.read(mySubscriptionsProvider.notifier).remove(provider.id);
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text('Não deu para salvar. Desfizemos. ($error)')));
        return;
      }
      messenger.showSnackBar(SnackBar(
        content: Text('${provider.name} desmarcado.'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => unawaited(ref.read(mySubscriptionsProvider.notifier).save(
                SubscriptionDraft.from(removed, providerId: provider.id, today: today),
                provider: provider,
              )),
        ),
      ));
    }

    return ListTile(
      leading: PosterImage(
        url: TmdbImages.logo(provider.logoPath),
        width: 44,
        height: 44,
        borderRadius: 10,
        fallbackIcon: Icons.live_tv_outlined,
      ),
      title: Text(provider.name),
      subtitle: subtitle == null ? null : Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Switch(
        value: s != null,
        onChanged: (v) => unawaited(v ? edit() : remove()),
      ),
      onTap: s == null ? () => unawaited(edit()) : () => unawaited(edit()),
    );
  }
}

/// Folha para marcar/editar uma assinatura: plano, preço que paga (opcional),
/// data de renovação e lembrete. Salvar grava (otimista) e pede a permissão de
/// notificação se o lembrete estiver ligado.
Future<void> showSubscriptionSheet(
  BuildContext context,
  WidgetRef ref, {
  required StreamingProvider provider,
  required UserSubscription? current,
  required List<ProviderPrice> prices,
}) async {
  final draft = await showModalBottomSheet<SubscriptionDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _SubscriptionSheet(provider: provider, current: current, prices: prices),
  );
  if (draft == null || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final error = await ref.read(mySubscriptionsProvider.notifier).save(draft, provider: provider);
  if (error != null) {
    messenger.showSnackBar(SnackBar(content: Text('Não deu para salvar. Desfizemos. ($error)')));
    return;
  }
  if (draft.remindBeforeRenewal && draft.renewsOn != null) {
    final allowed = await ref.read(reminderSchedulerProvider).ensurePermission();
    if (!allowed) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Assinatura salva, mas sem permissão para notificar: o lembrete não vai aparecer. Libere em Configurações do Android.'),
      ));
      return;
    }
    // a permissão pode ter acabado de ser concedida: agenda de novo
    unawaited(ref.read(reminderSchedulerProvider).sync(ref.read(mySubscriptionsProvider).value ?? const []));
    messenger.showSnackBar(SnackBar(
      content: Text('${provider.name} salvo. Lembrete em ${shortDatePtBr(reminderMoment(draft.renewsOn!, DateTime.now()))}.'),
    ));
  } else {
    messenger.showSnackBar(SnackBar(content: Text('${provider.name} salvo.')));
  }
}

class _SubscriptionSheet extends StatefulWidget {
  const _SubscriptionSheet({required this.provider, required this.current, required this.prices});

  final StreamingProvider provider;
  final UserSubscription? current;
  final List<ProviderPrice> prices;

  @override
  State<_SubscriptionSheet> createState() => _SubscriptionSheetState();
}

class _SubscriptionSheetState extends State<_SubscriptionSheet> {
  late SubscriptionDraft _draft;
  late final TextEditingController _price;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _draft = SubscriptionDraft.from(widget.current, providerId: widget.provider.id, today: today);
    // sem plano com preço de tabela, o padrão da folha é o primeiro plano que existe
    if (widget.current == null && widget.prices.isNotEmpty && !widget.prices.any((p) => p.plan == _draft.plan)) {
      _draft = _draft.copyWith(plan: widget.prices.first.plan);
    }
    final cents = widget.current?.priceCents;
    _price = TextEditingController(text: cents == null ? '' : formatBrl(cents).replaceFirst('R\$ ', ''));
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  List<PricePlan> get _plans {
    final available = widget.prices.map((p) => p.plan).toSet();
    final plans = PricePlan.values.where(available.contains).toList();
    return plans.isEmpty ? PricePlan.values : plans;
  }

  int? _tablePrice(PricePlan? plan) => widget.prices.where((p) => p.plan == plan).firstOrNull?.priceCents;

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.renewsOn ?? today,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365 * 2)),
      helpText: 'Quando renova?',
    );
    if (picked != null) setState(() => _draft = _draft.copyWith(renewsOn: picked));
  }

  void _save() {
    final text = _price.text.trim();
    int? cents;
    if (text.isNotEmpty) {
      cents = parseBrlCents(text);
      if (cents == null || cents < 0) {
        setState(() => _priceError = 'Use um valor como 44,90.');
        return;
      }
    }
    Navigator.pop(context, _draft.copyWith(priceCents: cents));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final table = _tablePrice(_draft.plan);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PosterImage(url: TmdbImages.logo(widget.provider.logoPath), width: 40, height: 40, borderRadius: 10, fallbackIcon: Icons.live_tv_outlined),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.provider.name, style: theme.textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Plano', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          SegmentedButton<PricePlan>(
            segments: [for (final p in _plans) ButtonSegment(value: p, label: Text(p.labelPtBr))],
            selected: {_draft.plan ?? _plans.first},
            onSelectionChanged: (s) => setState(() => _draft = _draft.copyWith(plan: s.first)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Quanto você paga por mês (opcional)',
              prefixText: 'R\$ ',
              helperText: table == null ? 'Sem preço de tabela para este plano.' : 'Tabela: ${formatBrl(table)}. Deixe vazio para usar a tabela.',
              errorText: _priceError,
            ),
            onChanged: (_) {
              if (_priceError != null) setState(() => _priceError = null);
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_repeat_outlined),
            title: const Text('Renova em'),
            subtitle: Text(_draft.renewsOn == null ? 'Escolher data' : shortDatePtBr(_draft.renewsOn)),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () => unawaited(_pickDate()),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Lembrar $reminderDaysBefore dias antes de renovar'),
            subtitle: const Text('Notificação no celular, para cancelar a tempo se não for usar.'),
            value: _draft.remindBeforeRenewal,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(remindBeforeRenewal: v)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
