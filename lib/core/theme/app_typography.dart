import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografia da secção 11:
/// - Display/títulos: Space Grotesk (técnico/confiante sem ser frio).
/// - Corpo: Inter (legível em ecrãs pequenos, dados densos).
/// - Números (preços, kms, matrículas): IBM Plex Mono com números tabulares —
///   para preços e kms alinharem verticalmente como um conta-quilómetros.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Color onSurface) {
    final base = GoogleFonts.interTextTheme();
    return base
        .copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface),
          displayMedium: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: onSurface),
          headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600, color: onSurface),
          headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
          titleLarge: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
          bodyLarge: GoogleFonts.inter(fontSize: 16, color: onSurface),
          bodyMedium: GoogleFonts.inter(fontSize: 14, color: onSurface),
          labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
        )
        .apply(bodyColor: onSurface, displayColor: onSurface);
  }

  /// Estilo mono para matrícula/kms/preços — números tabulares para
  /// alinharem como um conta-quilómetros real (elemento assinatura, secção 11).
  static TextStyle numero({double fontSize = 16, FontWeight fontWeight = FontWeight.w600, Color? color}) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.grafiteAsfalto,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
