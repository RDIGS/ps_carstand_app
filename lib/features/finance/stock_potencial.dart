import '../vehicles/vehicle.dart';

class StockPotencialVeiculo {
  StockPotencialVeiculo({
    required this.id,
    required this.matricula,
    required this.marca,
    required this.modelo,
    this.precoCompra,
    this.precoVendaRecomendado,
    required this.despesas,
    required this.margemPotencial,
    required this.diasEmStock,
  });

  factory StockPotencialVeiculo.fromJson(Map<String, dynamic> json) => StockPotencialVeiculo(
        id: json['id'] as String,
        matricula: json['matricula'] as String,
        marca: json['marca'] as String,
        modelo: json['modelo'] as String,
        precoCompra: parseDecimal(json['preco_compra']),
        precoVendaRecomendado: parseDecimal(json['preco_venda_recomendado']),
        despesas: parseDecimal(json['despesas']) ?? 0,
        margemPotencial: parseDecimal(json['margem_potencial']) ?? 0,
        diasEmStock: (json['dias_em_stock'] as num).toInt(),
      );

  final String id;
  final String matricula;
  final String marca;
  final String modelo;
  final double? precoCompra;
  final double? precoVendaRecomendado;
  final double despesas;
  final double margemPotencial;
  final int diasEmStock;
}

class StockPotencial {
  StockPotencial({required this.veiculos, required this.totalMargemPotencial});

  factory StockPotencial.fromJson(Map<String, dynamic> json) => StockPotencial(
        veiculos: (json['veiculos'] as List<dynamic>)
            .map((e) => StockPotencialVeiculo.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalMargemPotencial: (json['total_margem_potencial'] as num).toDouble(),
      );

  final List<StockPotencialVeiculo> veiculos;
  final double totalMargemPotencial;
}
