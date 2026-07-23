import '../../core/api/api_client.dart';
import 'audit_entry.dart';

class AuditRepository {
  AuditRepository(this._api);

  final ApiClient _api;

  Future<List<AuditEntry>> list({String? entidade}) {
    return _api.request(
      'GET',
      '/audit',
      queryParameters: {if (entidade != null) 'entidade': entidade},
      parse: (data) => (data as List<dynamic>)
          .map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
