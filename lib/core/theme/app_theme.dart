import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Modo claro é o default (ao contrário da tendência SaaS atual) — pensado
/// para luz solar direta no parque de viaturas, não escritório escuro
/// (secção 11). Modo escuro existe como opção secundária.
///
/// Cartões usam cantos a 16px e sombra subtil (não 0) — assinatura visual do
/// mockup "PS CarStand Redesign", em vez do cartão plano+contorno anterior.
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
      primary: AppColors.teal,
      surface: AppColors.surface,
      onSurfaceVariant: AppColors.inkMuted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: AppTypography.textTheme(AppColors.ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52), // botões grandes, uma mão (secção 11)
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        shadowColor: AppColors.ink.withValues(alpha: 0.14),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.borderSoft,
    );
  }

  /// Mesma lógica de matiz do claro (secção 11 do mockup), invertida para
  /// superfície escura: fundo quase-preto neutro, texto quase-branco quente,
  /// acentos aclarados para manterem contraste ≥4.5:1 sobre o cartão escuro.
  static ThemeData dark() {
    const darkSurface = Color(0xFF1B1C1E);
    const darkCard = Color(0xFF242527);
    const darkBorder = Color(0xFF35373A);
    const darkInk = Color(0xFFF1F0EE);
    const darkInkMuted = Color(0xFFA7ABB0);
    const darkTeal = Color(0xFF3FBFA6);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.dark,
      primary: darkTeal,
      surface: darkSurface,
      onSurface: darkInk,
      onSurfaceVariant: darkInkMuted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkSurface,
      textTheme: AppTypography.textTheme(darkInk),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkInk,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTeal,
          foregroundColor: darkSurface,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.4),
        margin: EdgeInsets.zero,
      ),
      dividerColor: darkBorder,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: darkTeal),
    );
  }
}

