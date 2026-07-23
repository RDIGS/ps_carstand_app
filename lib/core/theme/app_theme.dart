import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Modo claro é o default (ao contrário da tendência SaaS atual) — pensado
/// para luz solar direta no parque de viaturas, não escritório escuro
/// (secção 11). Modo escuro existe como opção secundária.
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.azulMatricula,
      brightness: Brightness.light,
      primary: AppColors.azulMatricula,
      surface: AppColors.cinzaChapa,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cinzaChapa,
      textTheme: AppTypography.textTheme(AppColors.grafiteAsfalto),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cinzaChapa,
        foregroundColor: AppColors.grafiteAsfalto,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulMatricula,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52), // botões grandes, uma mão (secção 11)
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.grafiteAsfalto.withValues(alpha: 0.08)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.azulMatricula,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(Colors.white),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulMatricula,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
