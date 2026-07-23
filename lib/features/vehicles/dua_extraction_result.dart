import 'create_vehicle_data.dart';

/// Espelha `DuaExtractionResult` do backend (src/ocr/dua-extraction.types.ts).
class DuaExtractionResult {
  DuaExtractionResult({
    required this.extracted,
    required this.confianca,
    required this.avisos,
    required this.possivelImportado,
  });

  factory DuaExtractionResult.fromJson(Map<String, dynamic> json) {
    final extracted = json['extracted'] as Map<String, dynamic>;
    return DuaExtractionResult(
      extracted: extracted,
      confianca: Map<String, num>.from(json['confianca'] as Map),
      avisos: List<String>.from(json['avisos'] as List),
      possivelImportado: json['possivel_importado'] as bool? ?? false,
    );
  }

  final Map<String, dynamic> extracted;
  final Map<String, num> confianca;
  final List<String> avisos;
  final bool possivelImportado;

  /// Converte diretamente para os dados do formulário de confirmação
  /// (secção 5: "formulário pré-preenchido, o utilizador revê/corrige").
  CreateVehicleData toCreateVehicleData() {
    return CreateVehicleData(
      matricula: extracted['matricula'] as String? ?? '',
      marca: extracted['marca'] as String? ?? '',
      modelo: extracted['modelo'] as String? ?? '',
      kms: 0, // nunca vem do DUA — o utilizador preenche sempre (secção 5.6)
      origem: 'dua_ocr',
      versao: extracted['versao'] as String?,
      dataPrimeiraMatricula: extracted['data_primeira_matricula'] as String?,
      chassis: extracted['chassis'] as String?,
      categoria: extracted['categoria'] as String?,
      combustivel: extracted['combustivel'] as String?,
      cilindrada: (extracted['cilindrada'] as num?)?.toInt(),
      potenciaKw: (extracted['potencia_kw'] as num?)?.toInt(),
      pesoTara: (extracted['peso_tara'] as num?)?.toInt(),
      pesoBruto: (extracted['peso_bruto'] as num?)?.toInt(),
      cor: extracted['cor'] as String?,
      numLugares: (extracted['num_lugares'] as num?)?.toInt(),
      importado: extracted['importado'] as bool? ?? false,
      matriculaAnterior: extracted['matricula_anterior'] as String?,
      paisOrigemAnterior: extracted['pais_origem_anterior'] as String?,
      dataPrimeiraMatriculaOriginal: extracted['data_primeira_matricula_original'] as String?,
      possivelImportado: possivelImportado,
    );
  }
}
