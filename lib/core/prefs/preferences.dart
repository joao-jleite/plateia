import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências locais do aparelho (chave "aceito anúncios", onboarding visto…).
/// Interface mínima para o app não depender do plugin: `main.dart` injeta o
/// [SharedPrefsPreferences]; testes e fixtures usam [MemoryPreferences].
abstract class Preferences {
  bool? getBool(String key);
  Future<void> setBool(String key, bool value);
}

class SharedPrefsPreferences implements Preferences {
  SharedPrefsPreferences(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
}

/// Só memória: para testes de widget e para o backend de fixtures nos testes.
class MemoryPreferences implements Preferences {
  MemoryPreferences([Map<String, Object?>? initial]) : _values = {...?initial};

  final Map<String, Object?> _values;

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;
}

/// Sobrescrito em `main.dart` (plugin real) e em `pumpScreen` (memória).
/// Sem override é erro de programação, não um estado válido.
final preferencesProvider = Provider<Preferences>(
  (ref) => throw UnimplementedError('preferencesProvider precisa de override (main.dart / pumpScreen).'),
);

/// Chaves usadas no app, num lugar só.
abstract final class PrefKeys {
  static const acceptAds = 'accept_ads';
}
