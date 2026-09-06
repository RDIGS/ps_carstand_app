import 'package:flutter/material.dart';

import 'banner_content.dart';
import 'templates/banner_template.dart';
import 'templates/template_escuro_classico.dart';
import 'templates/template_etiqueta_preco.dart';
import 'templates/template_galeria_fotos.dart';
import 'templates/template_minimalista_claro.dart';

/// Banner para redes sociais (post 1:1 ou story 9:16, conforme o template
/// escolhido) — despacha para o template escolhido (`content.templateId`).
/// Design de cada template propositadamente independente da paleta da app:
/// só o ecrã à volta deste widget segue o tema da app.
///
/// Tamanho de desenho fixo (ver `BannerFormato.tamanhoCanvas`) para a
/// exportação via RepaintBoundary dar sempre a mesma proporção,
/// independentemente do ecrã.
class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key, required this.content});

  final BannerContent content;

  @override
  Widget build(BuildContext context) {
    final tamanho = bannerTemplateInfo(content.templateId).formato.tamanhoCanvas;
    return SizedBox(
      width: tamanho.width,
      height: tamanho.height,
      child: switch (content.templateId) {
        BannerTemplateId.escuroClassico => TemplateEscuroClassico(content: content),
        BannerTemplateId.minimalistaClaro => TemplateMinimalistaClaro(content: content),
        BannerTemplateId.etiquetaPreco => TemplateEtiquetaPreco(content: content),
        BannerTemplateId.galeriaFotos => TemplateGaleriaFotos(content: content),
      },
    );
  }
}
