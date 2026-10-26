import '../../core/api/api_client.dart';
import 'visit_request.dart';

class VisitsRepository {
  VisitsRepository(this._api);

  final ApiClient _api;

  Future<List<VisitRequest>> list({String? estado}) {
    return _api.request(
      'GET',
      '/visitas',
      queryParameters: {if (estado != null) 'estado': estado},
      parse: (data) => (data as List<dynamic>).map((e) => VisitRequest.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Aprovar cria também a lead (origem "Site") e o evento no calendário.
  Future<void> aprovar(String id) => _api.request('POST', '/visitas/$id/aprovar', parse: (_) {});

  Future<void> rejeitar(String id) => _api.request('POST', '/visitas/$id/rejeitar', parse: (_) {});
}
