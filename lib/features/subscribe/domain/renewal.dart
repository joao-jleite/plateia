// Datas do lembrete de cancelamento (SPEC §5.9). Puro; o agendamento de
// verdade (flutter_local_notifications) fica em `data/reminder_scheduler.dart`.

/// Quantos dias antes da renovação o lembrete toca.
const reminderDaysBefore = 3;

/// Hora local do lembrete (10h: a pessoa está acordada e dá tempo de cancelar).
const reminderHour = 10;

/// Quanto depois de "agora" entra o lembrete atrasado (renovação em menos de 3 dias).
const reminderCatchUpDelay = Duration(minutes: 1);

/// Próxima renovação a partir da data informada: assinatura renova todo mês,
/// então uma `renews_on` no passado avança mês a mês até hoje ou depois,
/// mantendo o dia (31/01 → 28/02 → 31/03…). A data no banco não muda; só a
/// tela e o lembrete usam a projetada.
DateTime nextRenewal(DateTime renewsOn, DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  var next = DateTime(renewsOn.year, renewsOn.month, renewsOn.day);
  if (!next.isBefore(day)) return next;
  // dia original, para não "perder" o 31 depois de passar por um mês de 30
  final anchorDay = renewsOn.day;
  var months = 0;
  while (next.isBefore(day)) {
    months++;
    next = _addMonths(DateTime(renewsOn.year, renewsOn.month, 1), months, anchorDay);
  }
  return next;
}

DateTime _addMonths(DateTime firstOfMonth, int months, int anchorDay) {
  final y = firstOfMonth.year + (firstOfMonth.month - 1 + months) ~/ 12;
  final m = (firstOfMonth.month - 1 + months) % 12 + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, anchorDay > lastDay ? lastDay : anchorDay);
}

/// Quando o lembrete deve tocar: 3 dias antes da próxima renovação, às 10h.
/// Se esse momento já passou (a pessoa marcou uma renovação para daqui a 2
/// dias), toca daqui a 1 minuto: melhor um aviso atrasado do que nenhum.
DateTime reminderMoment(DateTime renewsOn, DateTime now) {
  final next = nextRenewal(renewsOn, now);
  final planned = DateTime(next.year, next.month, next.day - reminderDaysBefore, reminderHour);
  return planned.isAfter(now) ? planned : now.add(reminderCatchUpDelay);
}

/// "Renova em 12 dias", "Renova amanhã", "Renova hoje".
String renewalLabel(DateTime renewsOn, DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  final next = nextRenewal(renewsOn, day);
  final days = next.difference(day).inDays;
  return switch (days) {
    0 => 'Renova hoje',
    1 => 'Renova amanhã',
    _ => 'Renova em $days dias',
  };
}
