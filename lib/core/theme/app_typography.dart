import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'paletas.dart';

/// Tipografia por tema (2026-11):
/// - Editorial: títulos em Playfair Display (serifa de alto contraste, ar de
///   revista), corpo em Manrope.
/// - Luxo: títulos em Cormorant Garamond (serifa mais fina e clássica),
///   corpo em Manrope.
/// - Minimalista: títulos em Inter Tight, corpo em Inter — sem serifas.
/// Números (preços, kms) sempre com algarismos tabulares, para alinharem.
class AppTypography {
  const AppTypography._();

  /// Definido pelo ThemeState antes de cada reconstrução.
  static TemaApp tema = TemaApp.editorial;

  static TextStyle _corpo({double? fontSize, FontWeight? fontWeight, Color? color, double? letterSpacing, double? height}) {
    final f = tema == TemaApp.minimal ? GoogleFonts.inter : GoogleFonts.manrope;
    return f(fontSize: fontSize, fontWeight: fontWeight, color: color, letterSpacing: letterSpacing, height: height);
  }

  /// Fonte de títulos do tema, já com o ajuste de tamanho/peso que cada uma
  /// precisa para parecer do mesmo tamanho (a Cormorant é pequena e fina).
  static TextStyle _titulo(double fontSize, FontWeight fontWeight, Color? color, {double height = 1.2, TemaApp? de}) {
    const lining = [FontFeature.liningFigures()];
    switch (de ?? tema) {
      case TemaApp.luxo:
        return GoogleFonts.cormorantGaramond(
          fontSize: fontSize * 1.18,
          fontWeight: FontWeight.w600,
          color: color,
          height: height,
          fontFeatures: lining,
        );
      case TemaApp.minimal:
        return GoogleFonts.interTight(
          fontSize: fontSize * 0.92,
          fontWeight: FontWeight.w600,
          color: color,
          height: height,
          letterSpacing: -0.4,
        );
      case TemaApp.editorial:
        return GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
          fontFeatures: lining,
        );
    }
  }

  static TextTheme textTheme(Color onSurface) {
    final base = tema == TemaApp.minimal ? GoogleFonts.interTextTheme() : GoogleFonts.manropeTextTheme();
    return base
        .copyWith(
          displayLarge: _titulo(40, FontWeight.w500, onSurface, height: 1.1),
          displayMedium: _titulo(32, FontWeight.w500, onSurface, height: 1.15),
          headlineLarge: _titulo(26, FontWeight.w500, onSurface),
          headlineMedium: _titulo(21, FontWeight.w500, onSurface),
          titleLarge: _corpo(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface),
          titleMedium: _corpo(fontSize: 15, fontWeight: FontWeight.w700, color: onSurface),
          bodyLarge: _corpo(fontSize: 16, color: onSurface),
          bodyMedium: _corpo(fontSize: 14, color: onSurface),
          bodySmall: _corpo(fontSize: 12.5, color: onSurface.withValues(alpha: 0.62)),
          labelLarge: _corpo(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
        )
        .apply(bodyColor: onSurface, displayColor: onSurface);
  }

  /// Título do tema (nomes de carros, valores do painel, cabeçalhos) — o
  /// nome ficou de quando só havia a versão serifada.
  static TextStyle serifa({double fontSize = 20, FontWeight fontWeight = FontWeight.w500, Color? color}) {
    return _titulo(fontSize, fontWeight, color ?? AppColors.ink);
  }

  /// Título no estilo de outro tema (amostras na escolha de aparência).
  static TextStyle amostraTitulo(TemaApp de, {double fontSize = 26, required Color color}) {
    return _titulo(fontSize, FontWeight.w500, color, de: de);
  }

  /// Etiqueta em versaletes ("DISPONÍVEL · 60 DIAS", rótulos do painel).
  static TextStyle etiqueta({Color? color, double fontSize = 11}) {
    return _corpo(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: tema == TemaApp.luxo ? 2.0 : 1.3,
      color: color ?? AppColors.inkMuted,
    );
  }

  /// Números (preços, kms, matrículas) com algarismos tabulares, para
  /// alinharem em coluna.
  ///
  /// `color` por omissão é `ink` do tema ativo.
  static TextStyle numero({double fontSize = 16, FontWeight fontWeight = FontWeight.w600, Color? color}) {
    return _corpo(fontSize: fontSize, fontWeight: fontWeight, color: color ?? AppColors.ink)
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  }
}
