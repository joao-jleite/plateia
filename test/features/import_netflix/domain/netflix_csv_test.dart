import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/features/import_netflix/domain/netflix_csv.dart';

Uint8List fixture(String name) => File('test/fixtures/netflix/$name').readAsBytesSync();

void main() {
  group('tokenizeCsv', () {
    test('aspas, aspas escapadas, vírgula dentro do campo, CRLF e quebra dentro de aspas', () {
      final rows = tokenizeCsv('Title,Date\r\n"Eu, a Patroa",1/1/24\r\n"Ela disse ""sim""",2/1/24\n"linha\nquebrada",3/1/24\n');
      expect(rows, [
        ['Title', 'Date'],
        ['Eu, a Patroa', '1/1/24'],
        ['Ela disse "sim"', '2/1/24'],
        ['linha\nquebrada', '3/1/24'],
      ]);
    });

    test('última linha sem quebra e linhas vazias', () {
      expect(tokenizeCsv('a,b\n\n1,2'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
      expect(detectDelimiter('Title;Date\nx;y'), ';');
      expect(detectDelimiter('Title,Date\nx,y'), ',');
    });
  });

  group('decodeCsvBytes', () {
    test('tira o BOM e lê UTF-8', () {
      final text = decodeCsvBytes(fixture('simple_br.csv'));
      expect(text.startsWith('Title,Date'), isTrue);
      expect(text, contains('Capítulo'));
    });

    test('latin-1 como reserva', () {
      final text = decodeCsvBytes(fixture('latin1_semicolon.csv'));
      expect(text, contains('Minissérie'));
    });
  });

  group('datas', () {
    test('detecta dia-primeiro por um campo > 12', () {
      final r = detectDateOrder(['01/02/24', '15/07/24']);
      expect(r.order, DateOrder.dayFirst);
      expect(r.ambiguous, isFalse);
    });

    test('detecta mês-primeiro por um segundo campo > 12', () {
      final r = detectDateOrder(['7/15/24', '8/28/24']);
      expect(r.order, DateOrder.monthFirst);
      expect(r.ambiguous, isFalse);
    });

    test('sem prova assume dia-primeiro e marca ambíguo', () {
      final r = detectDateOrder(['05/06/24', '07/08/24']);
      expect(r.order, DateOrder.dayFirst);
      expect(r.ambiguous, isTrue);
    });

    test('ISO (exportação completa)', () {
      expect(detectDateOrder(['2024-07-15 23:31:02']).order, DateOrder.isoLike);
      expect(parseCsvDate('2024-07-15 23:31:02', DateOrder.isoLike), DateTime(2024, 7, 15));
      expect(parseCsvDate('2024-07-15', DateOrder.isoLike), DateTime(2024, 7, 15));
    });

    test('parseCsvDate: D/M/YY, M/D/YY, DD/MM/YYYY, inválidas', () {
      expect(parseCsvDate('15/07/24', DateOrder.dayFirst), DateTime(2024, 7, 15));
      expect(parseCsvDate('7/15/24', DateOrder.monthFirst), DateTime(2024, 7, 15));
      expect(parseCsvDate('15/07/2024', DateOrder.dayFirst), DateTime(2024, 7, 15));
      expect(parseCsvDate('15/07/24', DateOrder.monthFirst), DateTime(2024, 7, 15), reason: 'linha impossível na ordem escolhida inverte');
      expect(parseCsvDate('31/02/24', DateOrder.dayFirst), isNull);
      expect(parseCsvDate('ontem', DateOrder.dayFirst), isNull);
      expect(parseCsvDate('', DateOrder.dayFirst), isNull);
    });

    test('duração HH:MM:SS', () {
      expect(parseDurationSeconds('01:55:03'), 6903);
      expect(parseDurationSeconds('00:00:31'), 31);
      expect(parseDurationSeconds('x'), isNull);
    });
  });

  group('parseNetflixCsv', () {
    test('arquivo simples BR: BOM, aspas, D/M/YY, 22 linhas', () {
      final parsed = parseNetflixCsv(decodeCsvBytes(fixture('simple_br.csv')));
      expect(parsed.kind, CsvKind.simple);
      expect(parsed.rowsTotal, 22);
      expect(parsed.rows.length, 22);
      expect(parsed.skipped, 0);
      expect(parsed.dateOrder, DateOrder.dayFirst);
      expect(parsed.dateAmbiguous, isFalse);
      expect(parsed.profiles, isEmpty);
      expect(parsed.rows.first.title, 'Stranger Things: Temporada 4: Capítulo Nove: O Piggyback');
      expect(parsed.rows.first.watchedAt, DateTime(2024, 7, 15));
      expect(parsed.rows.map((r) => r.title), contains('Eu, a Patroa e as Crianças: Temporada 1: Piloto'));
      expect(parsed.rows.map((r) => r.title), contains('Ela disse "sim": Temporada 1: Episódio 1'));
    });

    test('arquivo simples US: M/D/YY', () {
      final parsed = parseNetflixCsv(decodeCsvBytes(fixture('simple_us.csv')));
      expect(parsed.dateOrder, DateOrder.monthFirst);
      expect(parsed.rows.first.watchedAt, DateTime(2024, 7, 15));
      expect(parsed.rows.last.watchedAt, DateTime(2021, 9, 19));
    });

    test('datas ambíguas: dia-primeiro com aviso', () {
      final parsed = parseNetflixCsv(decodeCsvBytes(fixture('ambiguous.csv')));
      expect(parsed.dateAmbiguous, isTrue);
      expect(parsed.rows.first.watchedAt, DateTime(2024, 6, 5));
    });

    test('ViewingActivity.csv: perfis, trailers e prévias curtas fora', () {
      final parsed = parseNetflixCsv(decodeCsvBytes(fixture('viewing_activity.csv')));
      expect(parsed.kind, CsvKind.fullExport);
      expect(parsed.rowsTotal, 6);
      expect(parsed.rows.length, 3);
      expect(parsed.skippedSupplemental, 2, reason: 'HOOK e TRAILER');
      expect(parsed.skippedShort, 1, reason: '1 min 10 s de Cobra Kai');
      expect(parsed.profiles, ['João', 'Vini']);
      expect(parsed.rowsFor('João').map((r) => r.title).toList(), [
        'Stranger Things: Temporada 4: Capítulo Nove: O Piggyback',
        'One Piece: East Blue: Eu sou Luffy!',
      ]);
      expect(parsed.rowsFor('Vini').single.title, 'Oppenheimer');
      expect(parsed.rowsFor('Vini').single.watchedAt, DateTime(2024, 7, 13));
      expect(parsed.rowsFor(null).length, 3);
    });

    test('latin-1 com ponto e vírgula', () {
      final parsed = parseNetflixCsv(decodeCsvBytes(fixture('latin1_semicolon.csv')));
      expect(parsed.rows.length, 2);
      expect(parsed.rows.first.title, 'Olhos que Condenam: Minissérie: Parte Um');
    });

    test('duas colunas sem cabeçalho ainda passam; cabeçalho estranho não', () {
      final parsed = parseNetflixCsv('Oppenheimer,28/08/24\nDuna,30/08/24\n');
      expect(parsed.rows.length, 2);
      expect(() => parseNetflixCsv('Nome,Quando,Onde\nx,y,z\n'), throwsA(isA<NetflixCsvFormatException>()));
      expect(() => parseNetflixCsv(''), throwsA(isA<NetflixCsvFormatException>()));
    });

    test('linha sem data ou sem título é contada como não lida, não derruba o arquivo', () {
      final parsed = parseNetflixCsv('Title,Date\nOppenheimer,\n,28/08/24\nDuna,30/08/24\n');
      expect(parsed.rows.length, 1);
      expect(parsed.skippedUnparsable, 2);
      expect(parsed.rowsTotal, 3);
    });
  });
}
