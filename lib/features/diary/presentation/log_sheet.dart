import 'dart:async';

import 'package:flutter/material.dart' hide Title;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/model/media_type.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/poster_image.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../lists/presentation/add_to_list_sheet.dart';
import '../domain/entry.dart';
import 'diary_providers.dart';

/// Abre a folha Registrar (SPEC §J3) por cima do detalhe do título.
Future<void> showLogSheet(BuildContext context, {required TitleDetail detail}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => LogSheet(detail: detail),
  );
}

/// Folha Registrar: Assisti / Assistindo / Quero ver (um toque marca, o mesmo
/// toque desmarca), nota em meias estrelas, data, review com spoiler e, em
/// série, temporada/episódio. Estado e nota gravam na hora (otimista); review,
/// progresso e spoiler gravam em "Salvar" ou ao fechar a folha.
class LogSheet extends ConsumerStatefulWidget {
  const LogSheet({super.key, required this.detail});

  final TitleDetail detail;

  @override
  ConsumerState<LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends ConsumerState<LogSheet> {
  late EntryDraft _draft;
  late final TextEditingController _review;
  late final TextEditingController _episode;
  bool _dirty = false;

  Title get _title => widget.detail.title;
  String get _titleId => _title.id;
  bool get _isSeries => _title.mediaType == MediaType.tv;

  EntryForTitleProvider get _provider => entryForTitleProvider(_titleId);
  Entry? get _entry => ref.read(_provider).value;

  @override
  void initState() {
    super.initState();
    final entry = _entry;
    _draft = EntryDraft.from(entry, titleId: _titleId);
    _review = TextEditingController(text: entry?.review ?? '');
    _episode = TextEditingController(text: entry?.currentEpisode?.toString() ?? '');
  }

  @override
  void dispose() {
    _review.dispose();
    _episode.dispose();
    super.dispose();
  }

  /// Grava e, se o servidor recusar, a tela avisa (o notifier já desfez).
  void _commit(EntryDraft draft) {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(_provider.notifier);
    _dirty = false;
    unawaited(notifier.save(draft, title: _title).then((error) {
      if (error != null) _warn(messenger, error);
    }));
  }

  void _warn(ScaffoldMessengerState messenger, String error) {
    messenger.showSnackBar(SnackBar(content: Text('Não deu para salvar. Desfizemos a alteração. ($error)')));
  }

  EntryDraft _withProgress(EntryDraft d, {EntryStatus? status}) {
    final s = status ?? d.status;
    if (!_isSeries) return d.copyWith(status: s);
    return d.copyWith(
      status: s,
      episodesWatched: episodesWatchedFor(_title, status: s, season: d.currentSeason, episode: d.currentEpisode),
    );
  }

  void _onStatus(Set<EntryStatus> selection) {
    final current = _entry;
    if (selection.isEmpty) {
      // segundo toque no mesmo estado: desmarca
      if (current == null) return;
      final messenger = ScaffoldMessenger.of(context);
      setState(() {
        _draft = EntryDraft.from(null, titleId: _titleId);
        _review.clear();
        _dirty = false;
      });
      unawaited(ref.read(_provider.notifier).remove().then((error) {
        if (error != null) _warn(messenger, error);
      }));
      return;
    }
    final status = selection.single;
    var next = _withProgress(_draft.copyWith(review: _review.text), status: status).normalized();
    if (status == EntryStatus.want) _review.clear();
    setState(() => _draft = next);
    _commit(next);
  }

  void _onRating(double? rating) {
    // Nota sem estado marca "Assisti" (nota implica ter visto).
    final status = _draft.status.allowsRatingAndReview && _entry != null ? _draft.status : EntryStatus.watched;
    final next = _withProgress(_draft.copyWith(rating: rating, review: _review.text), status: status).normalized();
    setState(() => _draft = next);
    _commit(next);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.watchedAt ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Quando você assistiu?',
    );
    if (picked == null) return;
    final next = _draft.copyWith(watchedAt: picked);
    setState(() => _draft = next);
    if (_entry != null) _commit(next.copyWith(review: _review.text).normalized());
  }

  void _onProgress({int? season, String? episodeText}) {
    final episode = episodeText == null ? _draft.currentEpisode : int.tryParse(episodeText.trim());
    setState(() {
      _draft = _withProgress(_draft.copyWith(currentSeason: season ?? _draft.currentSeason, currentEpisode: episode));
      _dirty = true;
    });
  }

  void _save() {
    final next = _withProgress(_draft.copyWith(review: _review.text)).normalized();
    _commit(next);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entryState = ref.watch(_provider);
    final entry = entryState.value;
    final registered = entry != null;
    final status = registered ? entry.status : null;
    final showDetails = registered && status!.allowsRatingAndReview;
    final seasons = _title.seasons.where((s) => s.seasonNumber > 0).toList();

    return PopScope(
      // Fechar arrastando ou pelo voltar também salva o que ficou pendente.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _dirty && _entry != null) {
          _commit(_withProgress(_draft.copyWith(review: _review.text)).normalized());
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PosterImage(url: TmdbImages.poster(_title.posterPath, size: 'w92'), width: 40, height: 60, borderRadius: 6, fallbackLabel: ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Registrar', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
                        Text(_title.title, style: theme.textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (_title.year != null) Text('${_title.year}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentedButton<EntryStatus>(
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                selected: status == null ? const {} : {status},
                onSelectionChanged: _onStatus,
                // Sem ícone: com ícone "Assistindo" quebra em duas linhas em 360 dp.
                segments: const [
                  ButtonSegment(value: EntryStatus.watched, label: Text('Assisti')),
                  ButtonSegment(value: EntryStatus.watching, label: Text('Assistindo')),
                  ButtonSegment(value: EntryStatus.want, label: Text('Quero ver')),
                ],
              ),
              const SizedBox(height: 16),
              // Nota sempre visível: tocar nela sem estado marca "Assisti".
              Row(
                children: [
                  Text('Nota', style: theme.textTheme.titleSmall),
                  const Spacer(),
                  RatingStars(rating: showDetails ? _draft.rating : null, onChanged: _onRating, size: 34),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    child: Text(
                      showDetails && _draft.rating != null ? ratingLabel(_draft.rating!) : '–',
                      style: theme.textTheme.titleSmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              if (showDetails) ...[
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(status == EntryStatus.watching ? 'Começou em' : 'Assistiu em'),
                  subtitle: Text(_dateLabel(_draft.watchedAt)),
                  trailing: TextButton(onPressed: _pickDate, child: const Text('Mudar')),
                ),
                if (_isSeries) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          key: const Key('log-season'),
                          initialValue: seasons.any((s) => s.seasonNumber == _draft.currentSeason) ? _draft.currentSeason : null,
                          decoration: const InputDecoration(labelText: 'Temporada', isDense: true),
                          items: [
                            for (final s in seasons)
                              DropdownMenuItem(value: s.seasonNumber, child: Text('T${s.seasonNumber} · ${s.episodeCount} ep')),
                          ],
                          onChanged: (v) => _onProgress(season: v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          key: const Key('log-episode'),
                          controller: _episode,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Episódio', isDense: true),
                          onChanged: (v) => _onProgress(episodeText: v),
                        ),
                      ),
                    ],
                  ),
                  if (_draft.episodesWatched != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${_draft.episodesWatched} episódios contados nas suas horas',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ),
                ],
                const SizedBox(height: 12),
                TextField(
                  key: const Key('log-review'),
                  controller: _review,
                  maxLines: 4,
                  minLines: 2,
                  maxLength: 5000,
                  decoration: const InputDecoration(labelText: 'Review (opcional)', alignLabelWithHint: true),
                  onChanged: (_) => setState(() => _dirty = true),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Contém spoiler'),
                  subtitle: const Text('A review aparece borrada até a pessoa tocar.'),
                  value: _draft.hasSpoiler,
                  onChanged: (v) => setState(() {
                    _draft = _draft.copyWith(hasSpoiler: v);
                    _dirty = true;
                  }),
                ),
                if (status == EntryStatus.watched)
                  OutlinedButton.icon(
                    onPressed: () {
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => _draft = _draft.copyWith(watchCount: _draft.watchCount + 1, watchedAt: DateTime.now()));
                      unawaited(ref.read(_provider.notifier).rewatch(title: _title).then((error) {
                        if (error != null) _warn(messenger, error);
                      }));
                    },
                    icon: const Icon(Icons.replay),
                    label: Text(entry.watchCount > 1 ? 'Assisti de novo (${entry.watchCount}ª vez)' : 'Assisti de novo'),
                  ),
              ],
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.playlist_add),
                title: const Text('Adicionar à lista'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showAddToListSheet(context, title: _title),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: registered && !_dirty ? () => Navigator.of(context).pop() : _save,
                child: Text(registered && !_dirty ? 'Fechar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _dateLabel(DateTime? d) {
    if (d == null) return 'hoje';
    final now = DateTime.now();
    final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
    return sameDay ? 'hoje' : shortDatePtBr(d);
  }
}
