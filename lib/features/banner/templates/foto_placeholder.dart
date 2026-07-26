import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Placeholder desenhado na app (sem depender de nenhuma foto de stock) —
/// só para pré-visualização, nunca é o que fica no ficheiro final: "Gerar"
/// continua bloqueado até haver foto real. Partilhado por todos os templates.
class FotoPlaceholder extends StatelessWidget {
  const FotoPlaceholder({super.key, this.corFundo = const Color(0xFF2A2A2A), this.corIcone});

  final Color corFundo;
  final Color? corIcone;

  @override
  Widget build(BuildContext context) {
    final cor = corIcone ?? Colors.white.withValues(alpha: 0.25);
    return ColoredBox(
      color: corFundo,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined, size: 220, color: cor),
            const SizedBox(height: 16),
            Text(
              'SEM FOTO',
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 2, color: cor),
            ),
          ],
        ),
      ),
    );
  }
}
