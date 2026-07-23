class TeamMember {
  TeamMember({
    required this.id,
    required this.personId,
    required this.role,
    required this.ativo,
    required this.nome,
    required this.email,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>;
    return TeamMember(
      id: json['id'] as String,
      personId: json['personId'] as String,
      role: json['role'] as String,
      ativo: json['ativo'] as bool,
      nome: person['nome'] as String,
      email: person['email'] as String,
    );
  }

  final String id;
  final String personId;
  final String role;
  final bool ativo;
  final String nome;
  final String email;
}
