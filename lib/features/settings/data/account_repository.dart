import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

part 'account_repository.g.dart';

/// Apagar a conta (exigência da Play). A Edge Function `account-delete` apaga
/// `auth.users` (cascade em tudo) e os avatares; o app só desloga depois.
abstract class AccountRepository {
  Future<void> deleteMyAccount();
}

class SupabaseAccountRepository implements AccountRepository {
  SupabaseAccountRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> deleteMyAccount() async {
    await invokeFunction(_client, 'account-delete');
    await _client.auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) =>
    SupabaseAccountRepository(ref.watch(supabaseClientProvider));
