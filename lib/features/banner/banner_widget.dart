import 'package:flutter/material.dart';

import 'banner_content.dart';
import 'templates/banner_template.dart';
import 'templates/template_escuro_classico.dart';
import 'templates/template_etiqueta_preco.dart';
import 'templates/template_minimalista_claro.dart';

/// Post 1:1 para redes sociais — despacha para o template escolhido
/// (`content.templateId`). Design de cada template propositadamente
/// independente da paleta da app: só o ecrã à volta deste widget segue o
/// tema da app.
///
/// Tamanho de desenho fixo (1000x1000) para a exportação via RepaintBoundary
/// dar sempre a mesma proporção 1:1 independentemente do ecrã.
class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key, required this.content});

  final BannerContent content;

  static const double tamanho = 1000;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: switch (content.templateId) {
        BannerTemplateId.escuroClassico => TemplateEscuroClassico(content: content),
        BannerTemplateId.minimalistaClaro => TemplateMinimalistaClaro(content: content),
        BannerTemplateId.etiquetaPreco => TemplateEtiquetaPreco(content: content),
      },
    );
  }
}
