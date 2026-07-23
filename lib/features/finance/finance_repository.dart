import '../../core/api/api_client.dart';
import 'finance_summary.dart';

class FinanceRepository {
  FinanceRepository(this._api);

  final ApiClient _api;

  Future<FinanceSummary> summary({String? periodo}) {
    return _api.request(
      'GET',
      '/finance/summary',
      queryParameters: {if (periodo != null) 'periodo': periodo},
      parse: (data) => FinanceSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> createEntry({required String tipo, String? categoria, required double valor, String? descricao}) {
    return _api.request(
      'POST',
      '/finance/entries',
      data: {'tipo': tipo, if (categoria != null) 'categoria': categoria, 'valor': valor, if (descricao != null) 'descricao': descricao},
      parse: (_) {},
    );
  }
}
