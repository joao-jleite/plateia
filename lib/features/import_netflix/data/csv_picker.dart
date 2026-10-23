import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../../core/errors/app_exception.dart';

/// O arquivo escolhido, já em memória. Os bytes vivem só até o `compute`
/// terminar; nada é gravado no aparelho nem enviado ao servidor.
class PickedCsv {
  const PickedCsv({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

abstract class CsvPicker {
  /// Null quando a pessoa cancela.
  Future<PickedCsv?> pick();
}

/// Seletor nativo (SAF no Android) via `file_picker` 13. `FileType.any` porque
/// o filtro por extensão esconde o CSV em alguns gerenciadores de arquivo.
class FilePickerCsvPicker implements CsvPicker {
  static const maxBytes = 20 * 1024 * 1024; // 5 mil linhas têm ~300 KB; 20 MB é folga

  @override
  Future<PickedCsv?> pick() async {
    final file = await FilePicker.pickFile(type: FileType.any, dialogTitle: 'Escolha o CSV da Netflix');
    if (file == null) return null;
    final known = file.lengthSync();
    if (known != null && known > maxBytes) throw const AppException('file', 'Arquivo grande demais (máximo 20 MB).');
    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      throw AppException('file', 'Não deu para ler o arquivo escolhido.', cause: e);
    }
    if (bytes.length > maxBytes) throw const AppException('file', 'Arquivo grande demais (máximo 20 MB).');
    return PickedCsv(name: file.name, bytes: bytes);
  }
}
