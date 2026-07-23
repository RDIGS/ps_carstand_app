/// Documento legal pendente de aceitação (secção 24) — o backend só devolve
/// os que ainda faltam aceitar na versão atual, filtrados já por role
/// (owner vê termos+privacidade+dpa, vendedor só privacidade).
class PendingLegalDocument {
  PendingLegalDocument({required this.tipo, required this.versao, required this.conteudo});

  factory PendingLegalDocument.fromJson(Map<String, dynamic> json) => PendingLegalDocument(
        tipo: json['tipo'] as String,
        versao: json['versao'] as int,
        conteudo: json['conteudo'] as String,
      );

  final String tipo; // 'termos' | 'privacidade' | 'dpa'
  final int versao;
  final String conteudo;
}
