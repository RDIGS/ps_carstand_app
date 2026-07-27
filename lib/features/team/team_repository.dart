import '../../core/api/api_client.dart';
import 'team_member.dart';

class InviteResult {
  InviteResult({required this.member, this.tempPassword});

  final TeamMember member;
  final String? tempPassword;
}

class TeamRepository {
  TeamRepository(this._api);

  final ApiClient _api;

  Future<List<TeamMember>> list() {
    return _api.request(
      'GET',
      '/team',
      parse: (data) => (data as List<dynamic>).map((e) => TeamMember.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<InviteResult> invite({required String nome, required String email, required String role}) {
    return _api.request(
      'POST',
      '/team/invite',
      data: {'nome': nome, 'email': email, 'role': role},
      parse: (data) {
        final map = data as Map<String, dynamic>;
        final membership = map['membership'] as Map<String, dynamic>;
        return InviteResult(
          member: TeamMember(
            id: membership['id'] as String,
            personId: membership['personId'] as String,
            role: membership['role'] as String,
            ativo: membership['ativo'] as bool,
            nome: nome,
            email: email,
          ),
          tempPassword: map['tempPassword'] as String?,
        );
      },
    );
  }

  Future<void> update(String memberId, {String? role, bool? ativo}) {
    return _api.request(
      'PATCH',
      '/team/$memberId',
      data: {if (role != null) 'role': role, if (ativo != null) 'ativo': ativo},
      parse: (_) {},
    );
  }

  Future<void> remove(String memberId) {
    return _api.request('DELETE', '/team/$memberId', parse: (_) {});
  }

  Future<String> resetPassword(String memberId) {
    return _api.request(
      'POST',
      '/team/$memberId/reset-password',
      parse: (data) => (data as Map<String, dynamic>)['tempPassword'] as String,
    );
  }
}
