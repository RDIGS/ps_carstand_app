import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../banner_content.dart';
import 'foto_placeholder.dart';

/// Template original — fundo escuro, foto de fundo, faixa de dados sobre
/// gradiente, rodapé com contacto. Replicado do protótipo HTML fornecido
/// pelo utilizador na 1ª versão do banner.
class TemplateEscuroClassico extends StatelessWidget {
  const TemplateEscuroClassico({super.key, required this.content});

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
                stops: [0.4, 0.75, 1.0],
                colors: [Colors.transparent, Color(0xD9000000), Color(0xF2000000)],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(38, 0, 38, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content.titulo.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      content.subtitulo,
                      style: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, color: content.corDestaque),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.only(top: 24),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x33FFFFFF)))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _Estatistica(label: 'POTÊNCIA', valor: content.potencia),
                          _Estatistica(label: 'ANO', valor: content.ano),
                          _Estatistica(label: 'COMBUSTÍVEL', valor: content.combustivel),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                border: Border(left: BorderSide(color: content.corDestaque, width: 4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    content.preco,
                                    style: GoogleFonts.inter(fontSize: 46, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(content.prestacao, style: GoogleFonts.inter(fontSize: 24, color: const Color(0xFFCCCCCC))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(38, 20, 38, 20),
                decoration: const BoxDecoration(
                  color: Color(0xE6000000),
                  border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(content.social, style: GoogleFonts.inter(fontSize: 26, color: const Color(0xFFAAAAAA))),
                    Text(content.contacto, style: GoogleFonts.inter(fontSize: 26, color: const Color(0xFFAAAAAA))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Estatistica extends StatelessWidget {
  const _Estatistica({required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 20, color: const Color(0xFFCCCCCC), fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(valor, style: GoogleFonts.inter(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
