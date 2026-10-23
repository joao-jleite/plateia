import 'package:flutter_riverpod/misc.dart' show Override;

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/catalog/presentation/catalog_providers.dart';
import '../../features/diary/presentation/diary_providers.dart';
import '../../features/feed/data/feed_repository.dart';
import '../../features/feed/presentation/feed_providers.dart';
import '../../features/import_netflix/presentation/import_providers.dart';
import '../../features/lists/presentation/lists_providers.dart';
import '../../features/notifications/presentation/notifications_providers.dart';
import '../../features/onboarding/presentation/my_profile_provider.dart';
import '../../features/settings/data/account_repository.dart';
import '../../features/social/presentation/social_providers.dart';
import '../../features/subscribe/presentation/subscribe_providers.dart';
import 'fixture_auth_repository.dart';
import 'fixture_catalog_repository.dart';
import 'fixture_diary.dart';
import 'fixture_import_repository.dart';
import 'fixture_netflix_csv.dart';
import 'fixture_social.dart';
import 'fixture_subscribe_repository.dart';

/// Troca os repositórios do Supabase pelos de amostra. Usado por `main.dart`
/// com `--dart-define=BACKEND=fixtures` (nunca em release) e pelos testes de
/// widget (sem rede). [failWrites] faz diário, listas e rede social recusarem
/// gravações, para exercitar o "desfazer com aviso" da interface otimista.
/// [social] permite ao teste inspecionar/semear a rede (follows, bloqueios…).
List<Override> fixtureOverrides({
  FixtureAuthRepository? auth,
  CatalogRepository? catalog,
  FixtureDiaryStore? diary,
  FixtureSocialStore? social,
  FixtureImportRepository? imports,
  FeedRepository? feed,
  FixtureSubscribeRepository? subscribe,
  bool failWrites = false,
  Duration latency = const Duration(milliseconds: 250),
}) {
  final authRepo = auth ?? FixtureAuthRepository(latency: latency);
  final catalogRepo = catalog ?? FixtureCatalogRepository(latency: latency);
  final store = diary ?? FixtureDiaryStore();
  // a rede social se liga ao diário (visibilidade, atividades por "trigger")
  final socialStore = social ?? FixtureSocialStore(store);
  final importRepo = imports ?? FixtureImportRepository(store, authRepo, latency: latency, failWrites: failWrites);
  // a aba Assinar lê o diário, o feed e o "cache" do catálogo de amostra
  final subscribeRepo = subscribe ??
      FixtureSubscribeRepository(store, socialStore, authRepo, catalog: catalogRepo, latency: latency, failWrites: failWrites);
  return [
    importRepositoryProvider.overrideWith((ref) => importRepo),
    // botão "Usar CSV de exemplo" na tela de importar (só com fixtures)
    sampleCsvProvider.overrideWith((ref) => sampleNetflixCsvBytes()),
    // "Entrar como @foxer / @camila / @vini" na tela de login (só com fixtures)
    fixtureLoginProvider.overrideWith(
      (ref) => FixtureLoginOptions(
        users: [FixtureDiaryStore.foxer, FixtureDiaryStore.camila, FixtureDiaryStore.vini],
        signIn: authRepo.signInAs,
      ),
    ),
    authRepositoryProvider.overrideWith((ref) => authRepo),
    catalogRepositoryProvider.overrideWith((ref) => catalogRepo),
    profileRepositoryProvider.overrideWith((ref) => FixtureProfileRepository(authRepo, store, latency: latency)),
    accountRepositoryProvider.overrideWith((ref) => FixtureAccountRepository(authRepo)),
    entriesRepositoryProvider.overrideWith((ref) => FixtureEntriesRepository(store, authRepo, latency: latency, failWrites: failWrites)),
    listsRepositoryProvider.overrideWith((ref) => FixtureListsRepository(store, authRepo, latency: latency, failWrites: failWrites)),
    socialRepositoryProvider.overrideWith((ref) => FixtureSocialRepository(socialStore, authRepo, latency: latency, failWrites: failWrites)),
    feedRepositoryProvider.overrideWith((ref) => feed ?? FixtureFeedRepository(socialStore, authRepo, latency: latency, failWrites: failWrites)),
    notificationsRepositoryProvider
        .overrideWith((ref) => FixtureNotificationsRepository(socialStore, authRepo, latency: latency, failWrites: failWrites)),
    subscribeRepositoryProvider.overrideWith((ref) => subscribeRepo),
  ];
}
