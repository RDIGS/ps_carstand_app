import '../../core/api/api_client.dart';
import 'lead.dart';

class LeadsRepository {
  LeadsRepository(this._api);

  final ApiClient _api;

  Future<LeadListPage> list({String? estado, int page = 1, int limit = 50}) {
    return _api.request(
      'GET',
      '/leads',
      queryParameters: {if (estado != null) 'estado': estado, 'page': page, 'limit': limit},
      parse: (data) => LeadListPage.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Lead> create({
    required String nome,
    String? telefone,
    String? email,
    String? origem,
    String? vehicleId,
    String? notas,
    String? proximoContacto,
  }) {
    return _api.request(
      'POST',
      '/leads',
      data: {
        'nome': nome,
        if (telefone != null) 'telefone': telefone,
        if (email != null) 'email': email,
        if (origem != null) 'origem': origem,
        if (vehicleId != null) 'vehicleId': vehicleId,
        if (notas != null) 'notas': notas,
        if (proximoContacto != null) 'proximoContacto': proximoContacto,
      },
      parse: (data) => Lead.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Lead> update(
    String id, {
    String? nome,
    String? telefone,
    String? email,
    String? origem,
    String? estado,
    String? notas,
    String? proximoContacto,
  }) {
    return _api.request(
      'PATCH',
      '/leads/$id',
      data: {
        if (nome != null) 'nome': nome,
        if (telefone != null) 'telefone': telefone,
        if (email != null) 'email': email,
        if (origem != null) 'origem': origem,
        if (estado != null) 'estado': estado,
        if (notas != null) 'notas': notas,
        if (proximoContacto != null) 'proximoContacto': proximoContacto,
      },
      parse: (data) => Lead.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> remove(String id) {
    return _api.request('DELETE', '/leads/$id', parse: (_) {});
  }
}
