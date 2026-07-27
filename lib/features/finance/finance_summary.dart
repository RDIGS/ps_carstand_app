import '../vehicles/vehicle.dart';

/// Total por categoria — usado tanto para despesas gerais (finance_entries)
/// como para despesas de veículo (vehicle_expenses); pedido explícito do
/// utilizador para os dois tipos ficarem sempre claramente distintos, nunca
/// só somados escondidos no cashflow.
class CategoriaTotal {
  CategoriaTotal({required this.categoria, required this.total});

  factory CategoriaTotal.fromJson(Map<String, dynamic> json) =>
      CategoriaTotal(categoria: json['categoria'] as String?, total: (json['total'] as num).toDouble());

  final String? categoria;
  final double total;
}

/// Espelha a resposta de GET /finance/summary (secção 12.5). Linhas de
/// SQL bruto no backend devolvem NUMERIC/COUNT(*) como String — os getters
/// aqui tratam disso, os mapas ficam soltos porque isto é só para
/// apresentação, não para reenviar ao backend.
class FinanceSummary {
  FinanceSummary({
    required this.periodoInicio,
    required this.periodoFim,
    required this.despesasGeraisPorCategoria,
    required this.despesasVeiculosPorCategoria,
    required this.margemPorVeiculo,
    required this.margemPorMarcaModelo,
    required this.rankingVendedores,
    this.desvioPrecoRecomendadoMedio,
    this.comparacaoMercadoMedia,
    required this.cashflowDoMes,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    final periodo = json['periodo'] as Map<String, dynamic>;
    return FinanceSummary(
      periodoInicio: periodo['inicio'] as String,
      periodoFim: periodo['fim'] as String,
      despesasGeraisPorCategoria: (json['despesas_gerais_por_categoria'] as List<dynamic>)
          .map((e) => CategoriaTotal.fromJson(e as Map<String, dynamic>))
          .toList(),
      despesasVeiculosPorCategoria: (json['despesas_veiculos_por_categoria'] as List<dynamic>)
          .map((e) => CategoriaTotal.fromJson(e as Map<String, dynamic>))
          .toList(),
      margemPorVeiculo: List<Map<String, dynamic>>.from(json['margem_por_veiculo'] as List),
      margemPorMarcaModelo: List<Map<String, dynamic>>.from(json['margem_por_marca_modelo'] as List),
      rankingVendedores: List<Map<String, dynamic>>.from(json['ranking_vendedores'] as List),
      desvioPrecoRecomendadoMedio: (json['desvio_preco_recomendado_medio'] as num?)?.toDouble(),
      comparacaoMercadoMedia: (json['comparacao_mercado_media'] as num?)?.toDouble(),
      cashflowDoMes: (json['cashflow_do_mes'] as num).toDouble(),
    );
  }

  final String periodoInicio;
  final String periodoFim;
  final List<CategoriaTotal> despesasGeraisPorCategoria;
  final List<CategoriaTotal> despesasVeiculosPorCategoria;
  final List<Map<String, dynamic>> margemPorVeiculo;
  final List<Map<String, dynamic>> margemPorMarcaModelo;
  final List<Map<String, dynamic>> rankingVendedores;
  final double? desvioPrecoRecomendadoMedio;
  final double? comparacaoMercadoMedia;
  final double cashflowDoMes;
}

/// COUNT(*) do Postgres também chega como String via node-pg (bigint).
int parseCount(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value as String) ?? 0;
}

// Reexporta o parser de NUMERIC/DECIMAL partilhado com o resto da app.
double? parseFinanceDecimal(dynamic value) => parseDecimal(value);
