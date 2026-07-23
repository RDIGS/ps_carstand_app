class AuditEntry {
  AuditEntry({
    required this.id,
    required this.entidade,
    required this.entidadeId,
    required this.acao,
    this.valorAnterior,
    this.valorNovo,
    required this.feitoPor,
    this.feitoPorNome,
    required this.criadoEm,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        id: json['id'] as String,
        entidade: json['entidade'] as String,
        entidadeId: json['entidade_id'] as String,
        acao: json['acao'] as String,
        valorAnterior: json['valor_anterior'] as Map<String, dynamic>?,
        valorNovo: json['valor_novo'] as Map<String, dynamic>?,
        feitoPor: json['feito_por'] as String,
        feitoPorNome: json['feito_por_nome'] as String?,
        criadoEm: DateTime.parse(json['criado_em'] as String),
      );

  final String id;
  final String entidade;
  final String entidadeId;
  final String acao;
  final Map<String, dynamic>? valorAnterior;
  final Map<String, dynamic>? valorNovo;
  final String feitoPor;
  final String? feitoPorNome;
  final DateTime criadoEm;
}
