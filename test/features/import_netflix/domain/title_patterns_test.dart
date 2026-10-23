import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/features/import_netflix/domain/text_normalize.dart';
import 'package:watchlog/features/import_netflix/domain/title_patterns.dart';

void main() {
  group('parseTitle: um caso por padrão', () {
    test('Temporada N', () {
      final t = parseTitle('Stranger Things: Temporada 1: Capítulo Um: O Desaparecimento de Will Byers');
      expect(t.kind, TitleKind.seasonNumbered);
      expect(t.showName, 'Stranger Things');
      expect(t.seasonLabel, 'Temporada 1');
      expect(t.episodeTitle, 'Capítulo Um: O Desaparecimento de Will Byers');
      expect(t.isEpisode, isTrue);
    });

    test('Season N em inglês e série com ":" no nome', () {
      final t = parseTitle('Star Trek: Discovery: Season 2: Brother');
      expect(t.kind, TitleKind.seasonNumbered);
      expect(t.showName, 'Star Trek: Discovery');
      expect(t.seasonLabel, 'Season 2');
    });

    test('Parte N', () {
      final t = parseTitle('La Casa de Papel: Parte 2: Episódio 1');
      expect(t.kind, TitleKind.part);
      expect(t.showName, 'La Casa de Papel');
      expect(t.seasonLabel, 'Parte 2');
      expect(t.episodeTitle, 'Episódio 1');
    });

    test('Minissérie', () {
      final t = parseTitle('Olhos que Condenam: Minissérie: Parte Um');
      expect(t.kind, TitleKind.miniseries);
      expect(t.showName, 'Olhos que Condenam');
      expect(t.seasonLabel, 'Minissérie');
      expect(t.episodeTitle, 'Parte Um');
    });

    test('Volume N', () {
      final t = parseTitle('Cobra Kai: Volume 1: Episódio 1');
      expect(t.kind, TitleKind.volume);
      expect(t.showName, 'Cobra Kai');
      expect(t.seasonLabel, 'Volume 1');
    });

    test('Episódio N sem temporada (capítulo)', () {
      final t = parseTitle('Round 6: Episódio 1');
      expect(t.kind, TitleKind.chapter);
      expect(t.showName, 'Round 6');
      expect(t.seasonLabel, isNull);
      expect(t.episodeTitle, 'Episódio 1');
    });

    test('arco nomeado de anime', () {
      final t = parseTitle('One Piece: East Blue: Eu sou Luffy! O homem que vai ser o Rei dos Piratas!');
      expect(t.kind, TitleKind.namedArc);
      expect(t.showName, 'One Piece');
      expect(t.seasonLabel, 'East Blue');
      expect(t.episodeTitle, 'Eu sou Luffy! O homem que vai ser o Rei dos Piratas!');
    });

    test('filme com um ":" no nome é título puro', () {
      final t = parseTitle('Duna: Parte Dois');
      expect(t.kind, TitleKind.plain);
      expect(t.showName, 'Duna: Parte Dois');
      expect(t.isEpisode, isFalse);
      expect(t.episodeKey, 'Duna: Parte Dois');
    });

    test('filme sem ":" é título puro; trailer também (a função decide)', () {
      expect(parseTitle('Oppenheimer').kind, TitleKind.plain);
      expect(parseTitle('Trailer: Round 6').kind, TitleKind.plain);
    });

    test('filme com dois ":" cai em arco nomeado (o agrupador desfaz pela repetição)', () {
      final t = parseTitle('Star Wars: Episódio IV: Uma Nova Esperança');
      expect(t.kind, TitleKind.namedArc);
      expect(t.showName, 'Star Wars');
    });

    test('episodeKey ignora a data: a mesma reprise conta uma vez', () {
      final a = parseTitle('Stranger Things: Temporada 4: Capítulo Oito: Papai');
      final b = parseTitle('Stranger Things: Temporada 4: Capítulo Oito: Papai ');
      expect(a.episodeKey, b.episodeKey);
    });
  });

  group('normalizeName', () {
    test('acento, pontuação, &, espaços, não latino', () {
      expect(normalizeName('  Minissérie: Olhos que Condenam!  '), 'minisserie olhos que condenam');
      expect(normalizeName('Tom & Jerry'), 'tom e jerry');
      expect(normalizeName('Duna: Parte Dois'), 'duna parte dois');
      expect(normalizeName('ワンピース'), 'ワンピース');
      expect(normalizeName('Ela disse "sim"'), 'ela disse sim');
      expect(normalizeName('Eu, a Patroa e as Crianças'), 'eu a patroa e as criancas');
    });
  });
}
