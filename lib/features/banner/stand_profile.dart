class StandProfile {
  StandProfile({required this.id, required this.nome, this.contacto, this.redesSociais});

  factory StandProfile.fromJson(Map<String, dynamic> json) => StandProfile(
        id: json['id'] as String,
        nome: json['nome'] as String,
        contacto: json['contacto'] as String?,
        redesSociais: json['redesSociais'] as String?,
      );

  final String id;
  final String nome;
  final String? contacto;
  final String? redesSociais;
}
