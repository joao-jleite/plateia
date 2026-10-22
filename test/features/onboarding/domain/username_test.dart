import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/features/onboarding/domain/username.dart';

void main() {
  group(r'validateUsername (^[a-z0-9_]{3,20}$)', () {
    test('aceita os válidos, normalizando @ e maiúsculas', () {
      expect(validateUsername('foxer'), isNull);
      expect(validateUsername('@Foxer_123 '), isNull);
      expect(normalizeUsername('@Foxer_123 '), 'foxer_123');
    });

    test('rejeita curto, longo, acento e espaço', () {
      expect(validateUsername(''), 'Escolha um @.');
      expect(validateUsername('ab'), 'Pelo menos 3 caracteres.');
      expect(validateUsername('a' * 21), 'No máximo 20 caracteres.');
      expect(validateUsername('joão'), isNotNull);
      expect(validateUsername('ana souza'), isNotNull);
      expect(validateUsername('ana-souza'), isNotNull);
    });
  });

  group('suggestUsername', () {
    test('usa o nome, sem acento e com _', () {
      expect(suggestUsername('Ana Souza', 'x@y.com'), 'ana_souza');
      expect(suggestUsername('João Leite', null), 'joao_leite');
    });

    test('cai para o e-mail e corta em 20', () {
      expect(suggestUsername(null, 'joao.jleite3@gmail.com'), 'joao_jleite3');
      expect(suggestUsername('a' * 30, null).length, 20);
    });
  });
}
