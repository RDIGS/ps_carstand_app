import 'package:flutter/material.dart';

/// Paleta alinhada ao logo real (triquetra teal/laranja/lilás) — substitui a
/// paleta "navy + âmbar" antiga que nunca bateu certo com a marca. Mockup
/// aprovado: design canvas "PS CarStand Redesign" (ver memória
/// project_visual_redesign).
class AppColors {
  const AppColors._();

  // Texto e superfícies (fundo branco quente, não frio).
  static const ink = Color(0xFF15171B); // texto principal
  static const inkMuted = Color(0xFF6C7278); // texto secundário, ícones neutros
  static const inkFaint = Color(0xFF9A9EA3); // texto terciário/desativado
  static const surface = Color(0xFFFAF9F7); // fundo de página
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE9E6E1);
  static const borderSoft = Color(0xFFF0EEE9);

  // Primária (do logo) — ações primárias, estado "disponível".
  static const teal = Color(0xFF1E9E86);
  static const tealInk = Color(0xFF0F6B58); // texto/ícone sobre fundo tintado de teal
  static const teal100 = Color(0xFFDFF3EE);

  // Acento secundário (do logo) — "reservado", avisos, CTAs secundários.
  static const orange = Color(0xFFD97A2E);
  static const orangeInk = Color(0xFFA15A20);
  static const orange100 = Color(0xFFFBE7D5);

  // Acento terciário (do logo) — "pendente_aprovacao", dados/agendado.
  static const lilac = Color(0xFFA366D9);
  static const lilacInk = Color(0xFF7A3FAE);
  static const lilac100 = Color(0xFFF0E3FA);

  // Só "rejeitado"/valores negativos — não vem do logo, semântica pura.
  static const red = Color(0xFFC64A3E);
  static const red100 = Color(0xFFFBE3E0);

  // "vendido"/neutro — baixo chroma de propósito (estado inativo).
  static const gray = Color(0xFF8A8F98);
  static const gray100 = Color(0xFFEEF0F1);

  static Color paraEstado(String estado) {
    switch (estado) {
      case 'disponivel':
        return teal;
      case 'reservado':
        return orange;
      case 'vendido':
        return gray;
      case 'pendente_aprovacao':
        return lilac;
      case 'rejeitado':
        return red;
      default:
        return gray;
    }
  }
}
