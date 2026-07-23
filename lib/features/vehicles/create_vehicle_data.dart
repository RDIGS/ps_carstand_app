/// Corpo comum a `POST /vehicles` (manual) e `POST /vehicles/:id/confirm`
/// (revisão pós-DUA) — os dois usam exatamente os mesmos campos no backend
/// (CreateVehicleDto), só muda se o id é gerado no servidor ou no cliente.
class CreateVehicleData {
  CreateVehicleData({
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.kms,
    required this.origem,
    this.versao,
    this.dataPrimeiraMatricula,
    this.chassis,
    this.categoria,
    this.combustivel,
    this.cilindrada,
    this.potenciaKw,
    this.pesoTara,
    this.pesoBruto,
    this.cor,
    this.numLugares,
    this.precoCompra,
    this.precoVendaRecomendado,
    this.importado = false,
    this.matriculaAnterior,
    this.paisOrigemAnterior,
    this.dataPrimeiraMatriculaOriginal,
    this.possivelImportado = false,
  });

  final String matricula;
  final String marca;
  final String modelo;
  final int kms;
  final String origem; // 'manual' | 'dua_ocr'
  final String? versao;
  final String? dataPrimeiraMatricula;
  final String? chassis;
  final String? categoria;
  final String? combustivel;
  final int? cilindrada;
  final int? potenciaKw;
  final int? pesoTara;
  final int? pesoBruto;
  final String? cor;
  final int? numLugares;
  final double? precoCompra;
  final double? precoVendaRecomendado;
  final bool importado;
  final String? matriculaAnterior;
  final String? paisOrigemAnterior;
  final String? dataPrimeiraMatriculaOriginal;
  final bool possivelImportado;

  Map<String, dynamic> toJson() => {
        'matricula': matricula,
        'marca': marca,
        'modelo': modelo,
        'kms': kms,
        'origem': origem,
        if (versao != null) 'versao': versao,
        if (dataPrimeiraMatricula != null) 'dataPrimeiraMatricula': dataPrimeiraMatricula,
        if (chassis != null) 'chassis': chassis,
        if (categoria != null) 'categoria': categoria,
        if (combustivel != null) 'combustivel': combustivel,
        if (cilindrada != null) 'cilindrada': cilindrada,
        if (potenciaKw != null) 'potenciaKw': potenciaKw,
        if (pesoTara != null) 'pesoTara': pesoTara,
        if (pesoBruto != null) 'pesoBruto': pesoBruto,
        if (cor != null) 'cor': cor,
        if (numLugares != null) 'numLugares': numLugares,
        if (precoCompra != null) 'precoCompra': precoCompra,
        if (precoVendaRecomendado != null) 'precoVendaRecomendado': precoVendaRecomendado,
        'importado': importado,
        if (matriculaAnterior != null) 'matriculaAnterior': matriculaAnterior,
        if (paisOrigemAnterior != null) 'paisOrigemAnterior': paisOrigemAnterior,
        if (dataPrimeiraMatriculaOriginal != null) 'dataPrimeiraMatriculaOriginal': dataPrimeiraMatriculaOriginal,
        'possivelImportado': possivelImportado,
      };
}
