/// Identificador de cada template de banner disponível. Adicionar um
/// template novo = 1 valor aqui + 1 caso no switch de `BannerWidget` +
/// 1 entrada em `bannerTemplates` — nada mais precisa de mudar.
enum BannerTemplateId { escuroClassico, minimalistaClaro, etiquetaPreco }

/// Metadados de cada template para o ecrã de escolha — `premium` já
/// preparado para o futuro (pedido do utilizador, 2026-07-26): quando a
/// plataforma passar a vender templates extra, é só marcar `premium: true`
/// nos novos e o ecrã de escolha já os mostra bloqueados. Nenhum template
/// atual é premium.
class BannerTemplateInfo {
  const BannerTemplateInfo({required this.id, required this.nome, this.premium = false});

  final BannerTemplateId id;
  final String nome;
  final bool premium;
}

const bannerTemplates = [
  BannerTemplateInfo(id: BannerTemplateId.escuroClassico, nome: 'Noturno Clássico'),
  BannerTemplateInfo(id: BannerTemplateId.minimalistaClaro, nome: 'Minimalista Claro'),
  BannerTemplateInfo(id: BannerTemplateId.etiquetaPreco, nome: 'Etiqueta de Preço'),
];
