/// Resumo do negócio no topo da lista de veículos (só owner) —
/// `GET /finance/painel`.
class PainelStand {
  PainelStand({
    required this.emStock,
    required this.investido,
    required this.margemPrevista,
    required this.semPreco,
    required this.vendasMes,
    required this.lucroMes,
  });

  factory PainelStand.fromJson(Map<String, dynamic> json) => PainelStand(
        emStock: json['em_stock'] as int,
        investido: (json['investido'] as num).toDouble(),
        margemPrevista: (json['margem_prevista'] as num).toDouble(),
        semPreco: json['sem_preco'] as int,
        vendasMes: json['vendas_mes'] as int,
        lucroMes: (json['lucro_mes'] as num).toDouble(),
      );

  final int emStock;

  /// Compra + despesas do que está em stock (disponível/reservado).
  final double investido;

  /// Só dos carros com preço pedido e de compra; os outros contam em [semPreco].
  final double margemPrevista;
  final int semPreco;
  final int vendasMes;
  final double lucroMes;
}
