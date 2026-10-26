import '../../core/api/api_client.dart';
import 'stand_profile.dart';

class StandProfileRepository {
  StandProfileRepository(this._api);

  final ApiClient _api;

  Future<StandProfile> getProfile() {
    return _api.request(
      'GET',
      '/stands/me',
      parse: (data) => StandProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<StandProfile> updateProfile({String? contacto, String? redesSociais}) {
    return _api.request(
      'PATCH',
      '/stands/me',
      data: {
        if (contacto != null) 'contacto': contacto,
        if (redesSociais != null) 'redesSociais': redesSociais,
      },
      parse: (data) => StandProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Gravação completa a partir do ecrã de Definições do stand — campos de
  /// texto vazios vão como `null` (apagam o valor), nunca como ''.
  Future<StandProfile> saveSettings({
    required String? contacto,
    required String? redesSociais,
    required String? morada,
    required String? slug,
    required bool siteAtivo,
    required bool vendedorPodeAprovarVisitas,
    required String? nif,
    required String? denominacaoSocial,
    required String? localidade,
  }) {
    return _api.request(
      'PATCH',
      '/stands/me',
      data: {
        'contacto': contacto,
        'redesSociais': redesSociais,
        'morada': morada,
        'slug': slug,
        'siteAtivo': siteAtivo,
        'vendedorPodeAprovarVisitas': vendedorPodeAprovarVisitas,
        'nif': nif,
        'denominacaoSocial': denominacaoSocial,
        'localidade': localidade,
      },
      parse: (data) => StandProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<StandProfile> uploadLogo(List<int> logo) {
    return _api.uploadMultipart(
      '/stands/me/logo',
      files: {'logo': logo},
      parse: (data) => StandProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<StandProfile> removeLogo() {
    return _api.request(
      'DELETE',
      '/stands/me/logo',
      parse: (data) => StandProfile.fromJson(data as Map<String, dynamic>),
    );
  }
}
