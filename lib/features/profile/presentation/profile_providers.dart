import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../../diary/domain/entry.dart';
import '../../diary/presentation/diary_providers.dart';
import '../../lists/presentation/lists_providers.dart';
import '../../onboarding/domain/profile.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../../social/presentation/social_providers.dart';
import '../domain/profile_stats.dart';

part 'profile_providers.g.dart';

/// Cartão de um perfil pelo @. Null = não existe (ou bloqueio). Recarrega
/// quando a rede muda (bloquear some com o cartão).
@riverpod
Future<Profile?> profileByUsername(Ref ref, String username) {
  ref.watch(socialVersionProvider);
  return ref.watch(profileRepositoryProvider).getByUsername(username);
}

/// Contadores (`profile_counts`). Recarrega quando meu diário, listas ou a
/// rede (seguir/aceitar) mudam.
@riverpod
Future<ProfileCounts> profileCounts(Ref ref, String profileId) {
  ref.watch(diaryVersionProvider);
  ref.watch(listsVersionProvider);
  ref.watch(socialVersionProvider);
  return ref.watch(profileRepositoryProvider).counts(profileId);
}

/// Posso ver o conteúdo (diário, listas, estatísticas) desse perfil? Muda ao
/// ser aceito num perfil privado ou ao bloquear.
@riverpod
Future<bool> canViewContent(Ref ref, String profileId) {
  ref.watch(socialVersionProvider);
  return ref.watch(profileRepositoryProvider).canViewContent(profileId);
}

/// Diário de um perfil por aba, paginado de 60 em 60 ("Mostrar mais").
@riverpod
class ProfileEntries extends _$ProfileEntries {
  static const pageSize = 60;

  @override
  Future<List<Entry>> build(String userId, EntryStatus? status, bool onlyReviews) {
    ref.watch(diaryVersionProvider);
    return ref.watch(entriesRepositoryProvider).byUser(userId, status: status, onlyReviews: onlyReviews, limit: pageSize);
  }

  bool get hasMore {
    final current = state.value;
    return current != null && current.length >= pageSize && current.length % pageSize == 0;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || state.isLoading || !hasMore) return;
    final repo = ref.read(entriesRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final next = await repo.byUser(userId, status: status, onlyReviews: onlyReviews, offset: current.length, limit: pageSize);
      return [...current, ...next];
    });
  }
}

/// Estatísticas: linhas magras da view + função pura no cliente.
@riverpod
Future<ProfileStats> profileStats(Ref ref, String profileId) async {
  ref.watch(diaryVersionProvider);
  final rows = await ref.watch(profileRepositoryProvider).statsRows(profileId);
  return computeProfileStats(rows);
}

/// Streamings por id (nome e logo para "por streaming").
@Riverpod(keepAlive: true)
Future<Map<int, StreamingProvider>> providersIndex(Ref ref) async {
  final list = await ref.watch(catalogRepositoryProvider).providers();
  return {for (final p in list) p.id: p};
}
