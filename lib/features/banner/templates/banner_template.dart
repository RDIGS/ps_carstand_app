import 'package:flutter/widgets.dart';

/// Identificador de cada template de banner disponível. Adicionar um
/// template novo = 1 valor aqui + 1 caso no switch de `BannerWidget` +
/// 1 entrada em `bannerTemplates` — nada mais precisa de mudar.
enum BannerTemplateId { escuroClassico, minimalistaClaro, etiquetaPreco, galeriaFotos }

/// Formato/proporção do banner — "post" para feed (1:1) ou "story" para
/// Instagram/Facebook Stories (9:16). Cada template pertence a um só
/// formato (pedido do utilizador, 2026-09-06: separar os templates por
/// "POSTS 1:1" e "STORIES 9:16" no ecrã de escolha).
enum BannerFormato { post, story }

extension BannerFormatoX on BannerFormato {
  /// Tamanho de desenho fixo do template (`BannerWidget`) — a exportação via
  /// RepaintBoundary dá sempre esta proporção, independente do ecrã.
  Size get tamanhoCanvas => switch (this) {
        BannerFormato.post => const Size(1000, 1000),
        BannerFormato.story => const Size(1080, 1920),
      };

  double get aspectRatio => tamanhoCanvas.width / tamanhoCanvas.height;

  /// Limites usados nas pré-visualizações (ecrã de formulário e de
  /// pré-visualização final) para o template não ficar gigante nem
  /// minúsculo consoante o formato.
  BoxConstraints get restricaoPreview => switch (this) {
        BannerFormato.post => const BoxConstraints(maxWidth: 480, maxHeight: 480),
        BannerFormato.story => const BoxConstraints(maxWidth: 320, maxHeight: 569),
      };
}

/// Metadados de cada template para o ecrã de escolha — `premium` já
/// preparado para o futuro (pedido do utilizador, 2026-07-26): quando a
/// plataforma passar a vender templates extra, é só marcar `premium: true`
/// nos novos e o ecrã de escolha já os mostra bloqueados. Nenhum template
/// atual é premium.
class BannerTemplateInfo {
  const BannerTemplateInfo({required this.id, required this.nome, required this.formato, this.premium = false});

  final BannerTemplateId id;
  final String nome;
  final BannerFormato formato;
  final bool premium;
}

const bannerTemplates = [
  BannerTemplateInfo(id: BannerTemplateId.escuroClassico, nome: 'Noturno Clássico', formato: BannerFormato.post),
  BannerTemplateInfo(id: BannerTemplateId.minimalistaClaro, nome: 'Minimalista Claro', formato: BannerFormato.post),
  BannerTemplateInfo(id: BannerTemplateId.etiquetaPreco, nome: 'Etiqueta de Preço', formato: BannerFormato.post),
  BannerTemplateInfo(id: BannerTemplateId.galeriaFotos, nome: 'Galeria de Fotos', formato: BannerFormato.story),
];

BannerTemplateInfo bannerTemplateInfo(BannerTemplateId id) => bannerTemplates.firstWhere((t) => t.id == id);
