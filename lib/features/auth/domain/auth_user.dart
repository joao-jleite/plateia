import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Usuário autenticado (o que o app precisa do `auth.users`). O perfil
/// público (@, foto, bio) é outra coisa: `Profile`, em `public.profiles`.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) = _AuthUser;
}

/// O que o cadastro por e-mail devolve: entrou direto ou precisa confirmar o
/// e-mail (depende de "Confirm email" no dashboard do Supabase).
enum SignUpOutcome { signedIn, needsEmailConfirmation }

/// Eventos que mudam a navegação sem mudar o usuário (ex.: a pessoa abriu o
/// link de redefinir senha e precisa de uma tela para digitar a nova).
enum AuthAppEvent { passwordRecovery }
