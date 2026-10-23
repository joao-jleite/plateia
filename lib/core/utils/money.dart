/// Centavos → "R$ 1.234,56", sem `intl` (o `NumberFormat` do pt_BR separa o
/// símbolo com um espaço fixo U+00A0, que quebra comparação de texto nos
/// testes e não ajuda em nada na tela). Pura: serve ao domínio e à interface.
String formatBrl(int cents) {
  final negative = cents < 0;
  final abs = cents.abs();
  final reais = abs ~/ 100;
  final centavos = (abs % 100).toString().padLeft(2, '0');
  final digits = reais.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    // ponto de milhar a cada 3 dígitos contados da direita
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}R\$ $buffer,$centavos';
}

/// "44,90", "R$ 44,90", "44.9", "1.234,56" → centavos. Null se não for número.
/// Aceita vírgula ou ponto como decimal; o separador de milhar é descartado.
int? parseBrlCents(String raw) {
  var s = raw.trim().replaceAll(RegExp(r'[^\d,.\-]'), '');
  if (s.isEmpty) return null;
  final negative = s.startsWith('-');
  s = s.replaceAll('-', '');
  // último separador é o decimal; os anteriores são milhar
  final lastComma = s.lastIndexOf(',');
  final lastDot = s.lastIndexOf('.');
  final decimalAt = lastComma > lastDot ? lastComma : lastDot;
  String intPart;
  String fracPart;
  if (decimalAt < 0) {
    intPart = s;
    fracPart = '';
  } else {
    intPart = s.substring(0, decimalAt);
    fracPart = s.substring(decimalAt + 1);
    // "1.234" sem vírgula: ponto com três dígitos depois é milhar, não decimal
    if (fracPart.length == 3 && lastComma < 0) {
      intPart = s;
      fracPart = '';
    }
  }
  intPart = intPart.replaceAll(RegExp(r'[,.]'), '');
  if (intPart.isEmpty) intPart = '0';
  if (fracPart.length > 2) fracPart = fracPart.substring(0, 2);
  final reais = int.tryParse(intPart);
  final centavos = fracPart.isEmpty ? 0 : int.tryParse(fracPart.padRight(2, '0'));
  if (reais == null || centavos == null) return null;
  final cents = reais * 100 + centavos;
  return negative ? -cents : cents;
}
