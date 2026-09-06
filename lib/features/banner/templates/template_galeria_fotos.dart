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
///
/// Formato Story 9:16 (1080x1920 — ver `BannerFormato.story`), não Post 1:1
/// (ajuste pedido 2026-09-06: este template imita um Instagram Story, por
/// isso passou a ter a proporção certa em vez de ficar "espremido" num
/// quadrado). A hero ocupa 60% da altura, tal como acontecia no quadrado
/// original — só a grelha por baixo ganhou muito mais espaço vertical.
///
/// Preço + valor de crédito (`content.prestacao`) em destaque por baixo das
/// especificações, com o valor de crédito num badge da cor de destaque —
/// mesmo padrão do `TemplateEtiquetaPreco` (pedido do utilizador, 2026-09-06).
class TemplateGaleriaFotos extends StatelessWidget {
  const TemplateGaleriaFotos({super.key, required this.content});

  final BannerContent content;

  static const double _alturaHero = 1150;
  static const double _espacoGrelha = 10;
  static const double _margemGrelha = 16;

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
                  left: 36,
                  right: 36,
                  bottom: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.titulo.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 22, color: Colors.white.withValues(alpha: 0.85)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              [content.ano, content.combustivel].where((v) => v.isNotEmpty).join('  •  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              content.preco,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                          if (content.prestacao.isNotEmpty) ...[
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                              decoration:
                                  BoxDecoration(color: content.corDestaque, borderRadius: BorderRadius.circular(24)),
                              child: Text(
                                content.prestacao,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ],
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
