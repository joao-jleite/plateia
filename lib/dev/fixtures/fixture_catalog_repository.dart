import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/model/media_type.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/catalog/domain/catalog_models.dart';
import 'fixture_data.dart';

/// Catálogo de amostra. Imita o comportamento observável das Edge Functions:
/// latência, erro para id desconhecido e, no detalhe, o cache com TTL de 7 dias
/// (a segunda abertura do mesmo título registra `upstream_calls: 0`, que é o
/// que o log da função de verdade mostra).
class FixtureCatalogRepository implements CatalogRepository {
  FixtureCatalogRepository({this.latency = const Duration(milliseconds: 350), DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final Duration latency;
  final DateTime Function() _clock;

  /// (tipo, id) → quando o "cache" foi renovado pela última vez.
  final Map<String, DateTime> _fetchedAt = {};

  static const _ttl = Duration(days: 7);

  /// O detalhe deste título já foi aberto (e, portanto, "onde assistir" está
  /// em cache)? A aba Assinar (fase 07) usa para um título marcado como nunca
  /// consultado (`FixtureTitle.providersCached = false`) sair do "sem dados"
  /// depois que a pessoa abre o detalhe, como no banco de verdade.
  bool hasFetched(MediaType type, int tmdbId) => _fetchedAt.containsKey('${type.path}/$tmdbId');

  @override
  Future<SearchPage> search(String query, {int page = 1}) async {
    await Future<void>.delayed(latency);
    final q = _fold(query);
    if (q.isEmpty) return const SearchPage(results: []);
    final results = fixtureTitles
        .where((t) => _fold(t.title.title).contains(q) || _fold(t.title.originalTitle ?? '').contains(q))
        .map((t) => t.item)
        .toList();
    _log('catalog-search', upstreamCalls: 1, extra: 'q="$query" results=${results.length}');
    return SearchPage(results: results, page: 1, totalPages: 1);
  }

  @override
  Future<TitleDetail> title({required MediaType type, required int tmdbId, bool force = false}) async {
    await Future<void>.delayed(latency);
    final fixture = fixtureTitles.where((t) => t.title.tmdbId == tmdbId && t.title.mediaType == type).firstOrNull;
    if (fixture == null) {
      _log('catalog-title', upstreamCalls: 1, extra: 'tmdb_id=$tmdbId → 404');
      throw const AppException('not_found', 'Não encontramos esse título.');
    }

    final key = '${type.path}/$tmdbId';
    final now = _clock();
    final last = _fetchedAt[key];
    final stale = last == null || now.difference(last) > _ttl;
    // force só renova se a última atualização tiver mais de 24 h (§10.5).
    final forced = force && last != null && now.difference(last) > const Duration(hours: 24);
    final upstream = (stale || forced) ? 2 : 0; // TMDB + Streaming Availability
    if (upstream > 0) _fetchedAt[key] = now;
    final fetched = _fetchedAt[key]!;
    _log('catalog-title', upstreamCalls: upstream, extra: 'tmdb_id=$tmdbId cache=${upstream == 0 ? 'hit' : 'miss'}');

    return TitleDetail(
      title: fixture.title.copyWith(fetchedAt: fetched),
      availability: fixture.availability.map((a) => a.copyWith(fetchedAt: fetched)).toList(),
      sync: TitleSync(
        providersFetchedAt: fetched,
        linksFetchedAt: fixture.linksStatus == 'ok' ? fetched : null,
        linksStatus: fixture.linksStatus,
      ),
    );
  }

  @override
  Future<HomeSections> homeSections() async {
    await Future<void>.delayed(latency);
    _log('home-sections', upstreamCalls: 0, extra: 'cache=hit');
    return fixtureHomeSections();
  }

  @override
  Future<List<StreamingProvider>> providers() async {
    await Future<void>.delayed(latency);
    return FixtureProviders.all;
  }

  /// Mesma linha de log que as Edge Functions escrevem (ARQUITETURA §15).
  void _log(String fn, {required int upstreamCalls, String extra = ''}) {
    debugPrint('[fixtures] {fn: $fn, user: fixture, ms: ${latency.inMilliseconds}, upstream_calls: $upstreamCalls} $extra');
  }

  static String _fold(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c')
      .trim();
}
