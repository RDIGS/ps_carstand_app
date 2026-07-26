import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../banner_content.dart';
import 'foto_placeholder.dart';

/// Template "etiqueta de preço" — foto a toda a largura, fita diagonal
/// "DISPONÍVEL" no canto, badges de especificação em baixo e um preço em
/// destaque tipo autocolante/etiqueta. Inspirado nas fitas/etiquetas de
/// preço comuns em anúncios de stands automóvel.
class TemplateEtiquetaPreco extends StatelessWidget {
  const TemplateEtiquetaPreco({super.key, required this.content});

  final BannerContent content;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (content.foto != null) Image.memory(content.foto!, fit: BoxFit.cover) else const FotoPlaceholder(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.55, 1.0],
                colors: [Colors.transparent, Color(0xF2000000)],
              ),
            ),
          ),
          // Fita diagonal no canto superior esquerdo.
          Positioned(
            top: 60,
            left: -110,
            child: Transform.rotate(
              angle: -0.7853981633974483, // -45°
              child: Container(
                width: 420,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: content.corDestaque,
                alignment: Alignment.center,
                child: Text(
                  'DISPONÍVEL',
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.titulo.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white, height: 1.05),
                ),
                Text(
                  content.subtitulo,
                  style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Badge(texto: content.potencia),
                    const SizedBox(width: 10),
                    _Badge(texto: content.ano),
                    const SizedBox(width: 10),
                    _Badge(texto: content.combustivel),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(content.social, style: GoogleFonts.inter(fontSize: 22, color: Colors.white70)),
                        Text(content.contacto, style: GoogleFonts.inter(fontSize: 22, color: Colors.white70)),
                      ],
                    ),
                    // "Etiqueta" de preço, tipo autocolante.
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: content.corDestaque,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            content.preco,
                            style: GoogleFonts.inter(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                          ),
                          Text(
                            content.prestacao,
                            style: GoogleFonts.inter(fontSize: 20, color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(texto, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}
