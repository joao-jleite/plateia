// Ensaio da importação da Netflix SEM servidor: lê um CSV real, roda o mesmo
// parser e agrupador do app (features/import_netflix/domain) e imprime só
// contagens: linhas, grupos, padrões de título, incertos, ordem das datas.
// Nenhum nome de título sai, a menos que você peça com --names (fica no seu
// terminal; nada é gravado). Serve para medir a metade "no aparelho" da
// importação antes de o projeto Supabase existir; a % de casamento de verdade
// aparece no resumo do app ("N títulos importados, M para revisar").
//
// Uso (na raiz do repo):
//   dart run tool/import_dry_run.dart research/NetflixViewingHistory.csv
//   dart run tool/import_dry_run.dart caminho/ViewingActivity.csv --profile "João" --names
//
// Pré-requisito: `flutter pub get` já rodado (usa package:crypto do pubspec).

import 'dart:io';

import 'package:watchlog/features/import_netflix/domain/grouper.dart';
import 'package:watchlog/features/import_netflix/domain/import_pipeline.dart';
import 'package:watchlog/features/import_netflix/domain/netflix_csv.dart';
import 'package:watchlog/features/import_netflix/domain/title_patterns.dart';

void main(List<String> args) {
  if (args.isEmpty || args.first.startsWith('--')) {
    stderr.writeln('Uso: dart run tool/import_dry_run.dart <arquivo.csv> [--profile "Nome"] [--names]');
    exit(64);
  }
  final file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('Arquivo não encontrado: ${file.path}');
    exit(66);
  }
  final showNames = args.contains('--names');
  final profileIdx = args.indexOf('--profile');
  final profile = profileIdx >= 0 && profileIdx + 1 < args.length ? args[profileIdx + 1] : null;

  final PreparedCsv prepared;
  try {
    prepared = prepareCsv(PrepareCsvInput(bytes: file.readAsBytesSync(), fileName: file.uri.pathSegments.last));
  } on NetflixCsvFormatException catch (e) {
    stderr.writeln('Formato não reconhecido: ${e.message}');
    exit(65);
  }
  final p = prepared.parsed;
  final rows = p.rowsFor(profile);
  final groups = groupRows(rows);

  final kinds = <TitleKind, int>{};
  for (final r in rows) {
    final k = parseTitle(r.title).kind;
    kinds[k] = (kinds[k] ?? 0) + 1;
  }
  final tv = groups.where((g) => g.guessedType?.name == 'tv').length;
  final movie = groups.where((g) => g.guessedType?.name == 'movie').length;
  final uncertain = groups.where((g) => g.isUncertain).length;
  final first = groups.isEmpty ? null : groups.map((g) => g.firstWatchedAt).reduce((a, b) => a.isBefore(b) ? a : b);
  final last = groups.isEmpty ? null : groups.map((g) => g.lastWatchedAt).reduce((a, b) => a.isAfter(b) ? a : b);

  stdout
    ..writeln('Arquivo: ${prepared.fileName} · sha-256 ${prepared.fileHash.substring(0, 12)}…')
    ..writeln('Formato: ${p.kind == CsvKind.simple ? 'NetflixViewingHistory.csv (Title,Date)' : 'ViewingActivity.csv (exportação completa)'}')
    ..writeln('Datas: ${p.dateOrder.name}${p.dateAmbiguous ? ' (AMBÍGUO: nenhum campo > 12; assumido dia-primeiro)' : ''}'
        '${first == null ? '' : ' · de ${_d(first)} a ${_d(last!)}'}')
    ..writeln('Linhas: ${p.rowsTotal} no arquivo · ${rows.length} válidas${profile == null ? '' : ' no perfil "$profile"'} · '
        '${p.skippedSupplemental} trailers/prévias · ${p.skippedShort} curtas (< 2 min) · ${p.skippedUnparsable} sem data/título')
    ..writeln(p.profiles.isEmpty ? '' : 'Perfis: ${p.profiles.join(', ')}${profile == null ? '  ← use --profile para filtrar' : ''}')
    ..writeln('Padrões de título (por linha):')
    ..writeln('  ${kinds.entries.map((e) => '${e.key.name}=${e.value}').join('  ')}')
    ..writeln('Grupos (o que vai para import-match): ${groups.length} · séries $tv · filmes $movie · incertos $uncertain '
        '· ${(groups.length / 100).ceil()} chamadas de até 100')
    ..writeln('Episódios distintos somados: ${groups.fold<int>(0, (s, g) => s + (g.guessedType?.name == 'tv' ? g.episodesCount : 0))}');

  if (showNames) {
    stdout.writeln('\nGrupos (mais recente primeiro) — só no seu terminal:');
    for (final g in groups) {
      stdout.writeln('  ${g.guessedType?.name.padRight(5) ?? '?    '} ${g.rawName}'
          '${g.guessedType?.name == 'tv' ? ' · ${g.episodesCount} ep' : ''} · último ${_d(g.lastWatchedAt)}'
          '${g.altQuery != null ? ' · alt: ${g.altQuery}' : ''}');
    }
  }
  stdout.writeln('\nPróximo passo: importe este arquivo no app com o projeto Supabase ligado; o resumo mostra '
      '"N títulos importados, M para revisar" → casamento automático = N / (N + M). Meta ≥ 90%.');
}

String _d(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
