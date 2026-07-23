import 'vehicle.dart';

class VehicleDetail {
  VehicleDetail({
    required this.id,
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.kms,
    required this.estado,
    required this.origem,
    required this.importado,
    required this.criadoEm,
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
    this.precoVendaFinal,
    this.matriculaAnterior,
    this.paisOrigemAnterior,
    this.dataPrimeiraMatriculaOriginal,
    this.possivelImportado = false,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) => VehicleDetail(
        id: json['id'] as String,
        matricula: json['matricula'] as String,
        marca: json['marca'] as String,
        modelo: json['modelo'] as String,
        versao: json['versao'] as String?,
        kms: (json['kms'] as num).toInt(),
        estado: json['estado'] as String,
        origem: json['origem'] as String,
        importado: json['importado'] as bool? ?? false,
        possivelImportado: json['possivel_importado'] as bool? ?? false,
        dataPrimeiraMatricula: json['data_primeira_matricula'] as String?,
        chassis: json['chassis'] as String?,
        categoria: json['categoria'] as String?,
        combustivel: json['combustivel'] as String?,
        cilindrada: (json['cilindrada'] as num?)?.toInt(),
        potenciaKw: (json['potencia_kw'] as num?)?.toInt(),
        pesoTara: (json['peso_tara'] as num?)?.toInt(),
        pesoBruto: (json['peso_bruto'] as num?)?.toInt(),
        cor: json['cor'] as String?,
        numLugares: (json['num_lugares'] as num?)?.toInt(),
        precoCompra: parseDecimal(json['preco_compra']),
        precoVendaRecomendado: parseDecimal(json['preco_venda_recomendado']),
        precoVendaFinal: parseDecimal(json['preco_venda_final']),
        matriculaAnterior: json['matricula_anterior'] as String?,
        paisOrigemAnterior: json['pais_origem_anterior'] as String?,
        dataPrimeiraMatriculaOriginal: json['data_primeira_matricula_original'] as String?,
        criadoEm: DateTime.parse(json['criado_em'] as String),
      );

  final String id;
  final String matricula;
  final String marca;
  final String modelo;
  final String? versao;
  final int kms;
  final String estado;
  final String origem;
  final bool importado;
  final bool possivelImportado;
  final DateTime criadoEm;
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
  final double? precoVendaFinal;
  final String? matriculaAnterior;
  final String? paisOrigemAnterior;
  final String? dataPrimeiraMatriculaOriginal;

  /// Idade real do veículo (secção 12.0, revista 2026-07-17): campo B para
  /// nacionais, data original do Z.3 para importados — nunca o campo I.
  String? get dataPrimeiraMatriculaReal => importado ? dataPrimeiraMatriculaOriginal : dataPrimeiraMatricula;
}
