import 'package:flutter/material.dart';

import '../../../core/widgets/async_view.dart';

/// Aba Assinar: chega na fase 07 (qual streaming assinar este mês).
class SubscribeScreen extends StatelessWidget {
  const SubscribeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assinar')),
      body: const EmptyView(
        icon: Icons.subscriptions_outlined,
        title: 'Em breve',
        subtitle: 'Vamos dizer qual streaming vale assinar este mês a partir da sua lista.',
      ),
    );
  }
}
