import 'package:intl/intl.dart';

/// "há 3 dias", "há 2 horas", "agora". Para o "Atualizado há N dias" discreto
/// da seção Onde assistir (SPEC §5.7).
String relativePtBr(DateTime? when, {DateTime? now}) {
  if (when == null) return 'nunca';
  final diff = (now ?? DateTime.now()).difference(when.toLocal());
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inHours < 1) return 'há ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'há ${diff.inHours} h';
  if (diff.inDays == 1) return 'há 1 dia';
  if (diff.inDays < 30) return 'há ${diff.inDays} dias';
  final months = diff.inDays ~/ 30;
  return months == 1 ? 'há 1 mês' : 'há $months meses';
}

String shortDatePtBr(DateTime? date) =>
    date == null ? '' : DateFormat('dd/MM/yyyy', 'pt_BR').format(date);

/// "1h 45min" para filmes; "~45 min/ep" para séries.
String runtimeLabel({int? movieMinutes, int? episodeMinutes}) {
  if (movieMinutes != null && movieMinutes > 0) {
    final h = movieMinutes ~/ 60;
    final m = movieMinutes % 60;
    return h == 0 ? '$m min' : (m == 0 ? '${h}h' : '${h}h ${m}min');
  }
  if (episodeMinutes != null && episodeMinutes > 0) return '~$episodeMinutes min/ep';
  return '';
}

/// Centavos → "R$ 9,90".
String brl(int cents) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: r'R$').format(cents / 100);
