/// Pontos de entrada da importação que rodam fora da thread da interface
/// (`compute`): funções de nível superior com argumentos e retornos simples,
/// como o isolate exige. Sem Flutter: `crypto` é Dart puro.
library;

import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'grouper.dart';
import 'netflix_csv.dart';

class PrepareCsvInput {
  const PrepareCsvInput({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// O arquivo lido: o que o app precisa para avisar "já importado" (hash),
/// escolher o perfil e seguir para o agrupamento. Os bytes não ficam.
class PreparedCsv {
  const PreparedCsv({required this.fileName, required this.fileHash, required this.parsed});

  final String fileName;

  /// sha-256 do arquivo em hexadecimal (`imports.file_hash`).
  final String fileHash;
  final ParsedCsv parsed;
}

/// Lê, decodifica, interpreta e calcula o hash. Lança
/// [NetflixCsvFormatException] se o cabeçalho não for reconhecido.
PreparedCsv prepareCsv(PrepareCsvInput input) {
  final hash = sha256.convert(input.bytes).toString();
  final parsed = parseNetflixCsv(decodeCsvBytes(input.bytes));
  return PreparedCsv(fileName: input.fileName, fileHash: hash, parsed: parsed);
}

class GroupInput {
  const GroupInput({required this.parsed, this.profile});

  final ParsedCsv parsed;

  /// Perfil escolhido na exportação completa; null = todas as linhas.
  final String? profile;
}

List<ImportGroup> groupPrepared(GroupInput input) => groupRows(input.parsed.rowsFor(input.profile));
