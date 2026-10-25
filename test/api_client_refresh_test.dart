import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ps_carstand_app/core/api/api_client.dart';
import 'package:ps_carstand_app/core/storage/secure_storage.dart';

/// Sessão em memória — só os métodos que o ApiClient usa.
class _StorageFalso extends SecureStorage {
  _StorageFalso({this.jwt, this.refreshToken});

  String? jwt;
  String? refreshToken;
  int sessoesGravadas = 0;
  int sessoesLimpas = 0;

  @override
  Future<String?> readJwt() async => jwt;
  @override
  Future<String?> readRefreshToken() async => refreshToken;
  @override
  Future<String?> readUserIdioma() async => 'pt';

  @override
  Future<void> saveSession({
    required String jwt,
    required String refreshToken,
    required String userId,
    required String userNome,
    required String userRole,
    required String userIdioma,
  }) async {
    sessoesGravadas++;
    this.jwt = jwt;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearSession() async {
    sessoesLimpas++;
    jwt = null;
    refreshToken = null;
  }
}

/// Backend falso que imita o real: JWT válido só o mais recente, refresh
/// token de uso único (rodado a cada renovação, o antigo deixa de valer).
class _BackendFalso implements HttpClientAdapter {
  _BackendFalso({required this.refreshAceite});

  String jwtValido = 'jwt-novo-0';
  String refreshAceite;
  int renovacoes = 0;
  // Corre a meio de cada pedido (depois de enviado, antes da resposta) —
  // para simular outro pedido que renovou a sessão entretanto.
  void Function(RequestOptions)? aMeioDoPedido;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    aMeioDoPedido?.call(options);
    if (options.path == '/auth/refresh') {
      final pedido = options.data as Map<String, dynamic>;
      if (pedido['refreshToken'] != refreshAceite) return _json(401, {'error': 'refresh_invalido'});
      renovacoes++;
      jwtValido = 'jwt-novo-$renovacoes';
      refreshAceite = 'refresh-$renovacoes';
      return _json(200, {
        'jwt': jwtValido,
        'refresh_token': refreshAceite,
        'user': {'id': 'u1', 'nome': 'Teste', 'role': 'owner', 'idioma': 'pt'},
      });
    }
    if (options.headers['Authorization'] != 'Bearer $jwtValido') return _json(401, {'error': 'nao_autenticado'});
    return _json(200, {'ok': options.path});
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  test('vários pedidos com JWT expirado partilham uma única renovação e nenhum faz logout', () async {
    final storage = _StorageFalso(jwt: 'jwt-expirado', refreshToken: 'refresh-0');
    final backend = _BackendFalso(refreshAceite: 'refresh-0');
    var sessaoExpirada = 0;
    final api = ApiClient(storage, onSessionExpired: () => sessaoExpirada++);
    api.raw.httpClientAdapter = backend;

    final resultados = await Future.wait([
      for (var i = 0; i < 5; i++) api.request('GET', '/recurso/$i', parse: (d) => d['ok'] as String),
    ]);

    expect(resultados, ['/recurso/0', '/recurso/1', '/recurso/2', '/recurso/3', '/recurso/4']);
    expect(backend.renovacoes, 1, reason: 'só pode haver uma renovação para os 5 pedidos');
    expect(storage.sessoesGravadas, 1);
    expect(storage.sessoesLimpas, 0, reason: 'a sessão era válida, não pode haver logout');
    expect(sessaoExpirada, 0);
    expect(storage.jwt, 'jwt-novo-1');
  });

  test('refresh recusado (sessão expirada a sério) faz logout uma única vez', () async {
    final storage = _StorageFalso(jwt: 'jwt-expirado', refreshToken: 'refresh-expirado');
    final backend = _BackendFalso(refreshAceite: 'outro');
    var sessaoExpirada = 0;
    final api = ApiClient(storage, onSessionExpired: () => sessaoExpirada++);
    api.raw.httpClientAdapter = backend;

    final erros = await Future.wait([
      for (var i = 0; i < 5; i++)
        api.request('GET', '/recurso/$i', parse: (d) => d).then<Object?>((_) => null, onError: (Object e) => e),
    ]);

    expect(erros.every((e) => e is ApiException), isTrue, reason: 'todos falham com erro da API');
    expect(erros.whereType<ApiException>().every((e) => e.error != 'erro_rede'), isTrue,
        reason: 'não pode aparecer como "Sem ligação ao servidor"');
    expect(sessaoExpirada, 1, reason: 'um só aviso de sessão expirada, não um por pedido');
    expect(storage.sessoesLimpas, 1);
  });

  test('pedido que saiu com o JWT antigo depois de outro já ter renovado não renova outra vez', () async {
    final storage = _StorageFalso(jwt: 'jwt-velho', refreshToken: 'refresh-velho');
    final backend = _BackendFalso(refreshAceite: 'refresh-velho')..jwtValido = 'jwt-velho';
    var primeiraVez = true;
    backend.aMeioDoPedido = (_) {
      if (!primeiraVez) return;
      primeiraVez = false;
      // Enquanto este pedido estava em viagem com 'jwt-velho', outro pedido
      // renovou a sessão (o refresh antigo já não vale).
      backend.jwtValido = 'jwt-ja-renovado';
      backend.refreshAceite = 'refresh-ja-renovado';
      storage.jwt = 'jwt-ja-renovado';
      storage.refreshToken = 'refresh-ja-renovado';
    };
    final api = ApiClient(storage);
    api.raw.httpClientAdapter = backend;

    final resultado = await api.request('GET', '/recurso/x', parse: (d) => d['ok'] as String);
    expect(resultado, '/recurso/x');
    expect(backend.renovacoes, 0, reason: 'devia repetir com o JWT já renovado, não renovar outra vez');
    expect(storage.sessoesLimpas, 0);
  });
}
