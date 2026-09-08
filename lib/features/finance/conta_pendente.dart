import 'finance_entry.dart' show formatFinanceDate;

class ContaPendente {
  ContaPendente({
    required this.id,
    required this.origem,
    required this.tipo,
    this.categoria,
    this.descricao,
    this.veiculo,
    this.veiculoId,
    required this.valor,
    this.dataVencimento,
    required this.atrasado,
  });

  factory ContaPendente.fromJson(Map<String, dynamic> json) => ContaPendente(
        id: json['id'] as String,
        origem: json['origem'] as String,
        tipo: json['tipo'] as String,
        categoria: json['categoria'] as String?,
        descricao: json['descricao'] as String?,
        veiculo: json['veiculo'] as String?,
        veiculoId: json['veiculoId'] as String?,
        valor: (json['valor'] as num).toDouble(),
        dataVencimento:
            json['dataVencimento'] != null ? formatFinanceDate(json['dataVencimento'] as String) : null,
        atrasado: json['atrasado'] as bool,
      );

  final String id;

  /// 'geral' (finance_entries) ou 'veiculo' (vehicle_expenses) — decide que
  /// repositório/rota usar para "marcar como pago".
  final String origem;
  final String tipo; // 'receita' | 'despesa'
  final String? categoria;
  final String? descricao;
  final String? veiculo;

  /// Só preenchido quando `origem == 'veiculo'` — necessário para chamar
  /// `PATCH /vehicles/:vehicleId/expenses/:id` ao marcar como pago.
  final String? veiculoId;
  final double valor;
  final String? dataVencimento;
  final bool atrasado;
}

class ContasPendentesResumo {
  ContasPendentesResumo({required this.itens, required this.totalPendente, required this.totalEmAtraso, required this.totalAVencerEm7Dias});

  factory ContasPendentesResumo.fromJson(Map<String, dynamic> json) {
    final resumo = json['resumo'] as Map<String, dynamic>;
    return ContasPendentesResumo(
      itens: (json['itens'] as List<dynamic>).map((e) => ContaPendente.fromJson(e as Map<String, dynamic>)).toList(),
      totalPendente: (resumo['totalPendente'] as num).toDouble(),
      totalEmAtraso: (resumo['totalEmAtraso'] as num).toDouble(),
      totalAVencerEm7Dias: (resumo['totalAVencerEm7Dias'] as num).toDouble(),
    );
  }

  final List<ContaPendente> itens;
  final double totalPendente;
  final double totalEmAtraso;
  final double totalAVencerEm7Dias;
}
