class FinanceEvolutionPoint {
  FinanceEvolutionPoint({required this.periodo, required this.vendas, required this.numVendas, required this.cashflow});

  factory FinanceEvolutionPoint.fromJson(Map<String, dynamic> json) => FinanceEvolutionPoint(
        periodo: json['periodo'] as String,
        vendas: (json['vendas'] as num).toDouble(),
        numVendas: (json['num_vendas'] as num).toInt(),
        cashflow: (json['cashflow'] as num).toDouble(),
      );

  final String periodo; // "YYYY-MM"
  final double vendas;
  final int numVendas;
  final double cashflow;
}
