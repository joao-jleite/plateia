import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/model/media_type.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../catalog/domain/catalog_models.dart';
import '../data/entries_repository.dart';
import '../domain/entry.dart';

part 'diary_providers.g.dart';

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
@Riverpod(keepAlive: true)
EntriesRepository entriesRepository(Ref ref) =>
    SupabaseEntriesRepository(ref.watch(supabaseClientProvider));

/// Sobe a cada gravação bem-sucedida no diário. Grade do perfil, contadores e
/// estatísticas observam este número para recarregar sem polling.
@Riverpod(keepAlive: true)
class DiaryVersion extends _$DiaryVersion {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Meu registro para um título. Interface otimista (docs/ARQUITETURA.md §5):
/// o estado muda na hora; se o servidor recusar, volta ao anterior e o método
/// devolve a mensagem para a tela avisar. `null` = deu certo.
@riverpod
class EntryForTitle extends _$EntryForTitle {
  @override
  Future<Entry?> build(String titleId) => ref.watch(entriesRepositoryProvider).forTitle(titleId);

  String get _uid => ref.read(authStateProvider).value?.id ?? '';

  Future<String?> save(EntryDraft draft, {Title? title}) async {
    final previous = state;
    final optimistic = optimisticEntry(previous.value, draft, userId: _uid, title: title);
    state = AsyncData(optimistic);
    try {
      final saved = await ref.read(entriesRepositoryProvider).save(draft);
      // Mantém o título embutido que a tela já tinha (o servidor pode não devolver tudo).
      state = AsyncData(saved.title == null ? saved.copyWith(title: optimistic.title) : saved);
      ref.read(diaryVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      state = previous;
      return describeError(e);
    }
  }

  /// Desmarcar (o mesmo toque no estado atual).
  Future<String?> remove() async {
    final previous = state;
    if (previous.value == null) return null;
    state = const AsyncData(null);
    try {
      await ref.read(entriesRepositoryProvider).remove(titleId);
      ref.read(diaryVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      state = previous;
      return describeError(e);
    }
  }

  /// Reassistir: soma `watch_count`, data de hoje, mantém nota e review.
  Future<String?> rewatch({Title? title}) async {
    final current = state.value;
    if (current == null) return null;
    final draft = EntryDraft.from(current, titleId: titleId).copyWith(
      status: EntryStatus.watched,
      watchCount: current.watchCount + 1,
      watchedAt: DateTime.now(),
      episodesWatched: title == null || title.mediaType != MediaType.tv
          ? current.episodesWatched
          : episodesWatchedFor(title, status: EntryStatus.watched),
    );
    return save(draft, title: title ?? current.title);
  }
}
