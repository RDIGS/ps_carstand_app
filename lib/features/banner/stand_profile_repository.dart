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
}
