import 'dart:math' as math;

import '../vehicles/vehicle_detail.dart';

/// Cálculos do banner de venda (secção nova, pedido do utilizador 2026-07-25):
/// conversão kW→CV e simulação de prestação de crédito. Valores fixos
/// combinados com o utilizador (TAN 10%, 120 meses, 100% financiado) —
/// não vêm de nenhuma configuração, propositadamente, para não abrir a
/// porta a alterações silenciosas destes números legalmente sensíveis.
class BannerCalculo {
  const BannerCalculo._();

  static const double _tanAnual = 0.10;
  static const int _prazoMeses = 120;

  /// kW → CV (1 CV = 0.73549875 kW), arredondado ao inteiro mais próximo.
  static int? potenciaCv(int? potenciaKw) {
    if (potenciaKw == null) return null;
    return (potenciaKw * 1.35962).round();
  }

  /// Preço-base usado no banner e no financiamento: final se existir, senão
  /// o recomendado. `null` se o veículo não tiver nenhum dos dois.
  static double? precoBase(VehicleDetail vehicle) {
    return vehicle.precoVendaFinal ?? vehicle.precoVendaRecomendado;
  }

  /// Prestação mensal pela fórmula PMT (100% financiado, sem entrada):
  /// PMT = P · r / (1 − (1 + r)⁻ⁿ), r = taxa mensal, n = número de meses.
  static double? prestacaoMensal(double? valorFinanciado) {
    if (valorFinanciado == null || valorFinanciado <= 0) return null;
    const taxaMensal = _tanAnual / 12;
    final fator = 1 - math.pow(1 + taxaMensal, -_prazoMeses);
    return valorFinanciado * taxaMensal / fator;
  }

  /// Ano da 1ª matrícula real (secção 12.0 — nunca o campo "I" para
  /// importados), extraído de uma data ISO "AAAA-MM-DD".
  static String? ano(String? dataIso) {
    if (dataIso == null || dataIso.length < 4) return null;
    return dataIso.substring(0, 4);
  }
}
