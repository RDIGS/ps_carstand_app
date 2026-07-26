import '../../core/api/api_client.dart';

class SuggestionsRepository {
  SuggestionsRepository(this._api);

  final ApiClient _api;

  Future<void> submit(String texto) {
    return _api.request('POST', '/suggestions', data: {'texto': texto}, parse: (_) {});
  }
}
