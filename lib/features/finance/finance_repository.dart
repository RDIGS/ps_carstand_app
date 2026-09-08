import '../../core/api/api_client.dart';
import 'conta_pendente.dart';
import 'finance_entry.dart';
import 'finance_evolution.dart';
import 'finance_statement.dart';
import 'finance_summary.dart';
import 'invoice_extraction_result.dart';
import 'stock_potencial.dart';

class FinanceRepository {
  FinanceRepository(this._api);

  final ApiClient _api;

  Future<FinanceSummary> summary({
    String? dataInicio,
    String? dataFim,
    String? vendedorId,
    String? marca,
    String? modelo,
  }) {
    return _api.request(
      'GET',
      '/finance/summary',
      queryParameters: {
        if (dataInicio != null) 'dataInicio': dataInicio,
        if (dataFim != null) 'dataFim': dataFim,
        if (vendedorId != null) 'vendedorId': vendedorId,
        if (marca != null && marca.isNotEmpty) 'marca': marca,
        if (modelo != null && modelo.isNotEmpty) 'modelo': modelo,
      },
      parse: (data) => FinanceSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<FinanceEvolutionPoint>> evolution({int meses = 12}) {
    return _api.request(
      'GET',
      '/finance/evolution',
      queryParameters: {'meses': meses},
      parse: (data) =>
          (data as List<dynamic>).map((e) => FinanceEvolutionPoint.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<StockPotencial> stockPotencial() {
    return _api.request('GET', '/finance/stock-potencial',
        parse: (data) => StockPotencial.fromJson(data as Map<String, dynamic>));
  }

  Future<FinanceEntriesPage> entries({
    String? dataInicio,
    String? dataFim,
    String? tipo,
    String? categoria,
    int page = 1,
  }) {
    return _api.request(
      'GET',
      '/finance/entries',
      queryParameters: {
        if (dataInicio != null) 'dataInicio': dataInicio,
        if (dataFim != null) 'dataFim': dataFim,
        if (tipo != null) 'tipo': tipo,
        if (categoria != null) 'categoria': categoria,
        'page': page,
      },
      parse: (data) => FinanceEntriesPage.fromJson(data as Map<String, dynamic>),
    );
  }

  // Devolve o lançamento criado (não só void) — o ecrã precisa do `id` para
  // poder logo a seguir carregar a foto do comprovativo.
  Future<FinanceEntry> createEntry({
    required String tipo,
    String? categoria,
    required double valor,
    String? descricao,
    String? data,
    String? metodoPagamento,
    String? pagoPor,
    bool? recorrente,
    String? fornecedorNome,
    String? fornecedorNif,
    double? valorIva,
    double? taxaIva,
    bool? pago,
    String? dataVencimento,
  }) {
    return _api.request(
      'POST',
      '/finance/entries',
      data: {
        'tipo': tipo,
        if (categoria != null) 'categoria': categoria,
        'valor': valor,
        if (descricao != null) 'descricao': descricao,
        if (data != null) 'data': data,
        if (metodoPagamento != null) 'metodoPagamento': metodoPagamento,
        if (pagoPor != null) 'pagoPor': pagoPor,
        if (recorrente != null) 'recorrente': recorrente,
        if (fornecedorNome != null) 'fornecedorNome': fornecedorNome,
        if (fornecedorNif != null) 'fornecedorNif': fornecedorNif,
        if (valorIva != null) 'valorIva': valorIva,
        if (taxaIva != null) 'taxaIva': taxaIva,
        if (pago != null) 'pago': pago,
        if (dataVencimento != null) 'dataVencimento': dataVencimento,
      },
      parse: (data) => FinanceEntry.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> updateEntry(
    String id, {
    String? tipo,
    String? categoria,
    double? valor,
    String? descricao,
    String? data,
    String? metodoPagamento,
    String? pagoPor,
    bool? recorrente,
    bool? reembolsado,
    String? fornecedorNome,
    String? fornecedorNif,
    double? valorIva,
    double? taxaIva,
    bool? pago,
    String? dataVencimento,
    bool limparDataVencimento = false,
  }) {
    return _api.request(
      'PATCH',
      '/finance/entries/$id',
      data: {
        if (tipo != null) 'tipo': tipo,
        // categoria/metodoPagamento/pagoPor/fornecedor* vão sempre, mesmo
        // `null` (limpos pelo utilizador no formulário) — o backend aceita
        // `null` nestes campos (`@IsOptional` do class-validator ignora
        // `null` como o próprio "omitido"), mas rejeitava `''` (não é um
        // valor válido da lista fixa/tipo). Sem isto, limpar um destes
        // campos de volta para "sem valor" ao editar dava erro 400.
        'categoria': categoria,
        if (valor != null) 'valor': valor,
        if (descricao != null) 'descricao': descricao,
        if (data != null) 'data': data,
        'metodoPagamento': metodoPagamento,
        'pagoPor': pagoPor,
        if (recorrente != null) 'recorrente': recorrente,
        if (reembolsado != null) 'reembolsado': reembolsado,
        'fornecedorNome': fornecedorNome,
        'fornecedorNif': fornecedorNif,
        'valorIva': valorIva,
        'taxaIva': taxaIva,
        if (pago != null) 'pago': pago,
        if (dataVencimento != null || limparDataVencimento) 'dataVencimento': dataVencimento,
      },
      parse: (_) {},
    );
  }

  /// Contas a pagar/receber — tudo o que ainda não foi pago/recebido.
  Future<ContasPendentesResumo> contasPendentes() {
    return _api.request(
      'GET',
      '/finance/contas-pendentes',
      parse: (data) => ContasPendentesResumo.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Transitório, nunca grava (mesmo padrão de extractIdentity em
  /// SalesRepository) — lê a foto da fatura/recibo via Gemini e devolve os
  /// campos para pré-preencher o formulário.
  Future<InvoiceExtractionResult> extractInvoice(List<int> foto) {
    return _api.uploadMultipart(
      '/finance/extract-invoice',
      files: {'foto': foto},
      parse: (data) => InvoiceExtractionResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> removeEntry(String id) {
    return _api.request('DELETE', '/finance/entries/$id', parse: (_) {});
  }

  Future<FinanceEntry> uploadComprovativo(String id, List<int> foto) {
    return _api.uploadMultipart(
      '/finance/entries/$id/comprovativo',
      files: {'foto': foto},
      parse: (data) => FinanceEntry.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> removeComprovativo(String id) {
    return _api.request('DELETE', '/finance/entries/$id/comprovativo', parse: (_) {});
  }

  Future<FinanceStatement> statement({required int ano, required int mes}) {
    return _api.request(
      'GET',
      '/finance/statement',
      queryParameters: {'ano': ano, 'mes': mes},
      parse: (data) => FinanceStatement.fromJson(data as Map<String, dynamic>),
    );
  }
}
