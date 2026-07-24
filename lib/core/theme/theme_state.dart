import 'package:flutter/material.dart';
import '../storage/secure_storage.dart';

/// Preferência de tema claro/escuro — secção 11: claro é o default
/// (legibilidade ao sol no parque de viaturas), escuro é opção secundária
/// explícita, nunca segue a preferência do sistema/browser sozinha (isso
/// causava ecrãs ilegíveis em modo escuro antes de existir este alternador).
class ThemeState extends ChangeNotifier {
  ThemeState(this._storage) {
    _load();
  }

  final SecureStorage _storage;
  ThemeMode mode = ThemeMode.light;

  Future<void> _load() async {
    final saved = await _storage.readThemeMode();
    if (saved == 'dark') {
      mode = ThemeMode.dark;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _storage.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
