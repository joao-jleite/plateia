import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/profile.dart';

abstract class ProfileRepository {
  /// Perfil do usuário logado. Cria um provisório se o trigger não criou.
  Future<Profile> getMyProfile();

  /// `null` quando o @ está livre. Bloqueio pode esconder o dono do @: por
  /// isso [saveUsername] ainda trata o 23505.
  Future<bool> isUsernameAvailable(String username);

  Future<Profile> saveUsername(String username, {String? displayName});

  Future<Profile> completeOnboarding();
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return id;
  }

  @override
  Future<Profile> getMyProfile() async {
    final uid = _uid;
    final row = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    if (row != null) return Profile.fromJson(row);
    // Reserva: a policy "profiles: criar só o próprio" existe para este caso.
    final provisional = 'u_${uid.replaceAll('-', '').substring(0, 10)}';
    final created = await _client
        .from('profiles')
        .insert({'id': uid, 'username': provisional})
        .select()
        .single();
    return Profile.fromJson(created);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final row = await _client.from('profiles').select('id').eq('username', username).maybeSingle();
    return row == null || row['id'] == _uid;
  }

  @override
  Future<Profile> saveUsername(String username, {String? displayName}) async {
    try {
      final row = await _client
          .from('profiles')
          .update({
            'username': username,
            if (displayName != null) 'display_name': displayName.trim().isEmpty ? null : displayName.trim(),
          })
          .eq('id', _uid)
          .select()
          .single();
      return Profile.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw AppException('taken', 'Esse @ já está em uso.', cause: e);
      }
      if (e.code == '23514') {
        throw AppException('invalid', 'Só letras minúsculas, números e _ (3 a 20).', cause: e);
      }
      rethrow;
    }
  }

  @override
  Future<Profile> completeOnboarding() async {
    final row = await _client
        .from('profiles')
        .update({'onboarded_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', _uid)
        .select()
        .single();
    return Profile.fromJson(row);
  }
}
