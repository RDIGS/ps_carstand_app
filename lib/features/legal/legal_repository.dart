import '../../core/api/api_client.dart';
import 'legal_models.dart';

class LegalRepository {
  LegalRepository(this._api);

  final ApiClient _api;

  Future<List<PendingLegalDocument>> status() {
    return _api.request(
      'GET',
      '/legal/status',
      parse: (data) => ((data as Map<String, dynamic>)['pendentes'] as List<dynamic>)
          .map((e) => PendingLegalDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> accept(String tipo) {
    return _api.request('POST', '/legal/accept', data: {'tipo': tipo}, parse: (_) {});
  }
}
