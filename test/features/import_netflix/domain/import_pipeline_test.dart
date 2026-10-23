import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/features/import_netflix/domain/import_pipeline.dart';
import 'package:watchlog/features/import_netflix/domain/netflix_csv.dart';

void main() {
  test('prepareCsv: hash estável, formato e perfis', () {
    final bytes = File('test/fixtures/netflix/viewing_activity.csv').readAsBytesSync();
    final a = prepareCsv(PrepareCsvInput(bytes: bytes, fileName: 'ViewingActivity.csv'));
    final b = prepareCsv(PrepareCsvInput(bytes: bytes, fileName: 'outro-nome.csv'));
    expect(a.fileHash, b.fileHash, reason: 'o hash é do conteúdo, não do nome');
    expect(a.fileHash, hasLength(64));
    expect(a.parsed.kind, CsvKind.fullExport);
    expect(a.parsed.profiles, ['João', 'Vini']);

    final groupsJoao = groupPrepared(GroupInput(parsed: a.parsed, profile: 'João'));
    expect(groupsJoao.map((g) => g.rawName), ['Stranger Things', 'One Piece']);
    expect(groupPrepared(GroupInput(parsed: a.parsed)).length, 3);
  });

  test('prepareCsv: arquivo que não é da Netflix lança erro de formato', () {
    final bytes = File('test/fixtures/netflix/simple_br.csv').readAsBytesSync();
    expect(prepareCsv(PrepareCsvInput(bytes: bytes, fileName: 'x.csv')).parsed.rows.length, 22);
    expect(
      () => prepareCsv(PrepareCsvInput(bytes: Uint8List.fromList('a,b,c\n1,2,3\n'.codeUnits), fileName: 'x.csv')),
      throwsA(isA<NetflixCsvFormatException>()),
    );
  });
}
