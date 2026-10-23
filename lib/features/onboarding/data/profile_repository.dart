import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../profile/domain/profile_stats.dart';
import '../domain/profile.dart';

/// O que o perfil pode editar além do @ (cartão do perfil, SPEC §4).
class ProfileCardDraft {
  const ProfileCardDraft({this.displayName, this.bio});

  final String? displayName;
  final String? bio;
}

abstract class ProfileRepository {
  /// Perfil do usuário logado. Cria um provisório se o trigger não criou.
  Future<Profile> getMyProfile();

  /// `null` quando o @ está livre. Bloqueio pode esconder o dono do @: por
  /// isso [saveUsername] ainda trata o 23505.
  Future<bool> isUsernameAvailable(String username);

  /// [acceptTerms] grava `terms_accepted_at = now()` junto (passo 1 do onboarding).
  Future<Profile> saveUsername(String username, {String? displayName, bool acceptTerms = false});

  Future<Profile> completeOnboarding();

  // ---- fase 04 -------------------------------------------------------------

  /// Cartão de qualquer perfil pelo @. Null se não existe ou se há bloqueio
  /// (a RLS esconde a linha; para o app é a mesma coisa).
  Future<Profile?> getByUsername(String username);

  /// Nome e bio do cartão.
  Future<Profile> updateCard(ProfileCardDraft draft);

  /// Perfil privado liga/desliga (SPEC §5.3). Virar público aceita pendentes (trigger).
  Future<Profile> setPrivate(bool isPrivate);

  /// Sobe a foto já redimensionada para `avatars/<uid>/avatar.jpg` e grava a
  /// URL pública (com `?v=` para furar cache) em `profiles.avatar_url`.
  Future<Profile> uploadAvatar(Uint8List bytes, {String contentType = 'image/jpeg'});

  /// `profile_counts(uuid)`. Aparece mesmo em perfil privado.
  Future<ProfileCounts> counts(String profileId);

  /// `can_view_content(uuid)`: posso ver diário, listas e estatísticas dele?
  Future<bool> canViewContent(String profileId);

  /// Linhas da view `entry_stats_rows` para o cálculo das estatísticas.
  Future<List<StatsRow>> statsRows(String profileId);
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
  Future<Profile> saveUsername(String username, {String? displayName, bool acceptTerms = false}) async {
    try {
      final row = await _client
          .from('profiles')
          .update({
            'username': username,
            if (displayName != null) 'display_name': displayName.trim().isEmpty ? null : displayName.trim(),
            if (acceptTerms) 'terms_accepted_at': DateTime.now().toUtc().toIso8601String(),
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

  @override
  Future<Profile?> getByUsername(String username) async {
    final row = await _client.from('profiles').select().eq('username', username).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  @override
  Future<Profile> updateCard(ProfileCardDraft draft) async {
    try {
      final row = await _client
          .from('profiles')
          .update({
            'display_name': _blankToNull(draft.displayName),
            'bio': _blankToNull(draft.bio),
          })
          .eq('id', _uid)
          .select()
          .single();
      return Profile.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == '23514') {
        throw AppException('invalid', 'Nome até 50 e bio até 280 caracteres.', cause: e);
      }
      rethrow;
    }
  }

  @override
  Future<Profile> setPrivate(bool isPrivate) async {
    final row = await _client.from('profiles').update({'is_private': isPrivate}).eq('id', _uid).select().single();
    return Profile.fromJson(row);
  }

  @override
  Future<Profile> uploadAvatar(Uint8List bytes, {String contentType = 'image/jpeg'}) async {
    final uid = _uid;
    final path = '$uid/avatar.jpg';
    try {
      await _client.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType, cacheControl: '3600'),
          );
    } on StorageException catch (e) {
      throw AppException('storage', 'Não deu para subir a foto: ${e.message}', cause: e);
    }
    final url = '${_client.storage.from('avatars').getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';
    final row = await _client.from('profiles').update({'avatar_url': url}).eq('id', uid).select().single();
    return Profile.fromJson(row);
  }

  @override
  Future<ProfileCounts> counts(String profileId) async {
    final res = await _client.rpc('profile_counts', params: {'p_profile': profileId});
    // função `returns table` devolve lista; vazia quando há bloqueio
    if (res is List && res.isNotEmpty && res.first is Map) {
      return ProfileCounts.fromJson(Map<String, dynamic>.from(res.first as Map));
    }
    if (res is Map) return ProfileCounts.fromJson(Map<String, dynamic>.from(res));
    return const ProfileCounts();
  }

  @override
  Future<bool> canViewContent(String profileId) async {
    final res = await _client.rpc('can_view_content', params: {'owner': profileId});
    return res == true;
  }

  @override
  Future<List<StatsRow>> statsRows(String profileId) async {
    // Página de 500: 2 mil entradas = 4 chamadas, ~250 KB (view magra, migração 0003).
    const page = 500;
    final out = <StatsRow>[];
    for (var offset = 0;; offset += page) {
      final rows = await _client
          .from('entry_stats_rows')
          .select('status, watch_count, episodes_watched, media_type, runtime_minutes, episode_run_time, number_of_episodes, genres, year, provider_ids')
          .eq('user_id', profileId)
          .range(offset, offset + page - 1);
      out.addAll(rows.map(StatsRow.fromJson));
      if (rows.length < page) break;
    }
    return out;
  }

  static String? _blankToNull(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
