import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/utils/clock.dart';
import 'package:watchlog/features/subscribe/data/reminder_scheduler.dart';
import 'package:watchlog/features/subscribe/domain/renewal.dart';
import 'package:watchlog/features/subscribe/presentation/my_subscriptions_screen.dart';

import '../../../helpers/pump_app.dart';

final clockOverride = clockProvider.overrideWithValue(() => DateTime(2026, 10, 23, 12));

void main() {
  testWidgets('resumo: quanto pago, economia no ano contra o recomendado; lembretes sincronizados ao abrir', (tester) async {
    // amostra: Netflix Padrão (44,90, renova em 10 dias) + Prime (19,90, renova em 21 dias) = 64,80/mês;
    // recomendado HBO Max 39,90 → (64,80 − 39,90) × 12 = R$ 298,80
    final scheduler = RecordingReminderScheduler();
    await pumpScreen(tester, const MySubscriptionsScreen(), scheduler: scheduler, overrides: [clockOverride]);
    await tester.pumpAndSettle();

    expect(find.text('Você paga R\$ 64,80 por mês'), findsOneWidget);
    expect(find.text('R\$ 777,60 por ano em 2 streamings'), findsOneWidget);
    expect(find.textContaining('Economia estimada no ano: R\$ 298,80'), findsOneWidget);
    expect(find.textContaining('HBO Max por R\$ 39,90'), findsOneWidget);
    expect(find.textContaining('Renova em 10 dias'), findsOneWidget);
    expect(find.textContaining('lembrete 3 dias antes'), findsNWidgets(2));

    // dois lembretes agendados: 7 dias antes de hoje+10 e hoje+21, às 10h
    expect(scheduler.scheduled.keys, containsAll([8, 119]));
    final netflix = scheduler.scheduled[8]!;
    expect(netflix.title, 'Netflix renova em 3 dias');
    expect(netflix.body, startsWith('A cobrança de R\$ 44,90 cai em'), reason: 'sem preço informado, vale o de tabela');
    final today = DateTime.now();
    final expected = DateTime(today.year, today.month, today.day).add(const Duration(days: 10 - reminderDaysBefore));
    expect(netflix.at, DateTime(expected.year, expected.month, expected.day, reminderHour));
  });

  testWidgets('marcar um streaming abre a folha; salvar grava, pede permissão e agenda o lembrete', (tester) async {
    final scheduler = RecordingReminderScheduler();
    await pumpScreen(tester, const MySubscriptionsScreen(), scheduler: scheduler, overrides: [clockOverride]);
    await tester.pumpAndSettle();

    // a chave da HBO Max (4ª linha) está desligada
    final row = find.widgetWithText(ListTile, 'HBO Max');
    expect(tester.widget<Switch>(find.descendant(of: row, matching: find.byType(Switch))).value, isFalse);
    await tester.tap(find.descendant(of: row, matching: find.byType(Switch)));
    await tester.pumpAndSettle();

    expect(find.text('Plano'), findsOneWidget);
    expect(find.text('Tabela: R\$ 39,90. Deixe vazio para usar a tabela.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '34,90');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(find.descendant(of: row, matching: find.byType(Switch))).value, isTrue);
    expect(find.textContaining('R\$ 34,90/mês'), findsOneWidget, reason: 'o preço informado vence a tabela');
    expect(find.textContaining('HBO Max salvo. Lembrete em'), findsOneWidget);
    expect(scheduler.permissionRequests, 1);
    expect(scheduler.scheduled.containsKey(1899), isTrue);
    // a economia muda: 64,80 + 34,90 = 99,70 → (99,70 − 39,90) × 12 = 717,60
    expect(find.text('Você paga R\$ 99,70 por mês'), findsOneWidget);
    expect(find.textContaining('Economia estimada no ano: R\$ 717,60'), findsOneWidget);
  });

  testWidgets('sem permissão de notificação, salva mas avisa', (tester) async {
    final scheduler = RecordingReminderScheduler(permissionGranted: false);
    await pumpScreen(tester, const MySubscriptionsScreen(), scheduler: scheduler, overrides: [clockOverride]);
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.text('Crunchyroll'), find.byType(ListView), const Offset(0, -200));
    final row = find.widgetWithText(ListTile, 'Crunchyroll');
    await tester.tap(find.descendant(of: row, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('sem permissão para notificar'), findsOneWidget);
    expect(tester.widget<Switch>(find.descendant(of: row, matching: find.byType(Switch))).value, isTrue);
  });

  testWidgets('desmarcar remove com "Desfazer"; o lembrete sai do aparelho e volta', (tester) async {
    final scheduler = RecordingReminderScheduler();
    await pumpScreen(tester, const MySubscriptionsScreen(), scheduler: scheduler, overrides: [clockOverride]);
    await tester.pumpAndSettle();
    final row = find.widgetWithText(ListTile, 'Prime Video');
    await tester.tap(find.descendant(of: row, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    expect(find.text('Prime Video desmarcado.'), findsOneWidget);
    expect(find.text('Você paga R\$ 44,90 por mês'), findsOneWidget);
    expect(scheduler.scheduled.containsKey(119), isFalse);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(find.text('Você paga R\$ 64,80 por mês'), findsOneWidget);
    expect(scheduler.scheduled.containsKey(119), isTrue);
  });

  testWidgets('servidor recusa: a chave volta e o aviso aparece', (tester) async {
    await pumpScreen(tester, const MySubscriptionsScreen(), failWrites: true, overrides: [clockOverride]);
    await tester.pumpAndSettle();
    final row = find.widgetWithText(ListTile, 'Netflix');
    await tester.tap(find.descendant(of: row, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Não deu para salvar. Desfizemos.'), findsOneWidget);
    expect(tester.widget<Switch>(find.descendant(of: row, matching: find.byType(Switch))).value, isTrue);
    expect(find.text('Você paga R\$ 64,80 por mês'), findsOneWidget);
  });

  testWidgets('"Testar lembrete" dispara uma notificação de exemplo', (tester) async {
    final scheduler = RecordingReminderScheduler();
    await pumpScreen(tester, const MySubscriptionsScreen(), scheduler: scheduler, overrides: [clockOverride]);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Testar lembrete'));
    await tester.pumpAndSettle();
    expect(scheduler.shownTests, ['Netflix renova em 3 dias']);
    expect(find.text('Lembrete de teste enviado. Veja a barra de notificações.'), findsOneWidget);
  });

  testWidgets('preço inválido na folha não salva', (tester) async {
    await pumpScreen(tester, const MySubscriptionsScreen(), overrides: [clockOverride]);
    await tester.pumpAndSettle();
    final row = find.widgetWithText(ListTile, 'Disney+');
    await tester.tap(find.descendant(of: row, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Use um valor como 44,90.'), findsOneWidget);
    expect(find.text('Plano'), findsOneWidget, reason: 'a folha continua aberta');
  });
}
