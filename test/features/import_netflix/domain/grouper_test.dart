import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/import_netflix/domain/grouper.dart';
import 'package:watchlog/features/import_netflix/domain/netflix_csv.dart';
import 'package:watchlog/features/import_netflix/domain/title_patterns.dart';

ParsedCsv load(String name) => parseNetflixCsv(decodeCsvBytes(File('test/fixtures/netflix/$name').readAsBytesSync()));

void main() {
  late List<ImportGroup> groups;
  late Map<String, ImportGroup> byName;

  setUpAll(() {
    groups = groupRows(load('simple_br.csv').rows);
    byName = {for (final g in groups) g.rawName: g};
  });

  test('22 linhas viram 12 grupos, mais recente primeiro', () {
    expect(groups.length, 12);
    expect(groups.map((g) => g.rawName).toList(), [
      'Duna: Parte Dois',
      'Oppenheimer',
      'Stranger Things',
      'One Piece',
      'Star Wars',
      'Cobra Kai',
      'Ela disse "sim"',
      'Eu, a Patroa e as Crianças',
      'La Casa de Papel',
      'Round 6',
      'Trailer: Round 6',
      'Olhos que Condenam',
    ]);
  });

  test('série por temporada: episódios distintos, reprise não conta, especial sem padrão entra na série', () {
    final st = byName['Stranger Things']!;
    expect(st.guessedType, MediaType.tv);
    expect(st.rowsCount, 5);
    expect(st.episodesCount, 4, reason: 'Capítulo Oito visto em dois dias conta uma vez; o Especial conta');
    expect(st.lastWatchedAt, DateTime(2024, 7, 15));
    expect(st.firstWatchedAt, DateTime(2023, 1, 2));
    expect(st.seasonLabels, ['Temporada 1', 'Temporada 4']);
    expect(st.dominantKind, TitleKind.seasonNumbered);
    expect(byName.containsKey('Stranger Things: Especial de Natal'), isFalse);
  });

  test('anime com arcos nomeados e mais de um episódio é série', () {
    final op = byName['One Piece']!;
    expect(op.guessedType, MediaType.tv);
    expect(op.episodesCount, 3);
    expect(op.seasonLabels, ['Alabasta', 'East Blue']);
    expect(op.altQuery, isNull);
  });

  test('Parte, Minissérie, Volume e Episódio N são séries', () {
    expect(byName['La Casa de Papel']!.guessedType, MediaType.tv);
    expect(byName['La Casa de Papel']!.episodesCount, 2);
    expect(byName['Olhos que Condenam']!.guessedType, MediaType.tv);
    expect(byName['Olhos que Condenam']!.seasonLabels, ['Minissérie']);
    expect(byName['Cobra Kai']!.guessedType, MediaType.tv);
    expect(byName['Round 6']!.guessedType, MediaType.tv);
    expect(byName['Round 6']!.episodesCount, 2);
  });

  test('aspas e vírgula no nome preservam o nome original', () {
    expect(byName['Eu, a Patroa e as Crianças']!.guessedType, MediaType.tv);
    expect(byName['Ela disse "sim"']!.episodesCount, 1);
  });

  test('filme: título inteiro, uma "unidade", repetição em dias diferentes não vira reassistir', () {
    final op = byName['Oppenheimer']!;
    expect(op.guessedType, MediaType.movie);
    expect(op.rowsCount, 2);
    expect(op.episodesCount, 1);
    expect(op.lastWatchedAt, DateTime(2024, 8, 29));
    final duna = byName['Duna: Parte Dois']!;
    expect(duna.guessedType, MediaType.movie);
    expect(duna.rawName, 'Duna: Parte Dois', reason: 'um ":" só não é estrutura');
  });

  test('"X: Y: Z" uma vez só é incerto: sem tipo e com o título completo como alternativa', () {
    final sw = byName['Star Wars']!;
    expect(sw.guessedType, isNull);
    expect(sw.isUncertain, isTrue);
    expect(sw.altQuery, 'Star Wars: Episódio IV: Uma Nova Esperança');
    expect(sw.episodesCount, 1);
  });

  test('trailer vira "filme" e segue para a função (que não vai achar e manda à revisão)', () {
    expect(byName['Trailer: Round 6']!.guessedType, MediaType.movie);
  });

  test('toRequestJson segue o contrato da função', () {
    expect(byName['Stranger Things']!.toRequestJson(), {'raw_name': 'Stranger Things', 'guessed_type': 'tv'});
    expect(byName['Oppenheimer']!.toRequestJson(), {'raw_name': 'Oppenheimer', 'guessed_type': 'movie'});
    expect(byName['Star Wars']!.toRequestJson(), {
      'raw_name': 'Star Wars',
      'guessed_type': null,
      'alt_query': 'Star Wars: Episódio IV: Uma Nova Esperança',
    });
  });

  test('exportação completa: agrupa só o perfil escolhido', () {
    final parsed = load('viewing_activity.csv');
    final joao = groupRows(parsed.rowsFor('João'));
    expect(joao.map((g) => g.rawName).toList(), ['Stranger Things', 'One Piece']);
    final vini = groupRows(parsed.rowsFor('Vini'));
    expect(vini.single.rawName, 'Oppenheimer');
    expect(groupRows(parsed.rows).length, 3);
  });

  test('maiúsculas e acento não separam a mesma série', () {
    final g = groupRows([
      ViewingRow(title: 'Olhos que Condenam: Minissérie: Parte Um', watchedAt: DateTime(2021, 9, 9)),
      ViewingRow(title: 'OLHOS QUE CONDENAM: Minissérie: Parte Dois', watchedAt: DateTime(2021, 9, 10)),
    ]);
    expect(g.single.episodesCount, 2);
    expect(g.single.rawName, 'Olhos que Condenam', reason: 'a primeira grafia vista');
  });
}
