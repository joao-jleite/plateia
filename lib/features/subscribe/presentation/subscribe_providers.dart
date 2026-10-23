import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/utils/clock.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../../diary/presentation/diary_providers.dart';
import '../../social/presentation/social_providers.dart';
import '../data/reminder_scheduler.dart';
import '../data/subscribe_repository.dart';
import '../domain/candidates.dart';
import '../domain/recommendation.dart';
import '../domain/recommender.dart';
import '../domain/subscribe_models.dart';

part 'subscribe_providers.g.dart';

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
@Riverpod(keepAlive: true)
SubscribeRepository subscribeRepository(Ref ref) =>
    SupabaseSubscribeRepository(ref.watch(supabaseClientProvider));

/// Lembrete local. Nos testes de widget é um [RecordingReminderScheduler]
/// (`pumpScreen`); no app, o real, que ao toque na notificação abre Meus streamings.
@Riverpod(keepAlive: true)
ReminderScheduler reminderScheduler(Ref ref) =>
    LocalReminderScheduler(onTap: (route) => ref.read(appRouterProvider).push(route));

/// Chave "aceito plano com anúncios" (SPEC §5.9). Vive enquanto o app vive:
/// ainda não há preferência local persistida (decisão da fase 07, ▶).
@Riverpod(keepAlive: true)
class AcceptAds extends _$AcceptAds {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// Sobe a cada gravação em `user_subscriptions`; a recomendação observa.
@Riverpod(keepAlive: true)
class SubscriptionsVersion extends _$SubscriptionsVersion {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Preços de tabela. keepAlive: mudam só pelo dashboard; puxar para atualizar invalida.
@Riverpod(keepAlive: true)
Future<List<ProviderPrice>> providerPrices(Ref ref) => ref.watch(subscribeRepositoryProvider).prices();

/// Os 8 streamings destacados (sem variantes), na ordem de exibição. É a lista
/// de "Meus streamings" e a base da conta.
@Riverpod(keepAlive: true)
Future<List<StreamingProvider>> featuredProviders(Ref ref) async {
  final all = await ref.watch(catalogRepositoryProvider).providers();
  return all.where((p) => p.isFeatured && p.parentId == null).toList()
    ..sort((a, b) => (a.displayOrder ?? 1 << 20).compareTo(b.displayOrder ?? 1 << 20));
}

/// Minhas assinaturas (`/subscribe/mine`): leitura, gravação otimista com
/// desfazer e o lembrete local sincronizado a cada mudança (e ao carregar, para
/// o aparelho refletir o banco depois de reinstalar ou trocar de celular).
@Riverpod(keepAlive: true)
class MySubscriptions extends _$MySubscriptions {
  @override
  Future<List<UserSubscription>> build() async {
    // ao trocar de conta no mesmo aparelho a lista tem que ser da conta nova
    ref.watch(authStateProvider).value?.id;
    final list = await ref.watch(subscribeRepositoryProvider).mySubscriptions();
    unawaited(_resync(list));
    return list;
  }

  /// (Re)agenda os lembretes. Quem não informou quanto paga leva o preço de
  /// tabela do plano, para a notificação dizer o valor da cobrança.
  Future<void> _resync(List<UserSubscription> list) async {
    try {
      final prices = ref.read(providerPricesProvider).value ?? const <ProviderPrice>[];
      final priced = [
        for (final s in list) s.priceCents != null ? s : s.copyWith(priceCents: monthlyPriceFor(s, prices)),
      ];
      await ref.read(reminderSchedulerProvider).sync(priced);
    } catch (_) {
      // sem permissão ou plataforma sem notificação: a tela avisa ao marcar
    }
  }

  /// Marcar ou editar. Null = deu certo; texto = erro (a tela avisa e já desfez).
  Future<String?> save(SubscriptionDraft draft, {StreamingProvider? provider}) async {
    final previous = state;
    final current = [...?previous.value];
    final i = current.indexWhere((s) => s.providerId == draft.providerId);
    final uid = ref.read(authStateProvider).value?.id ?? '';
    final optimistic = UserSubscription(
      userId: uid,
      providerId: draft.providerId,
      plan: draft.plan,
      priceCents: draft.priceCents,
      startedOn: draft.startedOn,
      renewsOn: draft.renewsOn,
      remindBeforeRenewal: draft.remindBeforeRenewal,
      provider: provider ?? (i >= 0 ? current[i].provider : null),
    );
    if (i >= 0) {
      current[i] = optimistic;
    } else {
      current.add(optimistic);
    }
    state = AsyncData(current);
    try {
      final saved = await ref.read(subscribeRepositoryProvider).saveSubscription(draft);
      if (!ref.mounted) return null;
      final list = [...?state.value];
      final j = list.indexWhere((s) => s.providerId == saved.providerId);
      final merged = saved.provider == null ? saved.copyWith(provider: optimistic.provider) : saved;
      if (j >= 0) {
        list[j] = merged;
      } else {
        list.add(merged);
      }
      state = AsyncData(list);
      ref.read(subscriptionsVersionProvider.notifier).bump();
      unawaited(_resync(list));
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }

  Future<String?> remove(int providerId) async {
    final previous = state;
    final current = [...?previous.value]..removeWhere((s) => s.providerId == providerId);
    state = AsyncData(current);
    try {
      await ref.read(subscribeRepositoryProvider).removeSubscription(providerId);
      if (!ref.mounted) return null;
      ref.read(subscriptionsVersionProvider.notifier).bump();
      unawaited(_resync([...?state.value]));
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }
}

/// A recomendação da aba Assinar: candidatos (meu diário + feed dos amigos),
/// disponibilidade **em cache** dos candidatos, preços e minhas assinaturas →
/// `recommend()`. Recalcula quando o diário, a rede, as assinaturas ou a chave
/// de anúncios mudam. Nunca chama Edge Function: sem cache é "sem dados".
@riverpod
Future<Recommendation> recommendation(Ref ref) async {
  ref.watch(diaryVersionProvider);
  ref.watch(socialVersionProvider);
  ref.watch(subscriptionsVersionProvider);
  ref.watch(titleCacheVersionProvider);
  final acceptAds = ref.watch(acceptAdsProvider);
  final uid = ref.watch(authStateProvider).value?.id ?? '';
  final repo = ref.watch(subscribeRepositoryProvider);
  final now = ref.watch(clockProvider)();

  // as cinco leituras são independentes: disparadas juntas
  final entriesFuture = repo.myEntries();
  final friendsFuture = repo.friendsActivity(since: now.subtract(friendsWindow));
  final pricesFuture = ref.watch(providerPricesProvider.future);
  final providersFuture = ref.watch(featuredProvidersProvider.future);
  final subscriptionsFuture = ref.watch(mySubscriptionsProvider.future);

  final candidates = buildCandidates(
    myUserId: uid,
    myEntries: await entriesFuture,
    friendActivities: await friendsFuture,
    now: now,
  );
  final availability = await repo.availabilityFor([for (final c in candidates) c.titleId]);

  return recommend(RecommendInput(
    candidates: candidates,
    availability: availability,
    providers: await providersFuture,
    prices: await pricesFuture,
    mySubscriptions: {for (final s in await subscriptionsFuture) s.providerId},
    acceptAds: acceptAds,
    now: now,
  ));
}
