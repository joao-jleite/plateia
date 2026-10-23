import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../domain/renewal.dart';
import '../domain/subscribe_models.dart';

/// Um lembrete agendado (para a tela e os testes conferirem).
@immutable
class ScheduledReminder {
  const ScheduledReminder({required this.providerId, required this.at, required this.title, required this.body});

  final int providerId;
  final DateTime at;
  final String title;
  final String body;
}

/// Lembrete de cancelamento (SPEC §5.9): notificação **local**, 3 dias antes
/// de `renews_on`, só com `remind_before_renewal`. Sem servidor: o aparelho
/// agenda e dispara. Interface para a implementação real
/// ([LocalReminderScheduler]) e a dos testes ([RecordingReminderScheduler]).
abstract class ReminderScheduler {
  /// Android 13+: pede `POST_NOTIFICATIONS`. True quando pode notificar.
  Future<bool> ensurePermission();

  /// Deixa o aparelho com exatamente os lembretes de [subscriptions]: agenda
  /// (ou reagenda) quem tem data e chave ligada, cancela o resto.
  Future<void> sync(List<UserSubscription> subscriptions, {DateTime? now});

  /// Dispara um lembrete de exemplo agora (botão "Testar lembrete").
  Future<void> showTest({required String providerName, required int priceCents, required DateTime renewsOn});

  Future<List<ScheduledReminder>> pending();
}

/// Texto do lembrete: direto, com valor e data, sem jargão.
({String title, String body}) reminderText({
  required String providerName,
  required int? priceCents,
  required DateTime renewsOn,
}) {
  final price = priceCents == null ? '' : ' de ${formatBrl(priceCents)}';
  return (
    title: '$providerName renova em $reminderDaysBefore dias',
    body: 'A cobrança$price cai em ${shortDatePtBr(renewsOn)}. Se não vai usar este mês, cancele antes.',
  );
}

/// Implementação com `flutter_local_notifications`.
///
/// Decisões (CLAUDE.md, fase 07): agendamento **inexato** (`inexactAllowWhileIdle`):
/// um aviso de "renova em 3 dias" não precisa de minuto certo, e o modo exato
/// exige a permissão `SCHEDULE_EXACT_ALARM`, que a Play audita. O id da
/// notificação é o `provider_id`: reagendar sobrescreve, cancelar é direto.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({this.onTap});

  /// Toque na notificação: a app leva para Meus streamings (payload = rota).
  final void Function(String route)? onTap;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const channel = AndroidNotificationChannel(
    'renewals',
    'Lembretes de renovação',
    description: 'Aviso 3 dias antes de um streaming renovar.',
    importance: Importance.high,
  );

  static const route = '/subscribe/mine';

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      // sem fuso do aparelho, fica em UTC: o lembrete toca algumas horas fora
      // do planejado, mas toca
      debugPrint('[reminders] fuso local indisponível ($e); usando UTC');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) onTap?.call(payload);
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _ready = true;
  }

  @override
  Future<bool> ensurePermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    // Android < 13 não tem a permissão em tempo de execução: devolve true
    final granted = await android.requestNotificationsPermission();
    return granted ?? true;
  }

  NotificationDetails get _details => NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
      );

  @override
  Future<void> sync(List<UserSubscription> subscriptions, {DateTime? now}) async {
    await _init();
    final current = now ?? DateTime.now();
    final wanted = <int>{};
    for (final s in subscriptions) {
      if (!s.wantsReminder) continue;
      wanted.add(s.providerId);
      final when = reminderMoment(s.renewsOn!, current);
      final text = reminderText(
        providerName: s.provider?.name ?? 'Seu streaming',
        priceCents: s.priceCents,
        renewsOn: nextRenewal(s.renewsOn!, current),
      );
      try {
        await _plugin.zonedSchedule(
          id: s.providerId,
          title: text.title,
          body: text.body,
          scheduledDate: tz.TZDateTime.from(when, tz.local),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: route,
        );
      } catch (e) {
        // sem permissão ou plataforma sem suporte: a tela já avisou; não derruba a gravação
        debugPrint('[reminders] falha ao agendar ${s.providerId}: $e');
      }
    }
    // o que não tem mais lembrete sai do aparelho
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (!wanted.contains(p.id)) await _plugin.cancel(id: p.id);
    }
  }

  @override
  Future<void> showTest({required String providerName, required int priceCents, required DateTime renewsOn}) async {
    await _init();
    final text = reminderText(providerName: providerName, priceCents: priceCents, renewsOn: renewsOn);
    // id fora da faixa dos provider_id para não apagar um lembrete real
    await _plugin.show(id: 0, title: text.title, body: text.body, notificationDetails: _details, payload: route);
  }

  @override
  Future<List<ScheduledReminder>> pending() async {
    await _init();
    final list = await _plugin.pendingNotificationRequests();
    // o plugin não devolve a data: a tela recalcula pela assinatura
    return [for (final p in list) ScheduledReminder(providerId: p.id, at: DateTime(0), title: p.title ?? '', body: p.body ?? '')];
  }
}

/// Para testes e para o backend de fixtures em plataformas sem notificação:
/// guarda o que foi agendado em memória.
class RecordingReminderScheduler implements ReminderScheduler {
  RecordingReminderScheduler({this.permissionGranted = true});

  bool permissionGranted;
  int permissionRequests = 0;
  final scheduled = <int, ScheduledReminder>{};
  final shownTests = <String>[];

  @override
  Future<bool> ensurePermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<void> sync(List<UserSubscription> subscriptions, {DateTime? now}) async {
    final current = now ?? DateTime.now();
    scheduled.clear();
    for (final s in subscriptions) {
      if (!s.wantsReminder) continue;
      final text = reminderText(
        providerName: s.provider?.name ?? 'Seu streaming',
        priceCents: s.priceCents,
        renewsOn: nextRenewal(s.renewsOn!, current),
      );
      scheduled[s.providerId] = ScheduledReminder(
        providerId: s.providerId,
        at: reminderMoment(s.renewsOn!, current),
        title: text.title,
        body: text.body,
      );
    }
  }

  @override
  Future<void> showTest({required String providerName, required int priceCents, required DateTime renewsOn}) async {
    shownTests.add(reminderText(providerName: providerName, priceCents: priceCents, renewsOn: renewsOn).title);
  }

  @override
  Future<List<ScheduledReminder>> pending() async => scheduled.values.toList();
}
