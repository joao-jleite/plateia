import 'package:freezed_annotation/freezed_annotation.dart';

import '../../catalog/domain/catalog_models.dart';

part 'list_models.freezed.dart';
part 'list_models.g.dart';

/// Linha de `public.lists`. `itemCount` vem do embed `list_items(count)`.
@freezed
abstract class ListModel with _$ListModel {
  const ListModel._();

  const factory ListModel({
    required String id,
    required String userId,
    required String name,
    String? description,
    @Default(false) bool isPrivate,
    @Default(false) bool isRanked,
    @Default(0) int itemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ListModel;

  factory ListModel.fromJson(Map<String, dynamic> json) => _$ListModelFromJson(json);

  String get countLabel => itemCount == 1 ? '1 título' : '$itemCount títulos';
}

/// Linha de `public.list_items` com o título embutido para o pôster.
@freezed
abstract class ListItem with _$ListItem {
  const factory ListItem({
    required String listId,
    required String titleId,
    @Default(0) int position,
    String? note,
    DateTime? addedAt,
    Title? title,
  }) = _ListItem;

  factory ListItem.fromJson(Map<String, dynamic> json) => _$ListItemFromJson(json);
}

/// Campos editáveis de uma lista (criar e editar usam o mesmo formulário).
@freezed
abstract class ListDraft with _$ListDraft {
  const factory ListDraft({
    required String name,
    String? description,
    @Default(false) bool isPrivate,
    @Default(false) bool isRanked,
  }) = _ListDraft;
}

/// Nome válido: 1 a 100 caracteres (check de `lists.name`).
String? validateListName(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return 'Dê um nome para a lista.';
  if (s.length > 100) return 'No máximo 100 caracteres.';
  return null;
}
