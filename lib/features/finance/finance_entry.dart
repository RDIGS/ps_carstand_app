import '../vehicles/vehicle.dart';

// Colunas DATE do Postgres chegam como meia-noite UTC do dia guardado —
// convertidas com `DateTime.parse` (sem `.toLocal()`) diretamente com
// `.substring(0,10)`, num dispositivo a leste de UTC (Portugal em horário
// de verão, ou o próprio servidor) a data mostrada fica 1 dia atrasada
// (ex.: 27 guardado aparece como "...T23:00:00.000Z" do dia 26). `toLocal()`
// devolve a data de calendário correta.
String formatFinanceDate(String isoData) => DateTime.parse(isoData).toLocal().toIso8601String().substring(0, 10);

class FinanceEntry {
  FinanceEntry({
    required this.id,
    required this.tipo,
    this.categoria,
    required this.valor,
    this.descricao,
    required this.data,
    this.comprovativoUrl,
    this.metodoPagamento,
    this.pagoPor,
    this.pagoPorNome,
    this.reembolsado = false,
    this.recorrente = false,
    this.fornecedorNome,
    this.fornecedorNif,
    this.valorIva,
    this.taxaIva,
  });

  factory FinanceEntry.fromJson(Map<String, dynamic> json) => FinanceEntry(
        id: json['id'] as String,
        tipo: json['tipo'] as String,
        categoria: json['categoria'] as String?,
        valor: parseDecimal(json['valor']) ?? 0,
        descricao: json['descricao'] as String?,
        data: formatFinanceDate(json['data'] as String),
        comprovativoUrl: json['comprovativo_url'] as String?,
        metodoPagamento: json['metodo_pagamento'] as String?,
        pagoPor: json['pago_por'] as String?,
        pagoPorNome: json['pago_por_nome'] as String?,
        reembolsado: json['reembolsado'] as bool? ?? false,
        recorrente: json['recorrente'] as bool? ?? false,
        fornecedorNome: json['fornecedor_nome'] as String?,
        fornecedorNif: json['fornecedor_nif'] as String?,
        valorIva: parseDecimal(json['valor_iva']),
        taxaIva: parseDecimal(json['taxa_iva']),
      );

  final String id;
  final String tipo;
  final String? categoria;
  final double valor;
  final String? descricao;
  final String data;

  /// URL da foto da fatura/comprovativo — `null` se ainda não foi carregada.
  final String? comprovativoUrl;
  final String? metodoPagamento;

  /// Id da pessoa que pagou do próprio bolso — `null` = pago diretamente
  /// pela empresa.
  final String? pagoPor;

  /// Nome dessa pessoa, já resolvido pelo backend (join) — só para mostrar.
  final String? pagoPorNome;

  /// Só relevante quando `pagoPor` está preenchido.
  final bool reembolsado;

  /// Gera automaticamente o lançamento do mês seguinte (FinanceRecurringCron).
  final bool recorrente;

  /// Dados fiscais do comprovativo — pré-preenchidos pela leitura automática
  /// da fatura, mas sempre editáveis à mão.
  final String? fornecedorNome;
  final String? fornecedorNif;
  final double? valorIva;
  final double? taxaIva;
}

class FinanceEntriesPage {
  FinanceEntriesPage({required this.entries, required this.total, required this.page, required this.limit});

  factory FinanceEntriesPage.fromJson(Map<String, dynamic> json) => FinanceEntriesPage(
        entries:
            (json['entries'] as List<dynamic>).map((e) => FinanceEntry.fromJson(e as Map<String, dynamic>)).toList(),
        total: json['total'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
      );

  final List<FinanceEntry> entries;
  final int total;
  final int page;
  final int limit;

  bool get temMaisPaginas => page * limit < total;
}
