import 'package:flutter_riverpod/misc.dart' show Override;

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/catalog/presentation/catalog_providers.dart';
import '../../features/diary/presentation/diary_providers.dart';
import '../../features/lists/presentation/lists_providers.dart';
import '../../features/onboarding/presentation/my_profile_provider.dart';
import '../../features/settings/data/account_repository.dart';
import 'fixture_auth_repository.dart';
import 'fixture_catalog_repository.dart';
import 'fixture_diary.dart';

/// Troca os repositórios do Supabase pelos de amostra. Usado por `main.dart`
/// com `--dart-define=BACKEND=fixtures` (nunca em release) e pelos testes de
/// widget (sem rede). [failWrites] faz diário e listas recusarem gravações,
/// para exercitar o "desfazer com aviso" da interface otimista.
List<Override> fixtureOverrides({
  FixtureAuthRepository? auth,
  CatalogRepository? catalog,
  FixtureDiaryStore? diary,
  bool failWrites = false,
  Duration latency = const Duration(milliseconds: 250),
}) {
  final authRepo = auth ?? FixtureAuthRepository(latency: latency);
  final catalogRepo = catalog ?? FixtureCatalogRepository(latency: latency);
  final store = diary ?? FixtureDiaryStore();
  return [
    authRepositoryProvider.overrideWith((ref) => authRepo),
    catalogRepositoryProvider.overrideWith((ref) => catalogRepo),
    profileRepositoryProvider.overrideWith((ref) => FixtureProfileRepository(authRepo, store, latency: latency)),
    accountRepositoryProvider.overrideWith((ref) => FixtureAccountRepository(authRepo)),
    entriesRepositoryProvider.overrideWith((ref) => FixtureEntriesRepository(store, authRepo, latency: latency, failWrites: failWrites)),
    listsRepositoryProvider.overrideWith((ref) => FixtureListsRepository(store, authRepo, latency: latency, failWrites: failWrites)),
  ];
}
