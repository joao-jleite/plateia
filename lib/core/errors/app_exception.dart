import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro já traduzido para a interface. `code` segue os códigos das Edge
/// Functions (docs/ARQUITETURA.md §9): bad_request, unauthorized, not_found,
/// quota_exceeded, upstream, internal; mais `network` e `config` do cliente.
class AppException implements Exception {
  const AppException(this.code, this.message, {this.cause});

  final String code;
  final String message;
  final Object? cause;

  bool get isNetwork => code == 'network';

  @override
  String toString() => 'AppException($code: $message)';
}

/// Converte qualquer erro em texto pt-BR para a tela. Preserva a mensagem das
/// Edge Functions (já vem em pt-BR) e traduz os erros conhecidos do Supabase.
String describeError(Object error) {
  if (error is AppException) return error.message;
  if (error is AuthException) return _authMessage(error);
  if (error is PostgrestException) return _postgrestMessage(error);
  if (error is FunctionException) return mapFunctionException(error).message;
  if (error is SocketException || error is http.ClientException) {
    return 'Sem conexão. Verifique a internet e tente de novo.';
  }
  return 'Algo deu errado. Tente de novo.';
}

/// `{ "error": { "code": "...", "message": "pt-BR" } }` → [AppException].
AppException mapFunctionException(FunctionException e) {
  final details = e.details;
  if (details is Map) {
    final err = details['error'];
    if (err is Map) {
      final code = err['code']?.toString() ?? 'internal';
      final message = err['message']?.toString() ?? 'Erro no servidor.';
      return AppException(code, message, cause: e);
    }
  }
  return switch (e.status) {
    401 => AppException('unauthorized', 'Sessão expirada. Entre de novo.', cause: e),
    404 => AppException('not_found', 'Não encontramos esse título.', cause: e),
    429 => AppException('quota_exceeded', 'Limite de consultas atingido. Tente mais tarde.', cause: e),
    502 || 503 || 504 => AppException('upstream', 'O serviço de catálogo não respondeu.', cause: e),
    _ => AppException('internal', 'Erro no servidor (${e.status}).', cause: e),
  };
}

String _authMessage(AuthException e) {
  final code = e.code ?? '';
  final msg = e.message.toLowerCase();
  if (code == 'invalid_credentials' || msg.contains('invalid login')) {
    return 'E-mail ou senha incorretos.';
  }
  if (code == 'email_not_confirmed') return 'Confirme seu e-mail antes de entrar.';
  if (code == 'user_already_exists' || msg.contains('already registered')) {
    return 'Já existe uma conta com esse e-mail.';
  }
  if (code == 'weak_password' || e is AuthWeakPasswordException) {
    return 'Senha fraca: use pelo menos 6 caracteres.';
  }
  if (code == 'over_email_send_rate_limit' || code == 'over_request_rate_limit') {
    return 'Muitas tentativas. Espere um pouco e tente de novo.';
  }
  if (code == 'validation_failed' || msg.contains('invalid format')) {
    return 'E-mail inválido.';
  }
  return 'Não foi possível autenticar: ${e.message}';
}

String _postgrestMessage(PostgrestException e) => switch (e.code) {
      '23505' => 'Esse valor já está em uso.',
      '23514' => 'Valor inválido.',
      '42501' => 'Você não tem permissão para isso.',
      'PGRST301' => 'Sessão expirada. Entre de novo.',
      _ => 'Erro ao salvar: ${e.message}',
    };
