import 'package:flutter/material.dart';

import '../../../core/widgets/async_view.dart';

/// Aba Feed: chega na fase 06 (rede social).
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: const EmptyView(
        icon: Icons.dynamic_feed_outlined,
        title: 'Em breve',
        subtitle: 'Aqui vai aparecer o que seus amigos estão assistindo.',
      ),
    );
  }
}
