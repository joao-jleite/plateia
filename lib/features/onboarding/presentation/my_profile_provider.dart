import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';

part 'my_profile_provider.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    SupabaseProfileRepository(ref.watch(supabaseClientProvider));

/// Perfil do usuário logado. `null` sem sessão. Alimenta o `redirect` do
/// router (onboarding feito?) e o cartão da aba Perfil.
@Riverpod(keepAlive: true)
class MyProfile extends _$MyProfile {
  @override
  Future<Profile?> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return null;
    return ref.watch(profileRepositoryProvider).getMyProfile();
  }

  Future<void> saveUsername(String username, {String? displayName}) async {
    final repo = ref.read(profileRepositoryProvider);
    final updated = await repo.saveUsername(username, displayName: displayName);
    state = AsyncData(updated);
  }

  Future<void> completeOnboarding() async {
    final updated = await ref.read(profileRepositoryProvider).completeOnboarding();
    state = AsyncData(updated);
  }
}
