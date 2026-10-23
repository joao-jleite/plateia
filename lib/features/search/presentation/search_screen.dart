import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/catalog_providers.dart';

/// Busca de títulos (TMDB via `catalog-search`). O ícone de pessoa leva à
/// busca por `@` (`/search/users`, fase 06).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _loadingMore = false;

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      await ref.read(searchResultsProvider(_query).notifier).loadMore();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Filme, série ou anime',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _onChanged('');
                    },
                  ),
          ),
          onChanged: (v) {
            setState(() {}); // atualiza o botão de limpar
            _onChanged(v);
          },
          onSubmitted: (v) {
            _debounce?.cancel();
            setState(() => _query = v.trim());
          },
        ),
        actions: [
          IconButton(
            key: const Key('search-people'),
            tooltip: 'Pessoas',
            icon: const Icon(Icons.person_search_outlined),
            onPressed: () => context.push(Routes.searchUsers),
          ),
        ],
      ),
      body: _query.isEmpty
          ? const EmptyView(
              icon: Icons.search,
              title: 'Busque qualquer título',
              subtitle: 'Resultados em português, com onde assistir no Brasil.',
            )
          : AsyncView<SearchPage>(
              value: results,
              onRetry: () => ref.invalidate(searchResultsProvider(_query)),
              isEmpty: (d) => d.results.isEmpty,
              empty: EmptyView(
                icon: Icons.search_off,
                title: 'Nada encontrado para "$_query"',
                subtitle: 'Tente o título original ou outra grafia.',
              ),
              data: (page) => ListView.builder(
                itemCount: page.results.length + (page.page < page.totalPages ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == page.results.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: _loadingMore
                          ? const Center(child: CircularProgressIndicator())
                          : OutlinedButton(onPressed: _loadMore, child: const Text('Mais resultados')),
                    );
                  }
                  return _ResultTile(item: page.results[i]);
                },
              ),
            ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final type = item.isAnime ? 'Anime' : item.mediaType.labelPtBr;
    final subtitle = [if (item.year != null) '${item.year}', type].join(' · ');
    return ListTile(
      leading: PosterImage(
        url: TmdbImages.poster(item.posterPath, size: 'w154'),
        width: 44,
        height: 66,
        borderRadius: 4,
        fallbackLabel: null,
      ),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
      onTap: () => context.push(Routes.title(item.mediaType, item.tmdbId)),
    );
  }
}
