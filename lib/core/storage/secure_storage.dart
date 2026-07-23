import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// O token do stand só é pedido 1 vez e fica guardado encriptado (secção 4);
/// só volta a ser pedido depois de um logout completo do dispositivo.
class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kStandToken = 'stand_token';
  static const _kStandId = 'stand_id';
  static const _kStandNome = 'stand_nome';
  static const _kJwt = 'jwt';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUserNome = 'user_nome';
  static const _kUserRole = 'user_role';
  static const _kUserIdioma = 'user_idioma';

  Future<void> saveStandToken(String token, String standId, String standNome) async {
    await _storage.write(key: _kStandToken, value: token);
    await _storage.write(key: _kStandId, value: standId);
    await _storage.write(key: _kStandNome, value: standNome);
  }

  Future<String?> readStandToken() => _storage.read(key: _kStandToken);
  Future<String?> readStandId() => _storage.read(key: _kStandId);
  Future<String?> readStandNome() => _storage.read(key: _kStandNome);

  Future<void> saveSession({
    required String jwt,
    required String refreshToken,
    required String userId,
    required String userNome,
    required String userRole,
    required String userIdioma,
  }) async {
    await _storage.write(key: _kJwt, value: jwt);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
    await _storage.write(key: _kUserId, value: userId);
    await _storage.write(key: _kUserNome, value: userNome);
    await _storage.write(key: _kUserRole, value: userRole);
    await _storage.write(key: _kUserIdioma, value: userIdioma);
  }

  Future<String?> readJwt() => _storage.read(key: _kJwt);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);
  Future<String?> readUserNome() => _storage.read(key: _kUserNome);
  Future<String?> readUserRole() => _storage.read(key: _kUserRole);
  Future<String?> readUserIdioma() => _storage.read(key: _kUserIdioma);

  Future<void> saveUserIdioma(String idioma) => _storage.write(key: _kUserIdioma, value: idioma);

  /// Logout normal: mantém o token do stand guardado (secção 4), só limpa a sessão.
  Future<void> clearSession() async {
    await _storage.delete(key: _kJwt);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUserNome);
    await _storage.delete(key: _kUserRole);
    await _storage.delete(key: _kUserIdioma);
  }

  /// Logout completo do dispositivo: também esquece o token do stand.
  Future<void> clearAll() => _storage.deleteAll();
}
