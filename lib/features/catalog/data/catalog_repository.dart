import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/model/media_type.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../domain/catalog_models.dart';

/// Catálogo (TMDB via Edge Functions). O app nunca fala com o TMDB direto:
/// a chave fica no servidor e o cache no Postgres (docs/ARQUITETURA.md §9–10).
abstract class CatalogRepository {
  Future<SearchPage> search(String query, {int page = 1});

  /// `force` pede renovação (ignorada no servidor se a última tiver < 24 h).
  Future<TitleDetail> title({
    required MediaType type,
    required int tmdbId,
    bool force = false,
  });

  Future<HomeSections> homeSections();

  /// Tabela `providers` (leitura direta; só a Edge Function escreve). Usada
  /// pelas estatísticas do perfil para dar nome e logo a cada streaming.
  Future<List<StreamingProvider>> providers();
}

class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<SearchPage> search(String query, {int page = 1}) async {
    final json = await invokeFunction(_client, 'catalog-search', body: {'q': query, 'page': page});
    return SearchPage.fromJson(json);
  }

  @override
  Future<TitleDetail> title({required MediaType type, required int tmdbId, bool force = false}) async {
    final json = await invokeFunction(_client, 'catalog-title', body: {
      'tmdb_id': tmdbId,
      'media_type': type.path,
      if (force) 'force': true,
    });
    return TitleDetail.fromJson(json);
  }

  @override
  Future<HomeSections> homeSections() async {
    final json = await invokeFunction(_client, 'home-sections');
    return HomeSections.fromJson(json);
  }

  @override
  Future<List<StreamingProvider>> providers() async {
    final rows = await _client.from('providers').select().order('display_order', nullsFirst: false).order('name');
    return rows.map(StreamingProvider.fromJson).toList();
  }
}
