import '../vehicles/vehicle.dart';

/// Fatura partilhável entre várias despesas (secção nova, 2026-09-17,
/// "fatura para várias despesas") — criada uma vez em
/// `InvoiceSplitScreen`, depois cada despesa (geral ou de veículo) referencia
/// esta fatura via `invoiceId` para herdar fornecedor/NIF/comprovativo.
class Invoice {
  Invoice({
    required this.id,
    this.fornecedorNome,
    this.fornecedorNif,
    this.data,
    this.valorTotal,
    this.valorIva,
    this.taxaIva,
    this.comprovativoUrl,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        fornecedorNome: json['fornecedor_nome'] as String?,
        fornecedorNif: json['fornecedor_nif'] as String?,
        data: json['data'] as String?,
        valorTotal: parseDecimal(json['valor_total']),
        valorIva: parseDecimal(json['valor_iva']),
        taxaIva: parseDecimal(json['taxa_iva']),
        comprovativoUrl: json['comprovativo_url'] as String?,
      );

  final String id;
  final String? fornecedorNome;
  final String? fornecedorNif;
  final String? data;
  final double? valorTotal;
  final double? valorIva;
  final double? taxaIva;
  final String? comprovativoUrl;
}
