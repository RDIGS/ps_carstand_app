/// Espelha `IdentityExtractionResult` do backend
/// (src/ocr/identity-extraction.types.ts) — secção 23, CC ou Título de
/// Residência (o backend deteta qual dos dois é).
class IdentityExtractionResult {
  IdentityExtractionResult({required this.extracted, required this.confianca, required this.avisos});

  factory IdentityExtractionResult.fromJson(Map<String, dynamic> json) {
    final extracted = json['extracted'] as Map<String, dynamic>;
    return IdentityExtractionResult(
      extracted: extracted,
      confianca: Map<String, num>.from(json['confianca'] as Map),
      avisos: List<String>.from(json['avisos'] as List),
    );
  }

  final Map<String, dynamic> extracted;
  final Map<String, num> confianca;
  final List<String> avisos;

  String? get tipoDocumento => extracted['tipo_documento'] as String?;
  String? get nomeCompleto => extracted['nome_completo'] as String?;
  String? get numeroDocumento => extracted['numero_documento'] as String?;
  String? get nif => extracted['nif'] as String?;
  String? get morada => extracted['morada'] as String?;
}
