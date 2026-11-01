import 'package:flutter/material.dart';

/// Aparência escolhida pelo owner nas Definições do stand (igual para toda a
/// equipa — `stands.tema` no backend).
enum TemaApp {
  editorial,
  luxo,
  minimal;

  static TemaApp deCodigo(String? codigo) =>
      TemaApp.values.firstWhere((t) => t.name == codigo, orElse: () => TemaApp.editorial);

  /// "Escuro luxo" é sempre escuro; os outros respeitam o modo claro/escuro.
  bool get soEscuro => this == TemaApp.luxo;
}

/// Cores de um tema. Os nomes dos papéis (teal/orange/lilac) vêm da paleta
/// original e ficaram por compatibilidade: teal = principal/positivo/
/// "disponível", orange = secundária/avisos/"reservado", lilac =
/// "pendente", red = negativo/"rejeitado", gray = neutro/"vendido".
class Paleta {
  const Paleta({
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.surface,
    required this.card,
    required this.border,
    required this.borderSoft,
    required this.teal,
    required this.tealInk,
    required this.teal100,
    required this.orange,
    required this.orangeInk,
    required this.orange100,
    required this.lilac,
    required this.lilacInk,
    required this.lilac100,
    required this.red,
    required this.red100,
    required this.gray,
    required this.gray100,
    required this.brightness,
  });

  final Color ink, inkMuted, inkFaint, surface, card, border, borderSoft;
  final Color teal, tealInk, teal100, orange, orangeInk, orange100, lilac, lilacInk, lilac100;
  final Color red, red100, gray, gray100;
  final Brightness brightness;

  static Paleta de(TemaApp tema, Brightness brilho) {
    switch (tema) {
      case TemaApp.luxo:
        return luxo;
      case TemaApp.minimal:
        return brilho == Brightness.dark ? minimalEscuro : minimalClaro;
      case TemaApp.editorial:
        return brilho == Brightness.dark ? editorialEscuro : editorialClaro;
    }
  }

  /// Marfim, tinta quase preta, verde-garrafa e dourado velho.
  static const editorialClaro = Paleta(
    brightness: Brightness.light,
    ink: Color(0xFF1C1B19),
    inkMuted: Color(0xFF6E6A63),
    inkFaint: Color(0xFFA39E95),
    surface: Color(0xFFF6F3EE),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE2DDD4),
    borderSoft: Color(0xFFEAE6DF),
    teal: Color(0xFF2E5A47),
    tealInk: Color(0xFF234538),
    teal100: Color(0xFFE3EBE6),
    orange: Color(0xFF9C7A3C),
    orangeInk: Color(0xFF7A5E2B),
    orange100: Color(0xFFF1EADC),
    lilac: Color(0xFF6D5C80),
    lilacInk: Color(0xFF54466A),
    lilac100: Color(0xFFECE7F0),
    red: Color(0xFFA4473A),
    red100: Color(0xFFF4E3DF),
    gray: Color(0xFF8C877F),
    gray100: Color(0xFFEDEAE4),
  );

  static const editorialEscuro = Paleta(
    brightness: Brightness.dark,
    ink: Color(0xFFF2EEE7),
    inkMuted: Color(0xFFA9A49B),
    inkFaint: Color(0xFF7C776F),
    surface: Color(0xFF191817),
    card: Color(0xFF222120),
    border: Color(0xFF363431),
    borderSoft: Color(0xFF2C2A28),
    teal: Color(0xFF8DBBA3),
    tealInk: Color(0xFFB3D3C2),
    teal100: Color(0xFF243229),
    orange: Color(0xFFCDA866),
    orangeInk: Color(0xFFE0C388),
    orange100: Color(0xFF392F20),
    lilac: Color(0xFFAC9CC2),
    lilacInk: Color(0xFFC6BAD7),
    lilac100: Color(0xFF2E2935),
    red: Color(0xFFD9806F),
    red100: Color(0xFF3B2521),
    gray: Color(0xFF928D85),
    gray100: Color(0xFF2B2927),
  );

  /// Quase preto, marfim e champanhe — o dourado faz de cor principal.
  static const luxo = Paleta(
    brightness: Brightness.dark,
    ink: Color(0xFFEDE6D6),
    inkMuted: Color(0xFFA59E8E),
    inkFaint: Color(0xFF6E685D),
    surface: Color(0xFF0F0F0E),
    card: Color(0xFF181817),
    border: Color(0xFF2E2B26),
    borderSoft: Color(0xFF23211E),
    teal: Color(0xFFC9A96E),
    tealInk: Color(0xFFDCC291),
    teal100: Color(0xFF2C251A),
    orange: Color(0xFFB98C5A),
    orangeInk: Color(0xFFD2A877),
    orange100: Color(0xFF2E2419),
    lilac: Color(0xFF9F92B6),
    lilacInk: Color(0xFFBDB2D0),
    lilac100: Color(0xFF26222C),
    red: Color(0xFFC97C6C),
    red100: Color(0xFF33201C),
    gray: Color(0xFF8E887D),
    gray100: Color(0xFF22211F),
  );

  /// Branco, cinzentos e preto; cor só para o que tem significado.
  static const minimalClaro = Paleta(
    brightness: Brightness.light,
    ink: Color(0xFF111111),
    inkMuted: Color(0xFF6B6B6B),
    inkFaint: Color(0xFFA3A3A3),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE5E5E5),
    borderSoft: Color(0xFFF0F0F0),
    teal: Color(0xFF1F7A4D),
    tealInk: Color(0xFF165C3A),
    teal100: Color(0xFFE8F3EC),
    orange: Color(0xFFB7791F),
    orangeInk: Color(0xFF8A5A14),
    orange100: Color(0xFFFBF1E2),
    lilac: Color(0xFF6B5FA8),
    lilacInk: Color(0xFF51478A),
    lilac100: Color(0xFFEEECF7),
    red: Color(0xFFC0392B),
    red100: Color(0xFFFBE9E7),
    gray: Color(0xFF8A8A8A),
    gray100: Color(0xFFF3F3F3),
  );

  static const minimalEscuro = Paleta(
    brightness: Brightness.dark,
    ink: Color(0xFFF5F5F5),
    inkMuted: Color(0xFFA3A3A3),
    inkFaint: Color(0xFF6B6B6B),
    surface: Color(0xFF0F0F0F),
    card: Color(0xFF171717),
    border: Color(0xFF2A2A2A),
    borderSoft: Color(0xFF1F1F1F),
    teal: Color(0xFF5FBF8B),
    tealInk: Color(0xFF8ED3AC),
    teal100: Color(0xFF1B2A21),
    orange: Color(0xFFE0A84A),
    orangeInk: Color(0xFFF0C27A),
    orange100: Color(0xFF2E2416),
    lilac: Color(0xFFA79CDD),
    lilacInk: Color(0xFFC4BCEA),
    lilac100: Color(0xFF242130),
    red: Color(0xFFE57363),
    red100: Color(0xFF3A201C),
    gray: Color(0xFF8F8F8F),
    gray100: Color(0xFF1F1F1F),
  );
}
