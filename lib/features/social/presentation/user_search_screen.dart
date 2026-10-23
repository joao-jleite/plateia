import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_view.dart';
import '../../feed/presentation/feed_item.dart';
import '../../onboarding/domain/profile.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../data/social_repository.dart';
import 'follow_button.dart';
import 'share_profile.dart';
import 'social_providers.dart';

/// Busca de pessoas por `@` ou nome (`/search/users`, SPEC §J4.1).
class UserSearchScreen extends StatelessWidget {
  const UserSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _SearchAppBar(),
      body: UserSearchBody(),
    );
  }
}

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Encontrar pessoas'));
}

/// Campo + resultados, reaproveitado pela etapa do onboarding. Sem busca,
/// mostra a dica e o botão de compartilhar o próprio perfil.
class UserSearchBody extends ConsumerStatefulWidget {
  const UserSearchBody({super.key, this.autofocus = true});

  final bool autofocus;

  @override
  ConsumerState<UserSearchBody> createState() => _UserSearchBodyState();
}

class _UserSearchBodyState extends ConsumerState<UserSearchBody> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(userSearchProvider(_query));
    final me = ref.watch(myProfileProvider).value;
    final hasQuery = normalizeUserQuery(_query).isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            key: const Key('user-search-field'),
            controller: _controller,
            autofocus: widget.autofocus,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '@ ou nome',
              prefixIcon: const Icon(Icons.alternate_email),
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
              isDense: true,
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _debounce?.cancel();
                        setState(() => _query = '');
                      },
                    ),
            ),
            onChanged: (v) {
              setState(() {}); // botão de limpar
              _onChanged(v);
            },
            onSubmitted: (v) {
              _debounce?.cancel();
              setState(() => _query = v.trim());
            },
          ),
        ),
        Expanded(
          child: !hasQuery
              ? EmptyView(
                  icon: Icons.person_search_outlined,
                  title: 'Procure pelo @ ou pelo nome',
                  subtitle: 'Perfis privados aparecem na busca; o conteúdo só depois de aceitarem você.',
                  action: me == null
                      ? null
                      : OutlinedButton.icon(
                          key: const Key('share-my-profile'),
                          onPressed: () => unawaited(shareProfile(ref, me)),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Compartilhar meu perfil'),
                        ),
                )
              : AsyncView<List<Profile>>(
                  value: results,
                  onRetry: () => ref.invalidate(userSearchProvider(_query)),
                  isEmpty: (l) => l.isEmpty,
                  empty: EmptyView(icon: Icons.search_off, title: 'Ninguém com "$_query"', subtitle: 'Confira o @ ou convide a pessoa pelo link do seu perfil.'),
                  data: (list) => ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => UserTile(profile: list[i], trailing: FollowButton(profile: list[i], compact: true)),
                  ),
                ),
        ),
      ],
    );
  }
}
