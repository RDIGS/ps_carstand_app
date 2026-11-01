import 'package:flutter/material.dart';
import 'app_typography.dart';
import 'paletas.dart';

/// Tema da app a partir da paleta do tema escolhido pelo stand (ver
/// paletas.dart). Modo claro é o default — pensado para luz solar direta no
/// parque de viaturas (secção 11); "Escuro luxo" é sempre escuro.
///
/// Formas comuns aos três temas (2026-11): cantos quase retos, sem sombras,
/// linhas finas em vez de caixas, botões sóbrios — menos "app gerada", mais
/// concessionário premium. O minimalista arredonda um pouco mais.
class AppTheme {
  const AppTheme._();

  static ThemeData de(TemaApp tema, Paleta p) {
    final raio = tema == TemaApp.minimal ? 8.0 : 4.0;
    final escuro = p.brightness == Brightness.dark;
    // Botão principal: tinta (preto no claro, marfim no escuro); no luxo,
    // champanhe.
    final botao = tema == TemaApp.luxo ? p.teal : p.ink;
    final textoBotao = tema == TemaApp.luxo ? p.surface : (escuro ? p.surface : Colors.white);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: p.teal,
      brightness: p.brightness,
      primary: botao,
      onPrimary: textoBotao,
      secondary: p.teal,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      outline: p.border,
      outlineVariant: p.borderSoft,
      surfaceContainerHighest: p.gray100,
      error: p.red,
    );

    final textTheme = AppTypography.textTheme(p.ink);
    final forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(raio));
    final textoBotaoEstilo = textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.3);
    final linha = p.border;
    final tinta = p.ink;

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.surface,
      canvasColor: p.surface,
      textTheme: textTheme,
      dividerColor: linha,
      dividerTheme: DividerThemeData(color: linha, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: tinta,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.serifa(fontSize: 22, color: tinta),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: botao,
          foregroundColor: textoBotao,
          elevation: 0,
          minimumSize: const Size.fromHeight(50), // botões grandes, uma mão (secção 11)
          shape: forma,
          textStyle: textoBotaoEstilo,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: botao,
          foregroundColor: textoBotao,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: forma,
          textStyle: textoBotaoEstilo,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tinta,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: tinta.withValues(alpha: 0.35)),
          shape: forma,
          textStyle: textoBotaoEstilo,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: tinta, shape: forma, textStyle: textoBotaoEstilo),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: botao,
        foregroundColor: textoBotao,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: forma,
        extendedTextStyle: textoBotaoEstilo,
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(raio), side: BorderSide(color: linha)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(raio), borderSide: BorderSide(color: linha)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(raio), borderSide: BorderSide(color: linha)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(raio), borderSide: BorderSide(color: tinta, width: 1.2)),
      ),
      chipTheme: ChipThemeData(shape: forma, side: BorderSide(color: linha)),
      dialogTheme: DialogThemeData(shape: forma, backgroundColor: p.card, surfaceTintColor: Colors.transparent),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(raio * 2))),
      ),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: forma),
      popupMenuTheme: PopupMenuThemeData(shape: forma, color: p.card, surfaceTintColor: Colors.transparent),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => textTheme.bodySmall!.copyWith(
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? tinta : tinta.withValues(alpha: 0.55),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(size: 22, color: s.contains(WidgetState.selected) ? tinta : tinta.withValues(alpha: 0.5)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? textoBotao : p.inkFaint),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? botao : p.gray100),
        trackOutlineColor: WidgetStateProperty.all(linha),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: tinta, linearTrackColor: linha),
      textSelectionTheme: TextSelectionThemeData(cursorColor: tinta),
    );
  }
}
