class StockAlerts {
  StockAlerts({required this.veiculosParados, required this.limiteDias});

  factory StockAlerts.fromJson(Map<String, dynamic> json) => StockAlerts(
        veiculosParados: json['veiculos_parados'] as int,
        limiteDias: json['limite_dias'] as int,
      );

  final int veiculosParados;
  final int limiteDias;
}
