import '../finance/finance_entry.dart' show formatFinanceDate;
import 'vehicle.dart';

class VehicleExpense {
  VehicleExpense({
    required this.id,
    required this.categoria,
    required this.valor,
    required this.data,
    this.descricao,
    this.comprovativoUrl,
    this.metodoPagamento,
    this.pagoPor,
    this.reembolsado = false,
    this.fornecedorNome,
    this.fornecedorNif,
    this.valorIva,
    this.taxaIva,
    this.pago = true,
    this.dataVencimento,
  });

  factory VehicleExpense.fromJson(Map<String, dynamic> json) => VehicleExpense(
        id: json['id'] as String,
        categoria: json['categoria'] as String,
        valor: parseDecimal(json['valor']) ?? 0,
        data: formatFinanceDate(json['data'] as String),
        descricao: json['descricao'] as String?,
        comprovativoUrl: json['comprovativo_url'] as String?,
        metodoPagamento: json['metodo_pagamento'] as String?,
        pagoPor: json['pago_por'] as String?,
        reembolsado: json['reembolsado'] as bool? ?? false,
        fornecedorNome: json['fornecedor_nome'] as String?,
        fornecedorNif: json['fornecedor_nif'] as String?,
        valorIva: parseDecimal(json['valor_iva']),
        taxaIva: parseDecimal(json['taxa_iva']),
        pago: json['pago'] as bool? ?? true,
        dataVencimento:
            json['data_vencimento'] != null ? formatFinanceDate(json['data_vencimento'] as String) : null,
      );

  final String id;
  final String categoria;
  final double valor;
  final String data;
  final String? descricao;
  final String? comprovativoUrl;
  final String? metodoPagamento;
  final String? pagoPor;
  final bool reembolsado;
  final String? fornecedorNome;
  final String? fornecedorNif;
  final double? valorIva;
  final double? taxaIva;

  /// Contas a pagar: `false` = despesa ainda não paga (não entra no
  /// cashflow/extrato do mês até ser marcada como paga).
  final bool pago;
  final String? dataVencimento;
}

const vehicleExpenseCategorias = ['reparacao', 'transporte', 'legalizacao', 'limpeza_detalhe', 'outro'];
