import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/model/media_type.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/catalog_repository.dart';
import '../domain/catalog_models.dart';

part 'catalog_providers.g.dart';

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) =>
    SupabaseCatalogRepository(ref.watch(supabaseClientProvider));

/// Seções do Início. keepAlive para não refazer a chamada ao trocar de aba;
/// puxar para atualizar faz `ref.invalidate`.
@Riverpod(keepAlive: true)
Future<HomeSections> homeSections(Ref ref) =>
    ref.watch(catalogRepositoryProvider).homeSections();

/// Detalhe do título com cache em memória por (tipo, id) enquanto o app vive.
/// O cache de verdade (30 d / 7 d) está no Postgres, atrás da Edge Function.
@Riverpod(keepAlive: true)
class TitleDetailNotifier extends _$TitleDetailNotifier {
  @override
  Future<TitleDetail> build(MediaType type, int tmdbId) =>
      ref.watch(catalogRepositoryProvider).title(type: type, tmdbId: tmdbId);

  /// Puxar para atualizar: pede `force` (o servidor ignora se < 24 h).
  Future<void> refresh() async {
    final repo = ref.read(catalogRepositoryProvider);
    state = await AsyncValue.guard(() => repo.title(type: type, tmdbId: tmdbId, force: true));
  }
}

/// Resultados da busca com paginação acumulada ("Mais resultados").
@riverpod
class SearchResults extends _$SearchResults {
  @override
  Future<SearchPage> build(String query) {
    if (query.trim().isEmpty) {
      return Future.value(const SearchPage(results: [], page: 1, totalPages: 1));
    }
    return ref.watch(catalogRepositoryProvider).search(query.trim());
  }

  bool get hasMore {
    final current = state.value;
    return current != null && current.page < current.totalPages;
  }

  /// Busca a próxima página e acrescenta aos resultados. O estado continua
  /// `data` durante a chamada (a tela mostra o próprio spinner no botão).
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || state.isLoading || current.page >= current.totalPages) return;
    final repo = ref.read(catalogRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final next = await repo.search(query.trim(), page: current.page + 1);
      return next.copyWith(results: [...current.results, ...next.results]);
    });
  }
}
