import '../../core/api/api_client.dart';
import 'finance_entry.dart';
import 'finance_evolution.dart';
import 'finance_summary.dart';
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
    return _api.request('GET', '/finance/stock-potencial', parse: (data) => StockPotencial.fromJson(data as Map<String, dynamic>));
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

  Future<void> createEntry({
    required String tipo,
    String? categoria,
    required double valor,
    String? descricao,
    String? data,
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
      },
      parse: (_) {},
    );
  }

  Future<void> updateEntry(
    String id, {
    String? tipo,
    String? categoria,
    double? valor,
    String? descricao,
    String? data,
  }) {
    return _api.request(
      'PATCH',
      '/finance/entries/$id',
      data: {
        if (tipo != null) 'tipo': tipo,
        if (categoria != null) 'categoria': categoria,
        if (valor != null) 'valor': valor,
        if (descricao != null) 'descricao': descricao,
        if (data != null) 'data': data,
      },
      parse: (_) {},
    );
  }

  Future<void> removeEntry(String id) {
    return _api.request('DELETE', '/finance/entries/$id', parse: (_) {});
  }
}
