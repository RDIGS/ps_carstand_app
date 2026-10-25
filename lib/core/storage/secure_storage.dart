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
  static const _kThemeMode = 'theme_mode';

  // No Windows (flutter_secure_storage_windows 3.x) todas as chaves vivem num
  // único ficheiro encriptado, reescrito por inteiro a cada escrita, sem
  // proteção contra acessos simultâneos — várias operações ao mesmo tempo
  // (ex.: pedidos em paralelo a renovar a sessão) deixam o ficheiro
  // ilegível. Todas as operações passam por esta fila, uma de cada vez.
  Future<void> _fila = Future.value();

  Future<T> _emFila<T>(Future<T> Function() operacao) {
    final resultado = _fila.then((_) => operacao());
    _fila = resultado.then((_) {}, onError: (_) {});
    return resultado;
  }

  // Ficheiro ilegível conta como "não há valor": a sessão perde-se e a app
  // pede login, em vez de o erro subir até ao ApiClient e aparecer como um
  // falso "Sem ligação ao servidor".
  Future<String?> _ler(String key) => _emFila(() async {
        try {
          return await _storage.read(key: key);
        } catch (_) {
          return null;
        }
      });

  Future<void> saveStandToken(String token, String standId, String standNome) => _emFila(() async {
        await _storage.write(key: _kStandToken, value: token);
        await _storage.write(key: _kStandId, value: standId);
        await _storage.write(key: _kStandNome, value: standNome);
      });

  Future<String?> readStandToken() => _ler(_kStandToken);
  Future<String?> readStandId() => _ler(_kStandId);
  Future<String?> readStandNome() => _ler(_kStandNome);

  Future<void> saveSession({
    required String jwt,
    required String refreshToken,
    required String userId,
    required String userNome,
    required String userRole,
    required String userIdioma,
  }) =>
      _emFila(() async {
        await _storage.write(key: _kJwt, value: jwt);
        await _storage.write(key: _kRefreshToken, value: refreshToken);
        await _storage.write(key: _kUserId, value: userId);
        await _storage.write(key: _kUserNome, value: userNome);
        await _storage.write(key: _kUserRole, value: userRole);
        await _storage.write(key: _kUserIdioma, value: userIdioma);
      });

  Future<String?> readJwt() => _ler(_kJwt);
  Future<String?> readRefreshToken() => _ler(_kRefreshToken);
  Future<String?> readUserId() => _ler(_kUserId);
  Future<String?> readUserNome() => _ler(_kUserNome);
  Future<String?> readUserRole() => _ler(_kUserRole);
  Future<String?> readUserIdioma() => _ler(_kUserIdioma);

  Future<void> saveUserIdioma(String idioma) => _emFila(() => _storage.write(key: _kUserIdioma, value: idioma));

  /// Preferência de tema (secção 11: claro é o default) — é do dispositivo,
  /// não da conta, por isso vive só aqui, não em `saveSession`.
  Future<String?> readThemeMode() => _ler(_kThemeMode);
  Future<void> saveThemeMode(String mode) => _emFila(() => _storage.write(key: _kThemeMode, value: mode));

  /// Logout normal: mantém o token do stand guardado (secção 4), só limpa a sessão.
  Future<void> clearSession() => _emFila(() async {
        try {
          await _storage.delete(key: _kJwt);
          await _storage.delete(key: _kRefreshToken);
          await _storage.delete(key: _kUserId);
          await _storage.delete(key: _kUserNome);
          await _storage.delete(key: _kUserRole);
          await _storage.delete(key: _kUserIdioma);
        } catch (_) {
          // Ficheiro ilegível: apagar tudo é a única forma de sair do estado
          // estragado (o token do stand já se tinha perdido com ele).
          try {
            await _storage.deleteAll();
          } catch (_) {}
        }
      });

  /// Logout completo do dispositivo: também esquece o token do stand.
  Future<void> clearAll() => _emFila(() => _storage.deleteAll());
}
