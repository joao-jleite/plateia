import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';

part 'supabase_providers.g.dart';

/// Cliente único do Supabase (inicializado em `main.dart`). Com
/// `BACKEND=fixtures` ninguém lê este provider.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

/// Chama uma Edge Function com o JWT da sessão e devolve o JSON de sucesso.
/// Qualquer erro vira [AppException] com mensagem em pt-BR.
Future<Map<String, dynamic>> invokeFunction(
  SupabaseClient client,
  String name, {
  Map<String, dynamic> body = const {},
}) async {
  try {
    final res = await client.functions.invoke(name, body: body);
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw AppException('bad_response', 'Resposta inesperada do servidor.');
  } on FunctionException catch (e) {
    throw mapFunctionException(e);
  } on AuthException catch (e) {
    throw AppException('unauthorized', describeError(e), cause: e);
  } on SocketException catch (e) {
    throw AppException('network', describeError(e), cause: e);
  } on http.ClientException catch (e) {
    throw AppException('network', describeError(e), cause: e);
  }
}
