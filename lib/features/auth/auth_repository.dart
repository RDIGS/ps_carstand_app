import '../../core/api/api_client.dart';

class ValidateTokenResult {
  ValidateTokenResult({required this.standId, required this.standNome, required this.tokenEstado});

  factory ValidateTokenResult.fromJson(Map<String, dynamic> json) => ValidateTokenResult(
        standId: json['stand_id'] as String,
        standNome: json['stand_nome'] as String,
        tokenEstado: json['token_estado'] as String,
      );

  final String standId;
  final String standNome;
  final String tokenEstado;
}

class LoginResult {
  LoginResult({
    required this.jwt,
    required this.refreshToken,
    required this.userId,
    required this.userNome,
    required this.userRole,
    required this.userIdioma,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return LoginResult(
      jwt: json['jwt'] as String,
      refreshToken: json['refresh_token'] as String,
      userId: user['id'] as String,
      userNome: user['nome'] as String,
      userRole: user['role'] as String,
      userIdioma: user['idioma'] as String? ?? 'pt',
    );
  }

  final String jwt;
  final String refreshToken;
  final String userId;
  final String userNome;
  final String userRole;
  final String userIdioma;
}

/// Estado da subscrição do stand (secção 3.4, O14) — contagens já vêm
/// calculadas do backend (nunca confiar na data do dispositivo).
class SubscriptionStatus {
  SubscriptionStatus({
    required this.tokenEstado,
    this.tokenValidoAte,
    required this.diasAvisoPrevio,
    required this.diasCarencia,
    this.diasParaExpirar,
    this.diasCarenciaRestantes,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) => SubscriptionStatus(
        tokenEstado: json['token_estado'] as String,
        tokenValidoAte: json['token_valido_ate'] as String?,
        diasAvisoPrevio: json['dias_aviso_previo'] as int,
        diasCarencia: json['dias_carencia'] as int,
        diasParaExpirar: json['dias_para_expirar'] as int?,
        diasCarenciaRestantes: json['dias_carencia_restantes'] as int?,
      );

  final String tokenEstado;
  final String? tokenValidoAte;
  final int diasAvisoPrevio;
  final int diasCarencia;
  final int? diasParaExpirar;
  final int? diasCarenciaRestantes;

  /// Se deve mostrar o aviso persistente no ecrã principal.
  bool get mostrarAviso {
    if (tokenEstado == 'em_carencia') return true;
    if (tokenEstado == 'ativo' && diasParaExpirar != null) {
      return diasParaExpirar! <= diasAvisoPrevio && diasParaExpirar! >= 0;
    }
    return false;
  }
}

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<ValidateTokenResult> validateStandToken(String token) {
    return _api.request(
      'POST',
      '/auth/validate-token',
      data: {'token': token},
      parse: (data) => ValidateTokenResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<LoginResult> login({required String email, required String password, required String standId}) {
    return _api.request(
      'POST',
      '/auth/login',
      data: {'email': email, 'password': password, 'standId': standId},
      parse: (data) => LoginResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> logout(String refreshToken) {
    return _api.request('POST', '/auth/logout', data: {'refreshToken': refreshToken}, parse: (_) {});
  }

  Future<void> updateIdioma(String idioma) {
    return _api.request('PATCH', '/auth/idioma', data: {'idioma': idioma}, parse: (_) {});
  }

  Future<SubscriptionStatus> subscriptionStatus() {
    return _api.request(
      'GET',
      '/auth/subscription-status',
      parse: (data) => SubscriptionStatus.fromJson(data as Map<String, dynamic>),
    );
  }
}
