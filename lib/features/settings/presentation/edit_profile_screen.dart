import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../onboarding/data/profile_repository.dart';
import '../../onboarding/domain/profile.dart';
import '../../onboarding/domain/username.dart';
import '../../onboarding/presentation/my_profile_provider.dart';

/// Editar o cartão do perfil: foto (redimensionada no aparelho antes de subir),
/// nome, @ e bio.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();
  bool _filled = false;
  bool _saving = false;
  bool _uploading = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _fill(Profile p) {
    if (_filled) return;
    _filled = true;
    _name.text = p.displayName ?? '';
    _username.text = p.username;
    _bio.text = p.bio ?? '';
  }

  Future<void> _pickAvatar() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      // maxWidth/maxHeight/imageQuality: o próprio Android redimensiona e
      // recomprime; o bucket aceita até 2 MB (migração 0002).
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
      if (picked == null) return;
      setState(() => _uploading = true);
      final bytes = await picked.readAsBytes();
      await ref.read(myProfileProvider.notifier).uploadAvatar(bytes, contentType: picked.mimeType ?? 'image/jpeg');
      messenger.showSnackBar(const SnackBar(content: Text('Foto atualizada.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save(Profile current) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final notifier = ref.read(myProfileProvider.notifier);
      final username = normalizeUsername(_username.text);
      if (username != current.username) await notifier.saveUsername(username);
      await notifier.updateCard(ProfileCardDraft(displayName: _name.text, bio: _bio.text));
      messenger.showSnackBar(const SnackBar(content: Text('Perfil salvo.')));
      if (router.canPop()) router.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: AsyncView<Profile?>(
        value: profile,
        onRetry: () => ref.invalidate(myProfileProvider),
        isEmpty: (p) => p == null,
        data: (p) {
          _fill(p!);
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Stack(
                    children: [
                      PosterImage(url: p.avatarUrl, width: 96, height: 96, borderRadius: 48, fallbackIcon: Icons.person),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          tooltip: 'Trocar foto',
                          onPressed: _uploading ? null : () => unawaited(_pickAvatar()),
                          icon: _uploading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.photo_camera_outlined, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  maxLength: 50,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _username,
                  maxLength: 20,
                  decoration: const InputDecoration(labelText: '@', prefixText: '@ ', helperText: 'Letras minúsculas, números e _. Links antigos deixam de funcionar.'),
                  validator: (v) => validateUsername(v ?? ''),
                  autocorrect: false,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bio,
                  maxLength: 280,
                  maxLines: 4,
                  minLines: 2,
                  decoration: const InputDecoration(labelText: 'Bio', alignLabelWithHint: true),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : () => unawaited(_save(p)),
                  child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
