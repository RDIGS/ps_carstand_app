class StandProfile {
  StandProfile({
    required this.id,
    required this.nome,
    this.contacto,
    this.redesSociais,
    this.logoUrl,
    this.morada,
    this.slug,
    this.siteAtivo = false,
    this.vendedorPodeAprovarVisitas = false,
    this.nif,
    this.denominacaoSocial,
    this.localidade,
  });

  factory StandProfile.fromJson(Map<String, dynamic> json) => StandProfile(
        id: json['id'] as String,
        nome: json['nome'] as String,
        contacto: json['contacto'] as String?,
        redesSociais: json['redesSociais'] as String?,
        logoUrl: json['logoUrl'] as String?,
        morada: json['morada'] as String?,
        slug: json['slug'] as String?,
        siteAtivo: (json['siteAtivo'] as bool?) ?? false,
        vendedorPodeAprovarVisitas: (json['vendedorPodeAprovarVisitas'] as bool?) ?? false,
        nif: json['nif'] as String?,
        denominacaoSocial: json['denominacaoSocial'] as String?,
        localidade: json['localidade'] as String?,
      );

  final String id;
  final String nome;
  final String? contacto;
  final String? redesSociais;

  /// Logótipo do stand para o gerador de banner de venda — `null` se ainda
  /// não foi carregado nenhum.
  final String? logoUrl;
  final String? morada;

  /// Endereço do site público (`ps-carstand-app.onrender.com/<slug>`).
  final String? slug;
  final bool siteAtivo;

  /// Se os colaboradores (não só o owner) podem aprovar pedidos de visita.
  final bool vendedorPodeAprovarVisitas;

  /// Dados que entram nas declarações do veículo (denominação social vazia
  /// → usa o nome do stand).
  final String? nif;
  final String? denominacaoSocial;
  final String? localidade;
}
