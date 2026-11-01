import 'package:flutter/material.dart';

import 'paletas.dart';

/// Cores do tema ativo (ver paletas.dart). Antes eram constantes fixas; desde
/// que o owner pode escolher a aparência do stand (2026-11), cada cor lê a
/// paleta atual — o ThemeState troca-a e reconstrói a app inteira.
///
/// Os nomes (teal/orange/lilac) ficaram por compatibilidade; o que conta é o
/// papel de cada um (ver comentário de [Paleta]).
class AppColors {
  const AppColors._();

  /// Definida pelo ThemeState antes de cada reconstrução.
  static Paleta paleta = Paleta.editorialClaro;

  static Color get ink => paleta.ink; // texto principal
  static Color get inkMuted => paleta.inkMuted; // texto secundário, ícones neutros
  static Color get inkFaint => paleta.inkFaint; // texto terciário/desativado
  static Color get surface => paleta.surface; // fundo de página
  static Color get card => paleta.card;
  static Color get border => paleta.border;
  static Color get borderSoft => paleta.borderSoft;

  static Color get teal => paleta.teal; // principal — "disponível", valores positivos
  static Color get tealInk => paleta.tealInk;
  static Color get teal100 => paleta.teal100;

  static Color get orange => paleta.orange; // secundária — "reservado", avisos
  static Color get orangeInk => paleta.orangeInk;
  static Color get orange100 => paleta.orange100;

  static Color get lilac => paleta.lilac; // "pendente_aprovacao", dados/agendado
  static Color get lilacInk => paleta.lilacInk;
  static Color get lilac100 => paleta.lilac100;

  static Color get red => paleta.red; // só "rejeitado"/valores negativos
  static Color get red100 => paleta.red100;

  static Color get gray => paleta.gray; // "vendido"/neutro
  static Color get gray100 => paleta.gray100;

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
