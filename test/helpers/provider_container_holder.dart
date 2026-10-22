import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Captura o container do ProviderScope de dentro da árvore, para o teste ler
/// providers depois do pump (`holder.container.read(...)`).
class ProviderContainerHolder {
  ProviderContainer? _container;

  void capture(BuildContext context) => _container = ProviderScope.containerOf(context);

  ProviderContainer get container => _container!;
}
