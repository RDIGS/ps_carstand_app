import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../banner_content.dart';
import 'foto_placeholder.dart';

/// Template com foto principal em destaque + grelha de fotos adicionais por
/// baixo (até 6, vêm da galeria já guardada do veículo — ver
/// `BannerContent.fotosGaleria`). Pedido do utilizador, 2026-09-02, a partir
/// de um exemplo de um concorrente (Instagram Stories).
///
/// Título/especificações ficam sobrepostos na própria foto principal (com
/// gradiente, mesmo padrão do TemplateEscuroClassico) em vez de numa faixa
/// preta à parte — ajuste pedido 2026-09-02 ("infos não deviam estar
/// diretamente no carro?"): a faixa à parte desperdiçava espaço preto que
/// agora vai todo para a grelha de fotos.
class TemplateGaleriaFotos extends StatelessWidget {
  const TemplateGaleriaFotos({super.key, required this.content});

  final BannerContent content;

  static const double _alturaHero = 600;
  static const double _espacoGrelha = 8;
  static const double _margemGrelha = 14;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _alturaHero,
            child: Stack(
              fit: StackFit.expand,
              children: [
                content.foto != null ? Image.memory(content.foto!, fit: BoxFit.cover) : const FotoPlaceholder(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.45, 0.78, 1.0],
                      colors: [Colors.transparent, Color(0xD9000000), Color(0xF2000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: 26,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.titulo.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 20, color: Colors.white.withValues(alpha: 0.85)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              [content.ano, content.combustivel, content.preco]
                                  .where((v) => v.isNotEmpty)
                                  .join('  •  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(_margemGrelha, _margemGrelha, _margemGrelha, _margemGrelha),
              child: _Grelha(fotos: content.fotosGaleria.take(6).toList()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grelha de fotos construída com `Row`/`Column`/`Expanded` em vez de `Wrap`
/// com tamanhos calculados à mão — `Expanded` preenche sempre o espaço
/// disponível exatamente, sem risco de sobrar uma faixa vazia por
/// arredondamento (bug real reportado 2026-09-02: "continua com muita
/// margem, até mesmo em baixo").
class _Grelha extends StatelessWidget {
  const _Grelha({required this.fotos});

  final List<Uint8List> fotos;

  @override
  Widget build(BuildContext context) {
    final total = fotos.length;
    if (total == 0) return const SizedBox.shrink();

    final colunas = total <= 1 ? 1 : (total <= 4 ? 2 : 3);
    final linhas = (total / colunas).ceil();

    return Column(
      children: [
        for (var l = 0; l < linhas; l++) ...[
          if (l > 0) const SizedBox(height: TemplateGaleriaFotos._espacoGrelha),
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < colunas; c++) ...[
                  if (c > 0) const SizedBox(width: TemplateGaleriaFotos._espacoGrelha),
                  Expanded(
                    child: l * colunas + c < total
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              fotos[l * colunas + c],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
