import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Badge do logótipo do stand — canto superior direito em todos os
/// templates (consistência entre eles), fundo branco semi-transparente para
/// garantir contraste mesmo sobre fotos claras. Só desenhado quando
/// `BannerContent.logo` não é `null` (utilizador escolheu incluir).
/// Pedido do utilizador, 2026-09-07.
class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, required this.logo, this.tamanho = 84});

  final Uint8List logo;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 28,
      right: 28,
      child: Container(
        width: tamanho,
        height: tamanho,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 3))],
        ),
        child: Image.memory(logo, fit: BoxFit.contain),
      ),
    );
  }
}
