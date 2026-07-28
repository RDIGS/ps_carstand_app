import '../vehicles/vehicle.dart';

/// Linha crua de GET /sales — vem direto de SELECT * (SQL do tenant), por
/// isso os NUMERIC (preco_final, comissao_vendedor) chegam como String.
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
}
