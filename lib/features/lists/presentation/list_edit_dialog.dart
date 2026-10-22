import 'package:flutter/material.dart';

import '../domain/list_models.dart';

/// Criar ou editar lista: nome, descrição, privada, ranqueada. Devolve o
/// rascunho ou null se cancelou.
Future<ListDraft?> showListEditDialog(BuildContext context, {ListDraft? initial}) {
  return showDialog<ListDraft>(
    context: context,
    builder: (_) => _ListEditDialog(initial: initial),
  );
}

class _ListEditDialog extends StatefulWidget {
  const _ListEditDialog({this.initial});

  final ListDraft? initial;

  @override
  State<_ListEditDialog> createState() => _ListEditDialogState();
}

class _ListEditDialogState extends State<_ListEditDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late bool _private;
  late bool _ranked;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _description = TextEditingController(text: widget.initial?.description ?? '');
    _private = widget.initial?.isPrivate ?? false;
    _ranked = widget.initial?.isRanked ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(ListDraft(
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      isPrivate: _private,
      isRanked: _ranked,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return AlertDialog(
      title: Text(editing ? 'Editar lista' : 'Nova lista'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('list-name'),
                controller: _name,
                autofocus: !editing,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => validateListName(v ?? ''),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _description,
                maxLength: 1000,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Lista privada'),
                subtitle: const Text('Só você vê, nem seguidores.'),
                value: _private,
                onChanged: (v) => setState(() => _private = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ranqueada'),
                subtitle: const Text('Mostra a posição (1., 2., 3.).'),
                value: _ranked,
                onChanged: (v) => setState(() => _ranked = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: Text(editing ? 'Salvar' : 'Criar')),
      ],
    );
  }
}
