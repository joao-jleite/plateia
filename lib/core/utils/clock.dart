import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Agora" injetável. O app usa o relógio de verdade; os testes de widget
/// fixam uma data para a janela de 30 dias dos amigos (aba Assinar) não
/// depender do dia em que o teste roda.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
