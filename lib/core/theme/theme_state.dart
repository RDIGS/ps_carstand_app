import 'package:flutter/material.dart';
import '../storage/secure_storage.dart';
import 'app_colors.dart';
import 'app_theme.dart';
import 'app_typography.dart';
import 'paletas.dart';

/// Aparência da app: o tema do stand (escolhido pelo owner, igual para toda a
/// equipa — vem de `GET /stands/me`) e o modo claro/escuro (preferência deste
/// dispositivo). Secção 11: claro é o default (legibilidade ao sol no parque
/// de viaturas) e nunca segue o sistema sozinho. "Escuro luxo" é sempre escuro.
///
/// O tema também fica guardado no dispositivo, para a app já abrir com a
/// aparência certa antes de o perfil do stand chegar.
class ThemeState extends ChangeNotifier {
  ThemeState(this._storage) {
    _aplicar();
    _load();
  }

  final SecureStorage _storage;
  ThemeMode mode = ThemeMode.light;
  TemaApp tema = TemaApp.editorial;

  bool get escuro => tema.soEscuro || mode == ThemeMode.dark;

  Paleta get paleta => Paleta.de(tema, escuro ? Brightness.dark : Brightness.light);

  ThemeData get themeData => AppTheme.de(tema, paleta);

  /// Muda sempre que a aparência muda — usada como chave da árvore principal
  /// para a reconstruir por inteiro (muitos widgets leem AppColors
  /// diretamente, sem dependerem do Theme).
  String get chave => '${tema.name}-$escuro';

  void _aplicar() {
    AppColors.paleta = paleta;
    AppTypography.tema = tema;
  }

  Future<void> _load() async {
    final modo = await _storage.readThemeMode();
    final temaGuardado = await _storage.readTema();
    mode = modo == 'dark' ? ThemeMode.dark : ThemeMode.light;
    tema = TemaApp.deCodigo(temaGuardado);
    _aplicar();
    notifyListeners();
  }

  Future<void> toggle() async {
    mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _aplicar();
    notifyListeners();
    await _storage.saveThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }

  /// Tema do stand (ao abrir a app, a partir do perfil, ou quando o owner o
  /// muda nas Definições).
  Future<void> definirTema(TemaApp novo) async {
    if (novo == tema) return;
    tema = novo;
    _aplicar();
    notifyListeners();
    await _storage.saveTema(novo.name);
  }
}
