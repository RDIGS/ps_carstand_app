// Mesmo padrão de IdentityExtractionResult (sales/identity_extraction_result.dart)
// — mapa em bruto + getters tipados, para não duplicar o parsing quando o
// backend acrescentar/mudar campos.
class InvoiceExtractionResult {
  InvoiceExtractionResult({required this.extracted, required this.confianca, required this.avisos});

  factory InvoiceExtractionResult.fromJson(Map<String, dynamic> json) {
    final extracted = json['extracted'] as Map<String, dynamic>;
    return InvoiceExtractionResult(
      extracted: extracted,
      confianca: Map<String, num>.from(json['confianca'] as Map),
      avisos: List<String>.from(json['avisos'] as List),
    );
  }

  final Map<String, dynamic> extracted;
  final Map<String, num> confianca;
  final List<String> avisos;

  String? get fornecedorNome => extracted['fornecedor_nome'] as String?;
  String? get fornecedorNif => extracted['fornecedor_nif'] as String?;
  String? get data => extracted['data'] as String?;
  double? get valorTotal => (extracted['valor_total'] as num?)?.toDouble();
  double? get valorIva => (extracted['valor_iva'] as num?)?.toDouble();
  double? get taxaIva => (extracted['taxa_iva'] as num?)?.toDouble();
  String? get descricao => extracted['descricao'] as String?;
}
