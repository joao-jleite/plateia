/// Leitura do CSV da Netflix (SPEC §5.8, docs/decisoes-apis.md "Formato do
/// CSV"). Puro: sem Flutter nem Supabase; roda num isolate via `compute`.
///
/// Dois formatos:
/// - `NetflixViewingHistory.csv` (Conta → Atividade de visualização → Baixar
///   tudo): cabeçalho `Title,Date`, uma linha por reprodução, data no locale
///   da conta (BR `D/M/YY`, US `M/D/YY`).
/// - `ViewingActivity.csv` da exportação completa (getmyinfo): `Profile Name,
///   Start Time, Duration, Attributes, Title, Supplemental Video Type, …`, com
///   todos os perfis e também trailers/prévias (filtrados aqui).
library;

import 'dart:convert';
import 'dart:typed_data';

enum CsvKind { simple, fullExport }

/// Como a data vem escrita. Decidido pelo conjunto, não linha a linha.
enum DateOrder { dayFirst, monthFirst, isoLike }

class ViewingRow {
  const ViewingRow({required this.title, required this.watchedAt, this.profile});

  final String title;

  /// Só a data (sem hora); no fuso em que a Netflix escreveu.
  final DateTime watchedAt;

  /// Perfil da conta (só a exportação completa informa).
  final String? profile;
}

class ParsedCsv {
  const ParsedCsv({
    required this.kind,
    required this.rows,
    required this.rowsTotal,
    required this.dateOrder,
    required this.dateAmbiguous,
    this.profiles = const [],
    this.skippedSupplemental = 0,
    this.skippedShort = 0,
    this.skippedUnparsable = 0,
  });

  final CsvKind kind;
  final List<ViewingRow> rows;

  /// Linhas de dado no arquivo (sem o cabeçalho), antes dos filtros.
  final int rowsTotal;
  final DateOrder dateOrder;

  /// Nenhum campo > 12 no arquivo: assumimos dia-primeiro (conta BR) e avisamos.
  final bool dateAmbiguous;

  /// Perfis distintos (exportação completa). Vazio no arquivo simples.
  final List<String> profiles;
  final int skippedSupplemental;
  final int skippedShort;
  final int skippedUnparsable;

  int get skipped => skippedSupplemental + skippedShort + skippedUnparsable;

  /// Linhas de um perfil (ou todas, se `profile` for null / arquivo simples).
  List<ViewingRow> rowsFor(String? profile) =>
      profile == null ? rows : rows.where((r) => r.profile == profile).toList();
}

class NetflixCsvFormatException implements Exception {
  const NetflixCsvFormatException(this.message);

  final String message;

  @override
  String toString() => 'NetflixCsvFormatException: $message';
}

// ────────────────────────────────────────────────────────────────────────────
// Bytes → texto
// ────────────────────────────────────────────────────────────────────────────

/// UTF-8 (com ou sem BOM); se não for UTF-8 válido, latin-1.
String decodeCsvBytes(Uint8List bytes) {
  var start = 0;
  if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) start = 3;
  final view = Uint8List.sublistView(bytes, start);
  try {
    return utf8.decode(view, allowMalformed: false);
  } on FormatException {
    return latin1.decode(view);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Texto → células (RFC 4180: aspas, aspas duplas escapadas, quebra de linha
// dentro de aspas, CRLF)
// ────────────────────────────────────────────────────────────────────────────

List<List<String>> tokenizeCsv(String text, {String delimiter = ','}) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  final n = text.length;
  var i = 0;
  // o BOM pode ter sobrevivido se o texto veio de outro lugar
  if (n > 0 && text.codeUnitAt(0) == 0xFEFF) i = 1;

  void endCell() {
    row.add(cell.toString());
    cell.clear();
  }

  void endRow() {
    endCell();
    // linha totalmente vazia (ex.: a última) não conta
    if (row.length > 1 || row.first.trim().isNotEmpty) rows.add(row);
    row = <String>[];
  }

  while (i < n) {
    final ch = text[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < n && text[i + 1] == '"') {
          cell.write('"');
          i += 2;
          continue;
        }
        inQuotes = false;
        i++;
        continue;
      }
      cell.write(ch);
      i++;
      continue;
    }
    if (ch == '"') {
      inQuotes = true;
      i++;
    } else if (ch == delimiter) {
      endCell();
      i++;
    } else if (ch == '\r') {
      if (i + 1 < n && text[i + 1] == '\n') i++;
      endRow();
      i++;
    } else if (ch == '\n') {
      endRow();
      i++;
    } else {
      cell.write(ch);
      i++;
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

/// `;` só se o cabeçalho não tiver vírgula (planilha regravada em pt-BR).
String detectDelimiter(String text) {
  final firstLine = text.split(RegExp(r'\r?\n')).first;
  if (!firstLine.contains(',') && firstLine.contains(';')) return ';';
  if (!firstLine.contains(',') && !firstLine.contains(';') && firstLine.contains('\t')) return '\t';
  return ',';
}

// ────────────────────────────────────────────────────────────────────────────
// Datas
// ────────────────────────────────────────────────────────────────────────────

final _isoLike = RegExp(r'^\d{4}-\d{1,2}-\d{1,2}');
final _threeParts = RegExp(r'^\s*(\d{1,4})[/.\-](\d{1,2})[/.\-](\d{1,4})');

/// Decide dia-primeiro ou mês-primeiro pelo arquivo inteiro: qualquer primeiro
/// campo > 12 prova dia-primeiro; qualquer segundo campo > 12 prova mês-primeiro.
({DateOrder order, bool ambiguous}) detectDateOrder(Iterable<String> rawDates) {
  var iso = 0, slash = 0, firstOver12 = false, secondOver12 = false;
  for (final raw in rawDates) {
    final t = raw.trim();
    if (_isoLike.hasMatch(t)) {
      iso++;
      continue;
    }
    final m = _threeParts.firstMatch(t);
    if (m == null) continue;
    slash++;
    final a = int.parse(m.group(1)!);
    final b = int.parse(m.group(2)!);
    if (a > 12 && a <= 31) firstOver12 = true;
    if (b > 12 && b <= 31) secondOver12 = true;
  }
  if (iso > slash) return (order: DateOrder.isoLike, ambiguous: false);
  if (firstOver12 && !secondOver12) return (order: DateOrder.dayFirst, ambiguous: false);
  if (secondOver12 && !firstOver12) return (order: DateOrder.monthFirst, ambiguous: false);
  // os dois ou nenhum: conta BR é a maioria dos nossos usuários; avisamos
  return (order: DateOrder.dayFirst, ambiguous: true);
}

/// `15/07/24`, `7/15/2024`, `2024-07-15 20:31:02` → data (sem hora). Null se inválida.
DateTime? parseCsvDate(String raw, DateOrder order) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (_isoLike.hasMatch(t)) {
    final parsed = DateTime.tryParse(t.length > 10 ? t.replaceFirst(' ', 'T') : t);
    return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
  }
  final m = _threeParts.firstMatch(t);
  if (m == null) return null;
  var a = int.parse(m.group(1)!);
  var b = int.parse(m.group(2)!);
  var c = int.parse(m.group(3)!);
  int day, month, year;
  if (a > 31) {
    // 2024/07/15
    year = a;
    month = b;
    day = c;
  } else {
    year = c < 100 ? 2000 + c : c;
    if (order == DateOrder.monthFirst) {
      month = a;
      day = b;
    } else {
      day = a;
      month = b;
    }
    // escapatória linha a linha: se a ordem escolhida for impossível, inverte
    if (month > 12 && day <= 12) {
      final tmp = month;
      month = day;
      day = tmp;
    }
  }
  if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1997 || year > 2100) return null;
  final d = DateTime(year, month, day);
  if (d.month != month) return null; // 31/02
  return d;
}

/// `HH:MM:SS` → segundos (Duration da exportação completa).
int? parseDurationSeconds(String raw) {
  final parts = raw.trim().split(':');
  if (parts.length != 3) return null;
  final h = int.tryParse(parts[0]), m = int.tryParse(parts[1]), s = int.tryParse(parts[2]);
  if (h == null || m == null || s == null) return null;
  return h * 3600 + m * 60 + s;
}

// ────────────────────────────────────────────────────────────────────────────
// Parser
// ────────────────────────────────────────────────────────────────────────────

/// Prévias e trailers autoexecutados: abaixo disto a linha não conta como
/// "assistiu" (só a exportação completa tem duração).
const minWatchSeconds = 120;

ParsedCsv parseNetflixCsv(String text) {
  final cells = tokenizeCsv(text, delimiter: detectDelimiter(text));
  if (cells.isEmpty) throw const NetflixCsvFormatException('O arquivo está vazio.');

  final header = cells.first.map((h) => h.trim().toLowerCase()).toList();
  int idx(String name) => header.indexOf(name);
  final body = cells.skip(1).toList();

  // --- arquivo simples: Title,Date ------------------------------------------
  final titleIdx = idx('title');
  final dateIdx = idx('date');
  final startIdx = idx('start time');
  if (titleIdx >= 0 && dateIdx >= 0 && startIdx < 0) {
    return _parseSimple(body, titleIdx: titleIdx, dateIdx: dateIdx);
  }

  // --- exportação completa: ViewingActivity.csv ------------------------------
  if (titleIdx >= 0 && startIdx >= 0) {
    return _parseFull(
      body,
      titleIdx: titleIdx,
      startIdx: startIdx,
      profileIdx: idx('profile name'),
      durationIdx: idx('duration'),
      supplementalIdx: idx('supplemental video type'),
    );
  }

  // --- sem cabeçalho reconhecível, mas com 2 colunas (título, data) ---------
  if (header.length == 2 && parseCsvDate(cells.first[1], DateOrder.dayFirst) != null) {
    return _parseSimple(cells, titleIdx: 0, dateIdx: 1);
  }

  throw const NetflixCsvFormatException(
    'Cabeçalho não reconhecido. Esperado "Title,Date" (NetflixViewingHistory.csv) '
    'ou o ViewingActivity.csv da exportação completa da Netflix.',
  );
}

ParsedCsv _parseSimple(List<List<String>> body, {required int titleIdx, required int dateIdx}) {
  final valid = body.where((r) => r.length > titleIdx && r.length > dateIdx).toList();
  final detected = detectDateOrder(valid.map((r) => r[dateIdx]));
  final rows = <ViewingRow>[];
  var unparsable = body.length - valid.length;
  for (final r in valid) {
    final title = r[titleIdx].trim();
    final date = parseCsvDate(r[dateIdx], detected.order);
    if (title.isEmpty || date == null) {
      unparsable++;
      continue;
    }
    rows.add(ViewingRow(title: title, watchedAt: date));
  }
  return ParsedCsv(
    kind: CsvKind.simple,
    rows: rows,
    rowsTotal: body.length,
    dateOrder: detected.order,
    dateAmbiguous: detected.ambiguous,
    skippedUnparsable: unparsable,
  );
}

ParsedCsv _parseFull(
  List<List<String>> body, {
  required int titleIdx,
  required int startIdx,
  required int profileIdx,
  required int durationIdx,
  required int supplementalIdx,
}) {
  final rows = <ViewingRow>[];
  final profiles = <String>{};
  var supplemental = 0, short = 0, unparsable = 0;
  String? cell(List<String> r, int i) => (i >= 0 && i < r.length) ? r[i].trim() : null;
  for (final r in body) {
    final title = cell(r, titleIdx) ?? '';
    final start = cell(r, startIdx) ?? '';
    final date = parseCsvDate(start, DateOrder.isoLike);
    if (title.isEmpty || date == null) {
      unparsable++;
      continue;
    }
    final profile = cell(r, profileIdx);
    if (profile != null && profile.isNotEmpty) profiles.add(profile);
    // trailers, prévias, resumos ("HOOK", "TRAILER", "TEASER_TRAILER", "RECAP"…)
    final supp = cell(r, supplementalIdx) ?? '';
    if (supp.isNotEmpty) {
      supplemental++;
      continue;
    }
    final seconds = parseDurationSeconds(cell(r, durationIdx) ?? '');
    if (seconds != null && seconds < minWatchSeconds) {
      short++;
      continue;
    }
    rows.add(ViewingRow(title: title, watchedAt: date, profile: profile?.isEmpty ?? true ? null : profile));
  }
  final sortedProfiles = profiles.toList()..sort();
  return ParsedCsv(
    kind: CsvKind.fullExport,
    rows: rows,
    rowsTotal: body.length,
    dateOrder: DateOrder.isoLike,
    dateAmbiguous: false,
    profiles: sortedProfiles,
    skippedSupplemental: supplemental,
    skippedShort: short,
    skippedUnparsable: unparsable,
  );
}
