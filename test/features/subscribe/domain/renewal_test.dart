import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/utils/money.dart';
import 'package:watchlog/features/subscribe/domain/recommender.dart';
import 'package:watchlog/features/subscribe/domain/renewal.dart';
import 'package:watchlog/features/subscribe/domain/subscribe_models.dart';

void main() {
  final today = DateTime(2026, 10, 23);

  group('nextRenewal', () {
    test('data futura ou hoje fica como está', () {
      expect(nextRenewal(DateTime(2026, 11, 2), today), DateTime(2026, 11, 2));
      expect(nextRenewal(DateTime(2026, 10, 23), today), DateTime(2026, 10, 23));
    });

    test('data passada avança mês a mês até hoje ou depois', () {
      expect(nextRenewal(DateTime(2026, 9, 10), today), DateTime(2026, 11, 10));
      expect(nextRenewal(DateTime(2026, 1, 23), today), DateTime(2026, 10, 23), reason: 'cai em hoje');
      expect(nextRenewal(DateTime(2025, 12, 5), today), DateTime(2026, 11, 5));
    });

    test('dia 31 encurta no mês de 30 e volta a 31 depois', () {
      expect(nextRenewal(DateTime(2026, 8, 31), DateTime(2026, 9, 1)), DateTime(2026, 9, 30));
      expect(nextRenewal(DateTime(2026, 8, 31), DateTime(2026, 10, 1)), DateTime(2026, 10, 31));
      expect(nextRenewal(DateTime(2026, 1, 31), DateTime(2026, 2, 1)), DateTime(2026, 2, 28));
    });
  });

  group('reminderMoment', () {
    test('3 dias antes, às 10h', () {
      final now = DateTime(2026, 10, 23, 15, 30);
      expect(reminderMoment(DateTime(2026, 11, 2), now), DateTime(2026, 10, 30, 10));
    });

    test('renovação em menos de 3 dias: toca daqui a 1 minuto (atrasado é melhor que nenhum)', () {
      final now = DateTime(2026, 10, 23, 15, 30);
      expect(reminderMoment(DateTime(2026, 10, 25), now), now.add(const Duration(minutes: 1)));
      expect(reminderMoment(DateTime(2026, 10, 26), now), now.add(const Duration(minutes: 1)), reason: '23/10 10h já passou');
      expect(reminderMoment(DateTime(2026, 10, 27), now), DateTime(2026, 10, 24, 10));
    });

    test('renovação passada usa a projetada', () {
      final now = DateTime(2026, 10, 23, 8);
      // 10/09 → próxima 10/11 → lembrete 07/11 10h
      expect(reminderMoment(DateTime(2026, 9, 10), now), DateTime(2026, 11, 7, 10));
    });
  });

  test('renewalLabel', () {
    expect(renewalLabel(DateTime(2026, 10, 23), today), 'Renova hoje');
    expect(renewalLabel(DateTime(2026, 10, 24), today), 'Renova amanhã');
    expect(renewalLabel(DateTime(2026, 11, 2), today), 'Renova em 10 dias');
    expect(renewalLabel(DateTime(2026, 9, 25), today), 'Renova em 2 dias', reason: '25/09 → 25/10');
  });

  group('economia no ano', () {
    final prices = [
      ProviderPrice(providerId: 8, plan: PricePlan.standard, planLabel: 'Padrão', priceCents: 4490, updatedAt: today),
      ProviderPrice(providerId: 8, plan: PricePlan.ads, planLabel: 'Com anúncios', priceCents: 2090, updatedAt: today),
      ProviderPrice(providerId: 1899, plan: PricePlan.standard, planLabel: 'Padrão', priceCents: 3990, updatedAt: today),
      ProviderPrice(providerId: 283, plan: PricePlan.premium, planLabel: 'Mega Fan', priceCents: 2299, updatedAt: today),
    ];
    const netflix = UserSubscription(userId: 'me', providerId: 8, plan: PricePlan.ads);
    const max = UserSubscription(userId: 'me', providerId: 1899, priceCents: 3490); // o que ela paga de fato
    const crunchy = UserSubscription(userId: 'me', providerId: 283); // sem plano: padrão não existe → o mais barato

    test('preço informado vence o de tabela; plano escolhido; sem plano cai no padrão ou no mais barato', () {
      expect(monthlyPriceFor(netflix, prices), 2090);
      expect(monthlyTotalCents([netflix, max, crunchy], prices), 2090 + 3490 + 2299);
    });

    test('tudo o que marquei × 12 contra o recomendado × 12', () {
      // (2090 + 3490 + 2299) = 7879/mês; recomendado HBO Max 3990 → (7879 − 3990) × 12 = 46.668
      expect(yearlySavingsCents(mine: [netflix, max, crunchy], prices: prices, recommendedMonthlyCents: 3990), 46668);
      expect(formatBrl(46668), 'R\$ 466,68');
      // só a Crunchyroll e o recomendado custa mais: negativo
      expect(yearlySavingsCents(mine: [crunchy], prices: prices, recommendedMonthlyCents: 3990), (2299 - 3990) * 12);
      expect(yearlySavingsCents(mine: const [], prices: prices, recommendedMonthlyCents: 3990), isNull);
      expect(yearlySavingsCents(mine: [netflix], prices: prices, recommendedMonthlyCents: null), isNull);
    });
  });

  test('parseBrlCents', () {
    expect(parseBrlCents('44,90'), 4490);
    expect(parseBrlCents('R\$ 44,90'), 4490);
    expect(parseBrlCents('44.9'), 4490);
    expect(parseBrlCents('1.234,56'), 123456);
    expect(parseBrlCents('1.234'), 123400, reason: 'ponto com três dígitos é milhar');
    expect(parseBrlCents('20'), 2000);
    expect(parseBrlCents(''), isNull);
    expect(parseBrlCents('abc'), isNull);
  });

  test('formatBrl', () {
    expect(formatBrl(0), 'R\$ 0,00');
    expect(formatBrl(499), 'R\$ 4,99');
    expect(formatBrl(3990), 'R\$ 39,90');
    expect(formatBrl(123456789), 'R\$ 1.234.567,89');
    expect(formatBrl(-2000), '-R\$ 20,00');
  });
}
