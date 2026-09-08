class StandProfile {
  StandProfile({required this.id, required this.nome, this.contacto, this.redesSociais, this.logoUrl});

  factory StandProfile.fromJson(Map<String, dynamic> json) => StandProfile(
        id: json['id'] as String,
        nome: json['nome'] as String,
        contacto: json['contacto'] as String?,
        redesSociais: json['redesSociais'] as String?,
        logoUrl: json['logoUrl'] as String?,
      );

  final String id;
  final String nome;
  final String? contacto;
  final String? redesSociais;

  /// Logótipo do stand para o gerador de banner de venda — `null` se ainda
  /// não foi carregado nenhum.
  final String? logoUrl;
}
