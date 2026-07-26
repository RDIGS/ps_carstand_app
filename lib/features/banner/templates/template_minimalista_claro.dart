import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../banner_content.dart';
import 'foto_placeholder.dart';

/// Template claro/minimalista — foto no topo, cartão branco em baixo com
/// tipografia preta a negrito e "pills" para as especificações. Inspirado em
/// convenções comuns de posts de stands automóvel (fundo limpo, poucos
/// elementos, preço em destaque forte).
class TemplateMinimalistaClaro extends StatelessWidget {
  const TemplateMinimalistaClaro({super.key, required this.content});

  final BannerContent content;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 58,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (content.foto != null)
                  Image.memory(content.foto!, fit: BoxFit.cover)
                else
                  FotoPlaceholder(corFundo: const Color(0xFFE5E5E5), corIcone: Colors.black.withValues(alpha: 0.2)),
              ],
            ),
          ),
          Container(height: 10, color: content.corDestaque),
          Expanded(
            flex: 42,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(38, 28, 38, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        content.titulo.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.black, height: 1.05),
                      ),
                      Text(
                        content.subtitulo,
                        style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: content.corDestaque),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _Pill(texto: content.potencia),
                          const SizedBox(width: 10),
                          _Pill(texto: content.ano),
                          const SizedBox(width: 10),
                          _Pill(texto: content.combustivel),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(content.social, style: GoogleFonts.inter(fontSize: 22, color: const Color(0xFF888888))),
                          Text(content.contacto, style: GoogleFonts.inter(fontSize: 22, color: const Color(0xFF888888))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            content.preco,
                            style: GoogleFonts.inter(fontSize: 52, fontWeight: FontWeight.w900, color: content.corDestaque, height: 1),
                          ),
                          Text(content.prestacao, style: GoogleFonts.inter(fontSize: 22, color: const Color(0xFF888888))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(20)),
      child: Text(
        texto,
        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
      ),
    );
  }
}
