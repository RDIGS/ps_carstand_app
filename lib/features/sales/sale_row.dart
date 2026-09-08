import '../vehicles/vehicle.dart';

/// Linha crua de GET /sales — vem direto de SELECT * (SQL do tenant) + join
/// de veículo/vendedor (backend, 2026-09-07), por isso os NUMERIC
/// (preco_final, comissao_vendedor) chegam como String.
class SaleRow {
  SaleRow({
    required this.id,
    required this.vehicleId,
    required this.compradorNome,
    required this.precoFinal,
    required this.dataVenda,
    required this.estado,
    this.comissaoVendedor,
    this.docRegistoCompraUrl,
    this.docDuaFinalUrl,
    this.matricula,
    this.marca,
    this.modelo,
    this.vendedorNome,
    this.compradorNif,
    this.compradorMorada,
    this.compradorCp,
    this.compradorTelefone,
    this.compradorLocalidade,
    this.compradorEmail,
  });

  factory SaleRow.fromJson(Map<String, dynamic> json) => SaleRow(
        id: json['id'] as String,
        vehicleId: json['vehicle_id'] as String,
        compradorNome: json['comprador_nome'] as String,
        precoFinal: parseDecimal(json['preco_final']) ?? 0,
        comissaoVendedor: parseDecimal(json['comissao_vendedor']),
        dataVenda: json['data_venda'] as String,
        estado: json['estado'] as String,
        docRegistoCompraUrl: json['doc_registo_compra_url'] as String?,
        docDuaFinalUrl: json['doc_dua_final_url'] as String?,
        matricula: json['matricula'] as String?,
        marca: json['marca'] as String?,
        modelo: json['modelo'] as String?,
        vendedorNome: json['vendedor_nome'] as String?,
        compradorNif: json['comprador_nif'] as String?,
        compradorMorada: json['comprador_morada'] as String?,
        compradorCp: json['comprador_cp'] as String?,
        compradorTelefone: json['comprador_telefone'] as String?,
        compradorLocalidade: json['comprador_localidade'] as String?,
        compradorEmail: json['comprador_email'] as String?,
      );

  final String id;
  final String vehicleId;
  final String compradorNome;
  final double precoFinal;
  final double? comissaoVendedor;
  final String dataVenda;
  final String estado;
  final String? docRegistoCompraUrl;
  final String? docDuaFinalUrl;

  // Vindos do join com veículo/vendedor (só leitura, não editáveis aqui).
  final String? matricula;
  final String? marca;
  final String? modelo;
  final String? vendedorNome;
  final String? compradorNif;
  final String? compradorMorada;
  final String? compradorCp;
  final String? compradorTelefone;
  final String? compradorLocalidade;
  final String? compradorEmail;
}
